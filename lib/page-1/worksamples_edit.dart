import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'account_managment.dart';

import '../utils.dart';

class ArtistCredentials44 extends StatefulWidget {
  @override
  _ArtistCredentialsState createState() => _ArtistCredentialsState();
}

class _ArtistCredentialsState extends State<ArtistCredentials44> {
  File? _audioFile1;
  File? _audioFile2;
  File? _videoFile1;
  File? _videoFile2;
  String? _imageFile1Url;
  String? _imageFile2Url;
  String? _imageFile3Url;
 String? _imageFile4Url;
  File? _searchedImage;
  File? _imageFile1;
  File? _imageFile2;
  File? _imageFile3;
  File? _imageFile4;

  String baseUrl = 'http://127.0.0.1:8000/storage/';


  final storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'token'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getid() async {
    return await storage.read(key: 'id'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getKind() async {
    return await storage.read(key: 'selected_value'); // Assuming you stored the token with key 'token'
  }


  Future<void> fetchArtistWorkInformation() async {
    String? token = await _getToken();
    String? id = await _getid();
    String? kind = await _getKind();

    print(token);
    print(id);
    print(kind);

    // Initialize API URLs for different kinds
    String apiUrl;
    if (kind == 'solo_artist') {
      apiUrl = 'http://127.0.0.1:8000/api/artist/info/$id';
    } else {
      apiUrl = 'http://127.0.0.1:8000/api/artist/team_info/$id';
    }

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = json.decode(response.body);

        // Construct complete URLs for images
         // Replace with your actual base URL
        String image1Url = '$baseUrl/${userData['data']['attributes']['image1']}';
        String image2Url = '$baseUrl/${userData['data']['attributes']['image2']}';
        String image3Url = '$baseUrl/${userData['data']['attributes']['image3']}';
        String image4Url = '$baseUrl/${userData['data']['attributes']['image4']}';

        print(image1Url);

        setState(() {
          _imageFile1Url = image1Url;
          _imageFile2Url = image2Url;
          _imageFile3Url = image3Url;
          _imageFile4Url = image4Url;
        });
      } else {
        print('Failed to fetch user information. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user information: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchArtistWorkInformation(); // Fetch profile data when screen initializes
  }

  Future<void> _pickAudio1() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _audioFile1 = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickAudio2() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _audioFile2 = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVideo1() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoFile1 = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVideo2() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoFile2 = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImage1() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile1 = File(pickedFile.path);
        _imageFile1Url = null; // Reset the URL if an image is picked from the device
      });
    }
  }

  Future<void> _pickImage2() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile2 = File(pickedFile.path);
        _imageFile2Url = null; // Reset the URL if an image is picked from the device
      });
    }
  }

  Future<void> _pickImage3() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile3 = File(pickedFile.path);
        _imageFile3Url = null; // Reset the URL if an image is picked from the device
      });
    }
  }

  Future<void> _pickImage4() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile4 = File(pickedFile.path);
        _imageFile4Url = null; // Reset the URL if an image is picked from the device
      });
    }
  }

  Future<void> _pickImageForSearchedSection() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _searchedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Work Samples',
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: 20),
              Text(
                'Upload Videos Here',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _pickVideo1,
                        child: Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey.withOpacity(0.3),
                          child: _videoFile1 != null
                              ? Text('Video 1 selected!')
                              : Icon(Icons.upload_outlined),
                        ),
                      ),
                      if (_videoFile1 != null) Text('Video 1 selected!'),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _pickVideo2,
                        child: Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey.withOpacity(0.3),
                          child: _videoFile2 != null
                              ? Text('Video 2 selected!')
                              : Icon(Icons.upload_outlined),
                        ),
                      ),
                      if (_videoFile2 != null) Text('Video 2 selected!'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Upload Images Here',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage1,
                        child: Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey.withOpacity(0.3),
                          child: _imageFile1 != null
                              ? Image.file(
                            _imageFile1!,
                            fit: BoxFit.cover,
                          )
                              : _imageFile1Url != null
                              ? Image.network(
                            _imageFile1Url!,
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.upload_outlined),
                        ),
                      ),
                      if (_imageFile1Url != null || _imageFile1 != null)
                        Text('Image 1 selected!'),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage2,
                        child: Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey.withOpacity(0.3),
                          child: _imageFile2 != null
                              ? Image.file(
                            _imageFile2!,
                            fit: BoxFit.cover,
                          )
                              : _imageFile2Url != null
                              ? Image.network(
                            _imageFile2Url!,
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.upload_outlined),
                        ),
                      ),
                      if (_imageFile2Url != null || _imageFile2 != null)
                        Text('Image 2 selected!'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage3,
                        child: Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey.withOpacity(0.3),
                          child: _imageFile3 != null
                              ? Image.file(
                            _imageFile3!,
                            fit: BoxFit.cover,
                          )
                              : _imageFile3Url != null
                              ? Image.network(
                            _imageFile3Url!,
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.upload_outlined),
                        ),
                      ),
                      if (_imageFile3Url != null || _imageFile3 != null)
                        Text('Image 3 selected!'),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage4,
                        child: Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey.withOpacity(0.3),
                          child: _imageFile4 != null
                              ? Image.file(
                            _imageFile4!,
                            fit: BoxFit.cover,
                          )
                              : _imageFile4Url != null
                              ? Image.network(
                            _imageFile4Url!,
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.upload_outlined),
                        ),
                      ),
                      if (_imageFile4Url != null || _imageFile4 != null)
                        Text('Image 4 selected!'),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 45),
                child: ElevatedButton(
                  onPressed: () {
                    _saveUserInformation();
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>account_managment()));
                    // Handle button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffe5195e),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10 * fem),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * fem,
                      vertical: 12 * fem,
                    ),
                    minimumSize: Size(double.infinity, 14 * fem),
                  ),
                  child: Center(
                    child: Text(
                      'Done',
                      style: SafeGoogleFont(
                        'Be Vietnam Pro',
                        fontSize: 17 * ffem,
                        fontWeight: FontWeight.w500,
                        height: 1.5 * ffem / fem,
                        letterSpacing: 0.2399999946 * fem,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<bool> _saveUserInformation() async {
    final storage = FlutterSecureStorage();

    Future<String?> _getToken() async {
      return await storage.read(key: 'token');
    }

    Future<String?> _getid() async {
      return await storage.read(key: 'id');
    }

    Future<String?> _getKind() async {
      return await storage.read(key: 'selected_value'); // Assuming you stored the token with key 'token'
    }

    String? token = await _getToken();
    String? id = await _getid();
    String? kind = await _getKind();

    // Initialize API URLs for different kinds
    String apiUrl;
    if (kind == 'solo_artist') {
      apiUrl = 'http://127.0.0.1:8000/api/artist/info/$id';
    } else {
      apiUrl = 'http://127.0.0.1:8000/api/artist/team_info/$id';
    }


    List<File?> imageFiles = [_imageFile1, _imageFile2, _imageFile3, _imageFile4];
    List<String?> imageFileUrls = [_imageFile1Url, _imageFile2Url, _imageFile3Url, _imageFile4Url];

    Map<String, dynamic> artistData = {};

    // Loop through imageFiles and imageFileUrls to check for alterations
    for (int i = 0; i < imageFiles.length; i++) {
      File? imageFile = imageFiles[i];
      String? imageUrl = imageFileUrls[i];

      if (imageFile != null) {
        // If the image has been altered, upload it and store the path
        String imagePath = await uploadImagesAndStorePaths(imageFile);
        artistData['image${i + 1}'] = imagePath;
      } else if (imageUrl != null) {
        // If the image has not been altered, remove the base URL
        String relativeImagePath = imageUrl.replaceAll('$baseUrl', '');
        artistData['image${i + 1}'] = relativeImagePath;
      }
    }

    try {
      // Make PATCH request to the API
      var response = await http.patch(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
          'Authorization': 'Bearer $token', // Include the token in the header
        },
        body: jsonEncode(artistData),
      );

      // Check if request was successful (status code 200)
      if (response.statusCode == 200) {
        // User information saved successfully, handle response if needed
        print('User information saved successfully');
        // Example response handling
        print('Response: ${response.body}');
        return true;
      } else {
        // Request failed, handle error
        print('Failed to save user information. Status code: ${response.statusCode}');
        // Example error handling
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle network errors
      print('Error saving user information: $e');
    }
    return false;
  }



  Future<String> uploadImagesAndStorePaths(File? imageFile) async {
    if (imageFile == null) {
      throw ArgumentError('Image file cannot be null');
    }
    String imagePath = '';
    // Your image upload API endpoint
    var uploadUrl = Uri.parse('http://127.0.0.1:8000/api/upload-image');

    // Create a multipart request
    var request = http.MultipartRequest('POST', uploadUrl);

    // Add the image file to the request
    var image = await http.MultipartFile.fromPath('image', imageFile.path);

    request.files.add(image);

    // Send the request to upload the image
    var streamedResponse = await request.send();
    print(streamedResponse);

    // Check if the image upload was successful
    if (streamedResponse.statusCode == 200) {
      // Parse the response to get the image URL or file path
      var response = await streamedResponse.stream.bytesToString();

      imagePath = json.decode(response)['imagePath'];
    }
    //   else {
    //     throw Exception('Failed to upload image');
    //   }
    // } catch (e) {
    //   // Handle errors if needed
    //   print('Error uploading image: $e');
    //   throw Exception('Error uploading image: $e');
    // }
    return imagePath;
  }
}
