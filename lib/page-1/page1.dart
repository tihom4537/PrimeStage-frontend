import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test1/page-1/phone_varification.dart';

import 'loc_service_ui.dart';

class Scene1 extends StatefulWidget {
  const Scene1({Key? key}) : super(key: key);

  @override
  _Scene1State createState() => _Scene1State();
}

class _Scene1State extends State<Scene1> {
  late VideoPlayerController _controller;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/page-1/images/6f1ff42d57f59d5c0b032de4753cf734.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0); // Mute the video
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void saveSelectedValue(String value) async {
    await storage.write(key: 'selected_value', value: value);
  }

  Future<void> navigateToNextPage(Widget nextPage) async {
    _controller.pause();
    await Future.delayed(Duration(milliseconds: 300));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fem = screenWidth / 390;
    double ffem = fem * 0.97;

    // Check if in landscape mode
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Stack(
        children: [
          // Video Background
          SizedBox.expand(
            child: _controller.value.isInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
                : Container(
              color: Colors.black,
            ),
          ),

          // Semi-transparent overlay
          Container(
            color: Colors.black.withOpacity(0.6), // Semi-transparent film
          ),

          // Content over the overlay
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 25 * fem),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 30 * fem),
                      child: Text(
                        'Start Your Journey With Us',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: isLandscape ? 24 * ffem : 28 * ffem, // Adjust font size in landscape mode
                          fontWeight: FontWeight.w400,
                          height: 1.25 * ffem / fem,
                          letterSpacing: -0.7 * fem,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Buttons Column
                    Column(
                      children: [
                        // Hire Artist Button


                        SizedBox(height: 26 * fem),

                        // I'm a Solo Artist Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11 * fem),
                            gradient: LinearGradient(
                              colors: [Color(0xffe5195e), Color(0xffc2185b)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              saveSelectedValue('solo_artist');
                              navigateToNextPage(PhoneNumberInputScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11 * fem),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * fem,
                                vertical: 12 * fem,
                              ),
                              minimumSize: Size(double.infinity, 14 * fem),
                            ),
                            child: Text(
                              'I\'m a Solo Artist',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 18 * ffem,
                                fontWeight: FontWeight.w500,
                                height: 1.5 * ffem / fem,
                                letterSpacing: 0.74 * fem,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 25 * fem),

                        // We're a Team of Artists Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11 * fem),
                            gradient: LinearGradient(
                              colors: [Color(0xffe5195e), Color(0xffc2185b)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              saveSelectedValue('team');
                              navigateToNextPage(PhoneNumberInputScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11 * fem),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * fem,
                                vertical: 12 * fem,
                              ),
                              minimumSize: Size(double.infinity, 14 * fem),
                            ),
                            child: Text(
                              'We\'re a Group of Artists',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 18 * ffem,
                                fontWeight: FontWeight.w500,
                                height: 1.5 * ffem / fem,
                                letterSpacing: 0.74 * fem,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isLandscape ? 20 * fem : 92 * fem), // Adjust based on orientation
                      ],
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
