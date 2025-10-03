import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test1/page-1/artsit_skills_edit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';



import '../config.dart';
import '../utils.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _addressController= TextEditingController();
  TextEditingController _altPhoneController=TextEditingController();
  TextEditingController _teamNameController=TextEditingController();

  // Variables to hold profile data
  // String _name = '';
  // int _age = 0;
  // String _phoneNo = '';
  // String _address = '';
  File? _image;
  String? _imageUrl; // For profile photo URL from backend

  final storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'token'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getid() async {
    return await storage.read(key: 'artist_id'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getTeamid() async {
    return await storage.read(key: 'team_id'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getKind() async {
    return await storage.read(key: 'selected_value'); // Assuming you stored the token with key 'token'
  }

  Future<void> fetchArtistInformation() async {
    String? token = await _getToken();
    String? id = await _getid();
    String? team_id = await _getTeamid();
    String? kind = await _getKind();
    // print(token);
    print(id);
    print(kind);

    // Initialize API URLs for different kinds
    String apiUrl;
      if (kind == 'solo_artist') {
      apiUrl = '${Config().apiDomain}/artist/info/$id';
    } else if (kind == 'team') {
      apiUrl = '${Config().apiDomain}/artist/team_info/$team_id';
    } else {
      // Handle the case where kind is not recognized
      return;
    }

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
          'Authorization': 'Bearer $token', // Include the token in the header
        },
      );
      if (response.statusCode == 200) {
        // Parse the response JSON
        Map<String, dynamic> userData = json.decode(response.body);
        print(userData);

        // Update text controllers with fetched data
        setState(() {
          _nameController.text = userData['data']['attributes']['name'] ?? '';
          _teamNameController.text=userData['data']['attributes']['team_name'] ?? '';
          _phoneController.text = userData['data']['attributes']['phone_number'] ?? '';
          // _ageController.text = userData['data']['attributes']['age']?.toString() ?? '';
          _addressController.text = userData['data']['attributes']['address'] ?? '';
          _altPhoneController.text=userData['data']['attributes']['alt_phone_number'] ?? userData['data']['attributes']['alternate_number']  ??'';
          _imageUrl=userData['data']['attributes']['profile_photo'];
          // _sController.text = userData['data']['attributes']['state'] ?? '';
          // _pinCodeController.text = userData['data']['attributes']['pin'] ?? '';
        });
        print('address is ${_addressController.text}');
        print('profile photo is $_imageUrl');
      } else {
        print('Failed to fetch user information. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user information: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchArtistInformation(); // Fetch profile data when screen initializes
  }

  // // Function to update profile data to backend
  // void updateProfileData() {
  //   // Call your backend API to update data
  //   // Display success or error message accordingly
  //   // For simplicity, we'll just print the data here
  //   print('Updated Profile:');
  //   print('Name: $_name');
  //   print('Age: $_age');
  //   print('Phone No: $_phoneNo');
  //   print('Address: $_address');
  // }

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
         _imageUrl= null; // For profile photo URL from backend

      } else {
        print('No image selected.');
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    // Condition to determine which controller to use
    bool useTeamController = _teamNameController.text.isNotEmpty;
    bool useAltPhoneController=_altPhoneController.text.isNotEmpty;

    // Dynamically select the controller based on the condition
    TextEditingController? selectedController =
    useTeamController ? _teamNameController : _nameController;

    TextEditingController? newSelectedController=
        useAltPhoneController? _altPhoneController:_ageController;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            color: Color(0xffe5195e), // Change icon button color
            onPressed: () async {
              await _saveUserInformation(); // Call function to update profile data
              // After editing the image, call the function to upload it
              if (_image != null) {
                uploadImage(_image!);
              }
              Navigator.pop(context); // Go back to previous screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Picture (You can implement this with ImagePicker)
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 190,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0), // Round the container
                  border: Border.all(color: Colors.grey), // Change border color
                ),
                alignment: Alignment.center,
                child: _image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.file(
                    _image!,
                    width: 190,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                )
                    : _imageUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    _imageUrl!,
                    width: 190,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(Icons.person, size: 100, color: Colors.grey),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Tap to change profile picture',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Name
            TextFormField(
              controller: selectedController, // Use the defined text controller
              decoration: InputDecoration(
                labelText: useTeamController? 'Team Name': 'Name',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15.0), // Round the container
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xffe5195e),
                  ), // Change focused border color
                  borderRadius: BorderRadius.circular(15.0), // Round the container
                ),
              ),
            ),
            SizedBox(height: 20), // Add space between Name and Age fields

            // Conditional rendering for Age or Alternate Phone Number
            _getKind() == 'team'
                ? TextFormField(
              controller: _altPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Alternate Phone Number',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15.0), // Round the container
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xffe5195e),
                  ), // Change focused border color
                  borderRadius: BorderRadius.circular(15.0), // Round the container
                ),
              ),
            )
                : TextFormField(
              controller: _phoneController, // Use the defined text controller
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15.0), // Round the container
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xffe5195e),
                  ), // Change focused border color
                  borderRadius: BorderRadius.circular(15.0), // Round the container
                ),
              ),
            ),
            SizedBox(height: 20), // Add space between Age/Phone Number and Address fields

            // Phone Number
            TextFormField(
              controller: newSelectedController, // Use the defined text controller
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: useAltPhoneController ? 'Alternate Phone Number' : 'Enter alternate Phone No',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15.0), // Round the container
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xffe5195e),
                  ), // Change focused border color
                  borderRadius: BorderRadius.circular(15.0), // Round the container
                ),
              ),
            ),
            SizedBox(height: 20), // Add space between Phone Number and Address fields

            // Address
            TextFormField(
              controller: _addressController, // Use the defined text controller
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15.0), // Round the container
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xffe5195e),
                  ), // Change focused border color
                  borderRadius: BorderRadius.circular(15.0), // Round the container
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Future<void> _saveUserInformation() async {
    final storage = FlutterSecureStorage();

    String? token = await _getToken();
    String? id = await _getid();
    String? team_id = await _getTeamid();
    String? kind = await _getKind();
    print(kind);
    print (token);


    // Initialize API URLs for different kinds
    String apiUrl;
    if (kind == 'solo_artist') {
      apiUrl = '${Config().apiDomain}/artist/info/$id';
    } else if (kind == 'team') {
      apiUrl = '${Config().apiDomain}/artist/team_info/$team_id';
    } else {
      // Handle the case where kind is not recognized
      return;
    }

    // Prepare data to send to the backend
    Map<String, dynamic> userData = {
      'name': _nameController.text,
      'phone_number': _phoneController.text,
      'address': _addressController.text,
      // 'age': _ageController.text,
      'team_name':_teamNameController.text,
      'alt_phone_number': _altPhoneController.text,
      // 'state': _stateController.text,
      // 'pin': _pinCodeController.text,
    };

    try {
      // Make PUT request to the API
      var response = await http.patch(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
          'Authorization': 'Bearer $token', // Include the token in the header
        },
        body: jsonEncode(userData),
      );

      // Check if request was successful (status code 200)
      if (response.statusCode == 200) {
        // User information saved successfully, handle response if needed
        print('User information saved successfully');
        // Example response handling
        print('Response: ${response.body}');
      } else {
        // Request failed, handle error
        print('Failed to save user information. Status code: ${response
            .statusCode}');
        // Example error handling
        print('Error response: ${response.body}');
      }
    } catch (e) {
      // Handle network errors
      print('Error saving user information: $e');
    }
  }


  void uploadImage(File imageFile) async {
    String? token = await _getToken();
    String? id = await _getid();
    String? teamId = await _getTeamid();
    String? kind = await _getKind();

    String apiUrl;
    if (kind == 'solo_artist') {
      apiUrl = '${Config().apiDomain}/artist/upload_image/$id';
    } else if (kind == 'team') {
      apiUrl = '${Config().apiDomain}/team/upload_image/$teamId';
    } else {
      return;
    }

    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.api+json',
      });

      // Add the file
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
          'profile_photo',
          stream,
          length,
          filename: imageFile.path.split('/').last
      );
      request.files.add(multipartFile);

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      // Process the response
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        print('Response: $responseData');
      } else {
        print('Failed to upload image. Status: ${response.statusCode}');
        print('Response: $responseData');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }




}


