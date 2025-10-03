import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class EditPaymentInfoScreen extends StatefulWidget {
  @override
  _EditPaymentInfoScreenState createState() => _EditPaymentInfoScreenState();
}

class _EditPaymentInfoScreenState extends State<EditPaymentInfoScreen> {
  bool isUpiSelected = true;
  bool isAccountSelected = false;
int? detailsID;
  TextEditingController _upiController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _ifscController = TextEditingController();
  TextEditingController _accountHolderNameController = TextEditingController();
  final storage = FlutterSecureStorage();

  Future<String?> _getid() async {
    return await storage.read(key: 'artist_id'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getTeamid() async {
    return await storage.read(key: 'team_id'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getKind() async {
    return await storage.read(key: 'selected_value'); // Assuming you stored the token with key 'token'
  }

  @override
  void initState() {
    super.initState();
    fetchArtistInformation(); // Fetch profile data when screen initializes
  }

  Future<void> fetchArtistInformation() async {
    String? artistId = await _getid();
    String? teamId = await _getTeamid();
    String? kind = await _getKind();

    // Set the base API URL
    String apiUrl = '${Config().apiDomain}/details/info';

    try {
      // Set up the request body
      Map<String, dynamic> requestBody = {
        if (kind == 'solo_artist') 'artist_id': artistId,
        if (kind == 'team') 'team_id': teamId,
      };
      print('request is $requestBody');

      // Make the POST request with the request body
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        Map<String, dynamic> userData = json.decode(response.body);
        print('payment info is $userData');

        // Update text controllers with fetched data
        setState(() {
          detailsID=userData['id'] ?? '';
           _upiController.text = userData['UPI_id'] ?? '';
          _accountNumberController.text = userData['account_number'] ?? '';
          _ifscController.text = userData['IFSC_code'] ?? '';
           _accountHolderNameController.text = userData['account_holder_name'] ?? '';
        });
      } else {
        print('Failed to fetch user information. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user information: $e');
    }
  }

  Future<void> _saveUserInformation() async {

    // Initialize API URLs for different kinds
    String apiUrl='${Config().apiDomain}/artist-bank-details/$detailsID';


    // Prepare data to send to the backend
    Map<String, dynamic> userData = {

      'UPI_id': _upiController.text,
      'account_number': _accountNumberController.text,
      'account_holder_name': _accountHolderNameController.text,
      'IFSC_code': _ifscController.text,
    };

    try {
      // Make PUT request to the API
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
          // Include the token in the header
        },
        body: jsonEncode(userData),
      );

      // Check if request was successful (status code 200)
      if (response.statusCode == 200) {
        // User information saved successfully, handle response if needed
        print('bank details saved successfully');
        // Example response handling
        print('Response: ${response.body}');
      } else {
        // Request failed, handle error
        print('Failed to save bank details. Status code: ${response
            .statusCode}');
        // Example error handling
        print('Error response: ${response.body}');
      }
    } catch (e) {
      // Handle network errors
      print('Error saving user information: $e');
    }
  }



  void _savePaymentInfo() {
    // Logic to handle saving the payment information
    if (isUpiSelected) {
      String upiId = _upiController.text;
      // Save or validate UPI ID
      print("UPI ID: $upiId");
    } else if (isAccountSelected) {
      String accountNumber = _accountNumberController.text;
      String ifscCode = _ifscController.text;
      String accountHolderName = _accountHolderNameController.text;
      // Save or validate account details
      print("Account Number: $accountNumber");
      print("IFSC Code: $ifscCode");
      print("Account Holder Name: $accountHolderName");
    }
  }

  @override
  Widget build(BuildContext context) {
    double fem = MediaQuery.of(context).size.width / 360;
    double ffem = fem * 0.8;

    return Scaffold(
      backgroundColor: Color(0xFF121217),
      appBar: AppBar(
        backgroundColor: Color(0xFF121217),
        title: Text(
          'Edit Payment Information',
          style: TextStyle(
            fontSize: 20 * ffem,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16 * fem, 0, 16 * fem, 10 * fem),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: Color(0xFF121217),
              margin: EdgeInsets.only(bottom: 20 * fem),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'For Receiving Payments',
                    style: TextStyle(
                      fontSize: 17 * ffem,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 14 * fem),

                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text(
                            'UPI ID',
                            style: TextStyle(color: Colors.white),
                          ),
                          value: true,
                          groupValue: isUpiSelected,
                          onChanged: (value) {
                            setState(() {
                              isUpiSelected = value!;
                              isAccountSelected = !value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text(
                            'Account',
                            style: TextStyle(color: Colors.white),
                          ),
                          value: true,
                          groupValue: isAccountSelected,
                          onChanged: (value) {
                            setState(() {
                              isAccountSelected = value!;
                              isUpiSelected = !value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  Visibility(
                    visible: isUpiSelected,
                    child: Container(
                      width: double.infinity,
                      height: 70 * fem,
                      margin: EdgeInsets.only(top: 10 * fem),
                      child: TextField(
                        controller: _upiController,
                        decoration: InputDecoration(
                          hintText: 'Your UPI ID',
                          hintStyle: TextStyle(color: Color(0xFF9E9EB8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * fem),
                            borderSide: BorderSide(
                              width: 1.25,
                              color: Color(0xFF9E9EB8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * fem),
                            borderSide: BorderSide(
                              width: 1.25,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  Visibility(
                    visible: isAccountSelected,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 70 * fem,
                          margin: EdgeInsets.only(top: 10 * fem),
                          child: TextField(
                            controller: _accountNumberController,
                            decoration: InputDecoration(
                              hintText: 'Account Number',
                              hintStyle: TextStyle(color: Color(0xFF9E9EB8)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                  width: 1.25,
                                  color: Color(0xFF9E9EB8),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                  width: 1.25,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 70 * fem,
                          margin: EdgeInsets.only(top: 10 * fem),
                          child: TextField(
                            controller: _ifscController,
                            decoration: InputDecoration(
                              hintText: 'IFSC Code',
                              hintStyle: TextStyle(color: Color(0xFF9E9EB8)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                  width: 1.25,
                                  color: Color(0xFF9E9EB8),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                  width: 1.25,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 70 * fem,
                          margin: EdgeInsets.only(top: 10 * fem),
                          child: TextField(
                            controller: _accountHolderNameController,
                            decoration: InputDecoration(
                              hintText: 'Account Holder Name',
                              hintStyle: TextStyle(color: Color(0xFF9E9EB8)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                  width: 1.25,
                                  color: Color(0xFF9E9EB8),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                                borderSide: BorderSide(
                                  width: 1.25,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20 * fem),
                  // Save Button
                  ElevatedButton(
                    onPressed: _saveUserInformation,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Color(0xFFA53A5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * fem),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Save Payment Information',
                        style: TextStyle(
                          fontSize: 16 * ffem,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _upiController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }
}