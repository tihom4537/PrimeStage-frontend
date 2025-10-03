import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test1/page-1/page0.dart';

import '../config.dart';

class account_delete extends StatelessWidget {

  // Function to delete account
  Future<bool> _deleteAccount() async {
    final storage = FlutterSecureStorage();


    Future<String?> _getId() async {
      return await storage.read(key: 'artist_id');
    }
    Future<String?> _getUser_id() async {
      return await storage.read(key: 'user_id'); // Assuming you stored the token with key 'token'
    }
    Future<String?> _getTeam_id() async {
      return await storage.read(key: 'team_id'); // Assuming you stored the token with key 'token'
    }


    String? user_id = await _getUser_id();

    Future<String?> _getKind() async {
      return await storage.read(key: 'selected_value');
    }

    String? team_id = await _getTeam_id();
    String? id = await _getId();
    String? kind = await _getKind();



    String apiUrlHire = '${Config().apiDomain}/info/$user_id';
    String apiUrlArtist='${Config().apiDomain}/artist/info/$id';
    String apiUrlTeam='${Config().apiDomain}/artist/team_info/$team_id';

    try {
      // Make DELETE request to the API based on the value of 'kind'
      var response;
      if (kind == 'hire') {
        // Make API call for kind value 1
        response = await http.delete(
          Uri.parse(apiUrlHire),
          headers: <String, String>{
            'Content-Type': 'application/vnd.api+json',
            'Accept': 'application/vnd.api+json',

          },
        );
      } else if (kind == 'solo_artist') {
        // Make API call for kind value 2
        // Update apiUrl if needed
        response = await http.delete(
          Uri.parse(apiUrlArtist),
          headers: <String, String>{
            'Content-Type': 'application/vnd.api+json',
            'Accept': 'application/vnd.api+json',

          },
        );
      } else if (kind == 'team') {
        // Make API call for kind value 3
        // Update apiUrl if needed
        response = await http.delete(
          Uri.parse(apiUrlTeam),
          headers: <String, String>{
            'Content-Type': 'application/vnd.api+json',
            'Accept': 'application/vnd.api+json',

          },
        );
      } else {
        // Handle other cases if needed
        print('Invalid value of kind: $kind');

      }

      // Check if request was successful (status code 204)
      if (response.statusCode == 204) {
        // Account deleted successfully
        print('Account deleted successfully');
        await storage.write(key: 'authorised', value: 'false');
        await storage.write(key: 'user_signup', value: 'false');
        return true;

      } else {
        // Request failed, handle error
        print('Failed to delete account. Status code: ${response.statusCode}');
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle network errors
      print('Error deleting account: $e');
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(backgroundColor:Color(0xFF121217),
      appBar:
      AppBar(title: const Text('Account', style: TextStyle(color: Colors.white),),
      backgroundColor: Color(0xFF121217)
        ,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Container(
            width: double.infinity,
            height: 844*fem,
            decoration: BoxDecoration (
              color: Color(0xFF121217)
              ,
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration (
                color: Color(0xFF121217),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(height: 674*fem,width: double.infinity,
                      padding: EdgeInsets.all(20),
                      child: const Text(
                        'Before proceeding with the deletion of your account, we want to ensure that '
                            'you\'re fully informed about the implications of this action. Deleting your '
                            'account will result in the permanent removal of all your data from our servers, '
                            'regardless of its secure encryption by Stargrime. '
                            '\n\nWe understand that this decision may be significant for you,'
                            ' and we want to reassure you that your security and privacy are '
                            'of the utmost importance to us. If you have any concerns or encounter '
                            'any issues during this process, please don\'t '
                            'hesitate to reach out to us through the customer'
                            ' support option available in the settings.'
                            '\n\nOur dedicated support team is here to assist'
                            ' you every step of the way and address any questions or concerns you may have. '
                            'Your satisfaction and peace of mind are our top priorities, and we\'re '
                            'committed to ensuring that you have a'
                            ' positive experience with our service.',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontFamily: 'Be Vietnam Pro', // Change font family as needed
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 45, right: 45),
                      child: ElevatedButton(
                        onPressed: () async {
                          // _showDialog('Alert','Are you sure that you want to delete your account');

                          bool deleted= await _deleteAccount();
                          // _deleteAccount();
                          if (deleted) {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) =>
                                Scene()));
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Account delete failed . Please try again.'),
                                duration: Duration(seconds: 3), // Adjust the duration as needed
                              ),
                            );
                          }
                          // Call function to delete account
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffe5195e),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * fem),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * fem,
                            vertical: 12 * fem,
                          ),
                          minimumSize: Size(double.infinity, 14 * fem),
                        ),
                        child: Center(
                          child: Text(
                            'Delete Account',
                            style: TextStyle(
                              fontSize: 16 * ffem,
                              fontWeight: FontWeight.w700,
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
          ),
        ),
      ),
    );
  }

  // void _showDialog( String title, String message) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(title),
  //         content: Text(message),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

}
