import 'package:flutter/material.dart';
import 'package:test1/page-1/page1.dart';
import '../utils.dart';
import 'package:test1/page-1/phone_varification.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'loc_service_ui.dart';

class Scene extends StatefulWidget {
  @override
  _SceneState createState() => _SceneState();
}

class _SceneState extends State<Scene> {
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    double baseWidth = MediaQuery.of(context).size.width > 400 ? 400 : MediaQuery.of(context).size.width;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    double screenHeight = MediaQuery.of(context).size.height;

    void saveSelectedValue(String value) async {
      await storage.write(key: 'selected_value', value: value);
    }

    return Scaffold(backgroundColor: Color(0xFF121217),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Color(0xFF121217),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 0 * fem), // Use consistent horizontal padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).orientation == Orientation.portrait ? 230 * fem : 180 * fem,
                      child: Image.asset(
                        'assets/page-1/images/pexels-koolshooters-6983014.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 14 * fem),
                    Text(
                      'Elevate your moments!',
                      textAlign: TextAlign.center,
                      style: SafeGoogleFont(
                        'Be Vietnam Pro',
                        fontSize: 26 * ffem,
                        fontWeight: FontWeight.w600,
                        height: 1.25 * ffem / fem,
                        letterSpacing: -0.7 * fem,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 14 * fem),
                    Text(
                      'Bring your celebrations to life with talent that ensures every moment is one to remember.',
                      textAlign: TextAlign.center,
                      style: SafeGoogleFont(
                        'Be Vietnam Pro',
                        fontSize: 17 * ffem,
                        fontWeight: FontWeight.w400,
                        height: 1.5 * ffem / fem,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.33), // Reduced spacing to accommodate bottom text
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          width: double.infinity, // Full width container
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12 * fem), // Match the button radius
                            gradient: LinearGradient(
                              colors: [Color(0xffe5195e), Color(0xffc2185b)], // Define your gradient colors here
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              saveSelectedValue('hire');
                              // navigateToNextPage(ServiceCheckerPage());
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceCheckerPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // Set background to transparent
                              shadowColor: Colors.transparent, // Remove shadow if desired
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
                                'Get Started',
                                style: SafeGoogleFont(
                                  'Be Vietnam Pro',
                                  fontSize: 16 * ffem,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5 * ffem / fem,
                                  letterSpacing: 0.24 * fem,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                    ),
                    SizedBox(height: screenHeight * 0.01), // Reduced space before "or"
                    // "or" text
                    Text(
                      'or',
                      textAlign: TextAlign.center,
                      style: SafeGoogleFont(
                        'Be Vietnam Pro',
                        fontSize: 16 * ffem,
                        fontWeight: FontWeight.w400,
                        height: 1.4 * ffem / fem,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01), // Space after "or"
                    // Bottom navigation options
                    Padding(
                      padding: EdgeInsets.only(
                        left: 25 * fem,
                        right: 25 * fem,
                        bottom: 30 * fem, // Padding from bottom
                      ),
                      child: Column(
                        children: [

                          // Register as solo artist
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scene1(), // Replace with your solo artist page
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8 * fem),
                              child: Text(
                                'Register/login as artist',
                                textAlign: TextAlign.center,
                                style: SafeGoogleFont(
                                  'Be Vietnam Pro',
                                  fontSize: 16 * ffem,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4 * ffem / fem,
                                  color: Colors.blue.withOpacity(0.8),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white.withOpacity(0.6),
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
            ),
          ),
        ],
      ),
    );
  }
}