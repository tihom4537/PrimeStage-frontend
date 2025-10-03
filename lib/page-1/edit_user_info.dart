import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config.dart';

class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  TextEditingController _nameController = TextEditingController();
  // TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController=TextEditingController();
  // TextEditingController _buildingController = TextEditingController();
  // TextEditingController _cityController = TextEditingController();
  // TextEditingController _stateController = TextEditingController();
  // TextEditingController _pinCodeController = TextEditingController();

  final storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'token'); // Assuming you stored the token with key 'token'
  }

  Future<String?> _getId() async {
    return await storage.read(key: 'user_id'); // Assuming you stored the token with key 'id'
  }

  Future<String?> _getKind() async {
    return await storage.read(key: 'selected_value'); // Assuming you stored the kind with key 'selected_value'
  }

  @override
  void initState() {
    super.initState();
    // Fetch user information from the backend
    fetchUserInformation();
  }

  Future<void> fetchUserInformation() async {
    String? token = await _getToken();
    String? id = await _getId();
    String? kind = await _getKind();
    print(token);
    print(id);
    print(kind);
    // Example URL, replace with your actual API endpoint
    String apiUrl = '${Config().apiDomain}/info/$id';


    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
           // Include the token in the header
        },
      );
      if (response.statusCode == 200) {
        // Parse the response JSON
        Map<String, dynamic> userData = json.decode(response.body);
        print(userData);

        // Update text controllers with fetched data
        setState(() {
          _nameController.text = userData['first_name'] ?? '';
           _emailController.text = userData['last_name'] ?? '';
          _phoneController.text = userData['phone_number'] ?? '';
          // _buildingController.text = userData['house_no_building'] ?? '';
          // _cityController.text = userData['city'] ?? '';
          // _stateController.text = userData['state'] ?? '';
          // _pinCodeController.text = userData['pin'] ?? '';
        });
        print(_phoneController.text);
      } else {
        print('Failed to fetch user information. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user information: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
      backgroundColor: Color(0xFF121217),
      appBar: AppBar(
        backgroundColor: Color(0xFF121217),
        title: Text('Account', style: TextStyle(color: Colors.white)),
        actions: [
          GestureDetector(
            onTap: () {
              _saveUserInformation(); // Call function to save user information
              // Show a snackbar to inform the user that their information is updated
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Your information is updated.'),
                  duration: Duration(seconds: 2), // Adjust the duration as needed
                ),
              );

              setState(() {

              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: Color(0xFF388FE5), // Change the text color as needed
                    fontSize: 16, // Change the font size as needed
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildEditableRow("Name:", _nameController, fem, ffem),
                  // buildEditableRow("Last Name:", _lastNameController, fem, ffem),
                  buildEditableRow("Email:", _emailController, fem, ffem),
                  buildEditableRow("Phone No:", _phoneController, fem, ffem),
                  // buildEditableRow("Building:", _buildingController, fem, ffem),
                  // buildEditableRow("City:", _cityController, fem, ffem),
                  // buildEditableRow("State:", _stateController, fem, ffem),
                  // buildEditableRow("Pin Code:", _pinCodeController, fem, ffem),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditableRow(String label, TextEditingController controller, double fem, double ffem) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Change the label color as needed
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white, // Change the text color inside the boxes
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFF292938), // Background color of the text field
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white), // Border color
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFF9E9EB8), // Change the focused border color as needed
                  width: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveUserInformation() async {
    String? token = await _getToken();
    String? id = await _getId();
    print(token);
    print(id);
    // Example URL, replace with your actual API endpoint
    String apiUrl = '${Config().apiDomain}/info/$id';

    // Prepare data to send to the backend
    Map<String, dynamic> userData = {
      'first_name': _nameController.text,
      'last_name': _emailController.text,
      'phone_number': _phoneController.text,
      // 'house_no_building': _buildingController.text,
      // 'city': _cityController.text,
      // 'state': _stateController.text,
      // 'pin': _pinCodeController.text,
    };

    try {
      // Make PATCH request to the API
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
        print('Failed to save user information. Status code: ${response.statusCode}');
        // Example error handling
        print('Error response: ${response.body}');
      }
    } catch (e) {
      // Handle network errors
      print('Error saving user information: $e');
    }
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: UserInformation(),
//   ));
// }
