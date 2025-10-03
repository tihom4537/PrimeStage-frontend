import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test1/page-1/artist_info_edit.dart';
import 'package:test1/page-1/artsit_skills_edit.dart';
import 'package:test1/page-1/customer_support.dart';
import 'package:test1/page-1/delete_account.dart';
import 'package:test1/page-1/edit_user_info.dart';
import 'package:test1/page-1/payment_edit.dart';
import 'package:test1/page-1/worksamples_edit.dart';
import 'package:test1/page-1/edit_team_members.dart';

import '../utils.dart';
import 'edit_team_members.dart';




class account_managment extends StatelessWidget {
  final storage = FlutterSecureStorage();

  Future<String?> _getKind() async {
    return await storage.read(key: 'selected_value');
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(backgroundColor: Color(0xFF121217)
      ,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disables the default back button
        title: Row(
          children: [
            // iOS-style Back Button
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios, // iOS back arrow style
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context); // Navigate back
              },
            ),
            // Title
            Expanded(
              child: Center(
                child:Text(
                  'Account',
                  style: SafeGoogleFont (
                    'Be Vietnam Pro',
                    fontSize: 20*ffem,
                    fontWeight: FontWeight.w500,
                    height: 1.25*ffem/fem,
                    letterSpacing: -0.2700000107*fem,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 48), // To balance the Row (space for back button)
          ],
        ),
        backgroundColor: Color(0xFF121217),
      ),

      body: SafeArea(
        child: FutureBuilder<String?>(
          future: _getKind(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            String? kind = snapshot.data;

            // Check the value of 'kind' and set boolean flags accordingly
            bool isHire = kind == 'hire';
            bool isSoloArtist = kind == 'solo_artist';
            bool isTeam = kind == 'team';

            return Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Edit Profile
                  if (isHire)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserInformation()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 6 * fem, 10 * fem),
                        width: double.infinity,
                        height: 56 * fem,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Logo or Icon on the left
                            Container(
                              width: 30 * fem, // Adjust size if necessary
                              height: 44 * fem,
                              margin: EdgeInsets.only(right: 10 * fem),
                              child: Icon(
                                Icons.person, // Replace with the desired icon or logo
                                color: Colors.white,
                              ),
                            ),
                            // Text
                            Expanded(
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 17 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5 * ffem / fem,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Arrow icon on the right
                            Container(
                              width: 64 * fem,
                              height: 44 * fem,
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Edit Artist Profile (based on conditions)
                  if (isSoloArtist || isTeam)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfileScreen()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 6 * fem, 10 * fem),
                        width: double.infinity,
                        height: 56 * fem,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30 * fem, // Adjust width if necessary
                              height: 44 * fem,
                              margin: EdgeInsets.only(right: 10 * fem),
                              child: Icon(
                                Icons.account_circle_outlined, // Replace with the desired icon or logo
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Text(
                                  isSoloArtist ? 'Edit Artist Profile' : 'Edit Team Profile',
                                  style: TextStyle(
                                    fontSize: 18 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5 * ffem / fem,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 64 * fem,
                              height: 44 * fem,
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,color: Colors.white
                                ,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Edit Skills (based on conditions)
                  if (isTeam)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditTeamMembersPage()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 6 * fem, 10 * fem),
                        width: double.infinity,
                        height: 56 * fem,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Logo/Icon on the left
                            Container(
                              width: 30 * fem, // Adjust width if necessary
                              height: 44 * fem,
                              margin: EdgeInsets.only(right: 10 * fem),
                              child: Icon(
                                Icons.group, // Replace with the desired icon or logo
                                color: Colors.white,
                              ),
                            ),
                            // Text
                            Expanded(
                              child: Text(
                                'Edit Team Members',
                                style: TextStyle(
                                  fontSize: 18 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5 * ffem / fem,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Arrow icon on the right
                            Container(
                              width: 64 * fem,
                              height: 44 * fem,
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (isSoloArtist || isTeam)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ArtistCredentials33()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 6 * fem, 10 * fem),
                        width: double.infinity,
                        height: 56 * fem,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Logo or Icon on the left
                            Container(
                              width: 30 * fem, // Adjust size as needed
                              height: 44 * fem,
                              margin: EdgeInsets.only(right: 10 * fem),
                              child: Icon(
                                Icons.star, // Replace with your desired logo or Image widget
                                color: Colors.white,
                              ),
                            ),
                            // Text
                            Expanded(
                              child: Text(
                                'Edit Skills',
                                style: TextStyle(
                                  fontSize: 17 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5 * ffem / fem,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Arrow icon on the right
                            Container(
                              width: 64 * fem,
                              height: 44 * fem,
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // // Edit Work Samples (based on conditions)
                  // if (isSoloArtist || isTeam)
                  //   InkWell(
                  //     onTap: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) => ArtistCredentials44()),
                  //       );
                  //     },
                  //     child: Container(
                  //       padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 6 * fem, 10 * fem),
                  //       width: double.infinity,
                  //       height: 56 * fem,
                  //       decoration: BoxDecoration(
                  //         border: Border(
                  //           bottom: BorderSide(
                  //             color: Colors.grey,
                  //             width: 0.2,
                  //           ),
                  //         ),
                  //       ),
                  //       child: Row(
                  //         children: [
                  //           // Expanded(
                  //           //   child: Container(
                  //           //     child: Text(
                  //           //       'Edit Work Samples',
                  //           //       style: TextStyle(
                  //           //         fontSize: 17 * ffem,
                  //           //         fontWeight: FontWeight.w400,
                  //           //         height: 1.5 * ffem / fem,
                  //           //         color: Colors.white,
                  //           //       ),
                  //           //     ),
                  //           //   ),
                  //           // ),
                  //           // Container(
                  //           //   width: 64 * fem,
                  //           //   height: 44 * fem,
                  //           //   child: Icon(
                  //           //     Icons.arrow_forward_ios_rounded,color: Colors.white,
                  //           //   ),
                  //           // ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // Report a Problem
                  if (isSoloArtist || isTeam)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditPaymentInfoScreen()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 6 * fem, 10 * fem),
                        width: double.infinity,
                        height: 56 * fem,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey, // Border color
                              width: 0.25, // Border width
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Left-side Icon
                            Container(
                              width: 30 * fem, // Icon container width
                              height: 44 * fem, // Icon container height
                              child: Center(
                                child: Icon(
                                  Icons.payment, // Icon representing payment
                                  color: Colors.white, // Icon color
                                  size: 26 * fem, // Icon size
                                ),
                              ),
                            ),
                            SizedBox(width: 8 * fem), // Space between the icon and the text
                            // Text
                            Expanded(
                              child: Text(
                                'Edit Payment Information', // Updated text spacing
                                style: TextStyle(
                                  fontSize: 17 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5 * ffem / fem,
                                  color: Colors.white, // Text color
                                ),
                              ),
                            ),
                            // Right-side Arrow Icon
                            Container(
                              width: 64 * fem,
                              height: 44 * fem,
                              child: Icon(
                                Icons.arrow_forward_ios_rounded, // Arrow icon
                                color: Colors.white, // Icon color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SupportScreen()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 6 * fem, 10 * fem),
                      width: double.infinity,
                      height: 56 * fem,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey, // Border color
                            width: 0.2, // Border width
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon on the left
                          Container(
                            width: 30 * fem, // Icon container width
                            height: 44 * fem, // Icon container height
                            child: Center( // Ensures the icon is vertically centered
                              child: Icon(
                                Icons.report_problem, // Use an appropriate icon
                                color: Colors.white, // Icon color
                                size: 26 * fem, // Icon size
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * fem), // Space between the icon and the text
                          // Expanded widget for the text
                          Expanded(
                            child: Text(
                              'Report a Problem',
                              style: TextStyle(
                                fontSize: 17 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.5 * ffem / fem,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Arrow icon on the right
                          Container(
                            width: 64 * fem,
                            height: 44 * fem,
                            child: Icon(
                              Icons.arrow_forward_ios_rounded, // Right-side arrow icon
                              color: Colors.white, // Icon color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Delete Account
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => account_delete()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 6 * fem, 10 * fem),
                      width: double.infinity,
                      height: 56 * fem,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey, // Border color
                            width: 0.25, // Border width
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon on the left
                          Container(
                            width: 30 * fem, // Icon container width
                            height: 44 * fem, // Icon container height
                            child: Center( // Center the icon vertically
                              child: Icon(
                                Icons.delete_forever, // Delete icon
                                color: Colors.red, // Icon color
                                size: 26 * fem, // Icon size
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * fem), // Space between the icon and the text
                          // Expanded widget for the text
                          Expanded(
                            child: Text(
                              'Delete Account',
                              style: TextStyle(
                                fontSize: 17 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.5 * ffem / fem,
                                color: Colors.red, // Text color matches the icon
                              ),
                            ),
                          ),
                          // Arrow icon on the right
                          Container(
                            width: 64 * fem,
                            height: 44 * fem,
                            child: Icon(
                              Icons.arrow_forward_ios_rounded, // Right-side arrow icon
                              color: Colors.white, // Icon color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
