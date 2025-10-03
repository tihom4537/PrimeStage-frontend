import 'package:flutter/material.dart';
import '../utils.dart';

class artist_inbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
      body: SafeArea(
      child: Container(
        width: double.infinity,
        child: Container(
          width: double.infinity,
          height: 744*fem,
          decoration: BoxDecoration (
            color: Color(0xffffffff),
          ),
          child: Container(
            // depth0frame0P6o (20:3000)
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration (
              color: Color(0xfffcfcfc),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  // depth1frame0hdH (20:3001)
                  padding: EdgeInsets.fromLTRB(16*fem, 12*fem, 16*fem, 8*fem),
                  width: double.infinity,
                  decoration: BoxDecoration (
                    color: Color(0xfffcfcfc),
                  ),
                  child: Center(
                    child: Text(
                      'Inbox',
                      style: SafeGoogleFont (
                        'Be Vietnam Pro',
                        fontSize: 28*ffem,
                        fontWeight: FontWeight.w700,
                        height: 1.25*ffem/fem,
                        letterSpacing: -0.6999999881*fem,
                        color: Color(0xff1c0c11),
                      ),
                    ),
                  ),
                ),
                Container(
                  // depth2frame0mt3 (20:3012)
                  margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 12*fem),
                  padding: EdgeInsets.fromLTRB(15.58*fem, 0*fem, 3.88*fem, 0*fem),
                  width: double.infinity,
                  height: 54*fem,
                  decoration: BoxDecoration (
                    border: Border.all(color: Color(0xffe8d1d6)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // depth3frame0sAP (20:3013)
                        margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 0*fem),
                        width: 136*fem,
                        height: 53*fem,

                        child: Center(
                          child: Text(
                            'All Messages',
                            textAlign: TextAlign.center,
                            style: SafeGoogleFont (
                              'Be Vietnam Pro',
                              fontSize: 14*ffem,
                              fontWeight: FontWeight.w700,
                              height: 1.5*ffem/fem,
                              letterSpacing: 0.2099999934*fem,
                              color: Color(0xff1c0c11),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                Container(
                  // depth1frame21vo (20:3021)
                  padding: EdgeInsets.fromLTRB(16*fem, 8*fem, 16*fem, 8*fem),
                  width: double.infinity,
                  height: 72*fem,
                  decoration: BoxDecoration (
                    color: Color(0xfffcfcfc),
                  ),
                  child: Container(
                    // depth2frame048P (20:3022)
                    width: 245.03*fem,
                    height: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // depth3frame0zGw (20:3023)
                          margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 16*fem, 0*fem),
                          width: 56*fem,
                          height: 56*fem,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28*fem),
                            child: Image.asset(
                              'assets/page-1/images/depth-3-frame-0-rwy.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          // depth3frame2VzP (20:3024)
                          margin: EdgeInsets.fromLTRB(0*fem, 5.5*fem, 0*fem, 5.5*fem),
                          width: 173.03*fem,
                          height: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // depth4frame0q2f (20:3025)
                                width: 100*fem,
                                height: 24*fem,
                                child: Center(
                                  child: Text(
                                    'Artista team',
                                    style: SafeGoogleFont (
                                      'Be Vietnam Pro',
                                      fontSize: 16*ffem,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5*ffem/fem,
                                      color: Color(0xff1c0c11),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                // depth4frame1jtj (20:3028)
                                margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0.03*fem, 0*fem),
                                width: double.infinity,
                                height: 21*fem,
                                child: Center(
                                  child: Text(
                                    'New booking for your art!',
                                    style: SafeGoogleFont (
                                      'Be Vietnam Pro',
                                      fontSize: 14*ffem,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5*ffem/fem,
                                      color: Color(0xff964f66),
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
                Container(
                  // depth1frame3qRy (20:3031)
                  padding: EdgeInsets.fromLTRB(16*fem, 8*fem, 16*fem, 8*fem),
                  width: double.infinity,
                  height: 82*fem,
                  decoration: BoxDecoration (
                    color: Color(0xfffcfcfc),
                  ),
                  child: Container(
                    // depth2frame0koq (20:3032)
                    width: double.infinity,
                    height: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // depth3frame0uRq (20:3033)
                          margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 16*fem, 0*fem),
                          width: 56*fem,
                          height: 56*fem,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28*fem),
                            child: Image.asset(
                              'assets/page-1/images/depth-3-frame-0-Squ.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          // depth3frame2Cvj (20:3034)
                          width: 286*fem,
                          height: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // depth4frame0khM (20:3035)
                                width: 83*fem,
                                height: 24*fem,
                                child: Center(
                                  child: Text(
                                    'Kaitlyn Liu',
                                    style: SafeGoogleFont (
                                      'Be Vietnam Pro',
                                      fontSize: 16*ffem,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5*ffem/fem,
                                      color: Color(0xff1c0c11),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                // depth4frame1sGB (20:3038)
                                width: 256*fem,
                                height: 42*fem,
                                child: Center(
                                  // yourartisamazingwewouldlovetof (20:3040)
                                  child: SizedBox(
                                    child: Container(
                                      constraints: BoxConstraints (
                                        maxWidth: 256*fem,
                                      ),
                                      child: Text(
                                        'Your art is amazing! We would love to feature it.',
                                        style: SafeGoogleFont (
                                          'Be Vietnam Pro',
                                          fontSize: 14*ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5*ffem/fem,
                                          color: Color(0xff964f66),
                                        ),
                                      ),
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
                Container(
                  // depth1frame4iXh (20:3041)
                  padding: EdgeInsets.fromLTRB(16*fem, 8*fem, 16*fem, 8*fem),
                  width: double.infinity,
                  height: 82*fem,
                  decoration: BoxDecoration (
                    color: Color(0xfffcfcfc),
                  ),
                  child: Container(
                    // depth2frame045m (20:3042)
                    width: double.infinity,
                    height: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // depth3frame0p4w (20:3043)
                          margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 16*fem, 0*fem),
                          width: 56*fem,
                          height: 56*fem,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28*fem),
                            child: Image.asset(
                              'assets/page-1/images/depth-3-frame-0-QqM.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          // depth3frame2iw1 (20:3044)
                          width: 286*fem,
                          height: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // depth4frame05Wf (20:3045)
                                width: 96*fem,
                                height: 24*fem,
                                child: Center(
                                  child: Text(
                                    'Olivia Smith',
                                    style: SafeGoogleFont (
                                      'Be Vietnam Pro',
                                      fontSize: 16*ffem,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5*ffem/fem,
                                      color: Color(0xff1c0c11),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                // depth4frame1oBm (20:3048)
                                width: 263*fem,
                                height: 42*fem,
                                child: Center(
                                  // iminterestedinbuyingthispiecec (20:3050)
                                  child: SizedBox(
                                    child: Container(
                                      constraints: BoxConstraints (
                                        maxWidth: 263*fem,
                                      ),
                                      child: Text(
                                        'I\'m interested in buying this piece. Can you tell me more?',
                                        style: SafeGoogleFont (
                                          'Be Vietnam Pro',
                                          fontSize: 14*ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5*ffem/fem,
                                          color: Color(0xff964f66),
                                        ),
                                      ),
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
                Container(
                  // depth1frame5qeF (20:3051)
                  margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 260*fem),
                  padding: EdgeInsets.fromLTRB(16*fem, 8*fem, 31.48*fem, 8*fem),
                  width: double.infinity,
                  height: 72*fem,
                  decoration: BoxDecoration (
                    color: Color(0xfffcfcfc),
                  ),
                  child: Container(
                    // depth2frame0whH (20:3052)
                    width: double.infinity,
                    height: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // depth3frame0Hm9 (20:3053)
                          margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 16*fem, 0*fem),
                          width: 56*fem,
                          height: 56*fem,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28*fem),
                            child: Image.asset(
                              'assets/page-1/images/depth-3-frame-0-gEs.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          // depth3frame2CNK (20:3054)
                          margin: EdgeInsets.fromLTRB(0*fem, 5.5*fem, 0*fem, 5.5*fem),
                          width: 270.52*fem,
                          height: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // depth4frame0815 (20:3055)
                                width: 115*fem,
                                height: 24*fem,
                                child: Center(
                                  child: Text(
                                    'Ethan Johnson',
                                    style: SafeGoogleFont (
                                      'Be Vietnam Pro',
                                      fontSize: 16*ffem,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5*ffem/fem,
                                      color: Color(0xff1c0c11),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                // depth4frame12cF (20:3058)
                                width: double.infinity,
                                height: 21*fem,
                                child: Center(
                                  child: Text(
                                    'Can I commission a painting of my dog?',
                                    style: SafeGoogleFont (
                                      'Be Vietnam Pro',
                                      fontSize: 14*ffem,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5*ffem/fem,
                                      color: Color(0xff964f66),
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

              ],
            ),
          ),
        ),
            ),
    ),);
  }
}