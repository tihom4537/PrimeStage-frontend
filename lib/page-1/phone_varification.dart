import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1/page-1/otp_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;  // Import for HTTP requests
import 'dart:convert';

import '../config.dart'; // For JSON encoding/decoding

class PhoneNumberInputScreen extends StatefulWidget {
  String?  artist_id;
  String? isteam;
  late  List<Map<String, dynamic>> selectedItems;
  late  List<Map<String, dynamic>> selectedkits;
  PhoneNumberInputScreen({ this.artist_id , this.isteam, this.selectedItems = const [], this.selectedkits= const[]});
  @override
  _PhoneNumberInputScreenState createState() => _PhoneNumberInputScreenState();
}

class _PhoneNumberInputScreenState extends State<PhoneNumberInputScreen> {
  bool isChecked = false;
  final _phoneController = TextEditingController(text: '+91 ');
  final storage = FlutterSecureStorage();

  // Function to send phone number to backend for Twilio OTP
  void _sendPhoneNumberToBackend() async {
    String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.startsWith('+91')) {
      phoneNumber = phoneNumber.substring(3).trim();
    }
    print(phoneNumber);

    // Prepare the API request
    final url = '${Config().apiDomain}/sms'; // Update this with your backend URL
    final body = json.encode({
      'numbers': phoneNumber,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print(response.statusCode);
      print(response.body);

      // Handle the response
      if (response.statusCode == 200) {
        // Navigate to OTP input screen if successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationCodeInputScreen(
              artist_id: widget.artist_id,
              isteam: widget.isteam,
              selectedItems: widget.selectedItems,
              selectedkits: widget.selectedkits,
              // phoneNumber: phoneNumber, // Pass phone number to OTP screen
            ),
          ),
        );
      } else {
        // Parse error message from response
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        final details = responseBody['details'];

        // Get the detailed message if available
        final detailedMessage = details != null ? details['message'] : null;

        // Show either the detailed message or the main message
        _showSnackBar('Error: ${detailedMessage ?? errorMessage}');
      }
    } catch (e) {
      print(e);
      _showSnackBar('Something went wrong: $e');
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFF121217),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 88, 0, 6.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 35,
                margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Text(
                  'Enter your mobile number',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                    letterSpacing: -0.7,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(18.7, 15, 18.7, 12),
                child: Text(
                  "We'll send you a code to verify your number.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
// // <<<<<<< HEAD
//             ),
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 children: [
//                   Checkbox(
//                     value: isChecked,
//                     onChanged: (value) {
//                       setState(() {
//                         isChecked = value ?? false;
//                       });
//                     },
//                     activeColor: Color(0xFF2B8AE8),
//                     checkColor: Colors.white,
//                   ),
//                   Expanded(
//                     child: RichText(
//                       text: TextSpan(
//                         text: 'You agree to our ',
//                         style: GoogleFonts.beVietnamPro(
//                           fontWeight: FontWeight.w300,
//                           fontSize: 16.5,
//                           height: 1.5,
//                           color: Colors.white,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: 'privacy policy',
//                             style: GoogleFonts.beVietnamPro(
//                               color: Colors.blue,
//                               fontStyle: FontStyle.italic,
//                             ),
//                             recognizer: TapGestureRecognizer()..onTap = () => PrivacyPolicyPage(),
//
//                           ),
//                           TextSpan(
//                             text: ' and ',
//                             style: GoogleFonts.beVietnamPro(
//                               fontWeight: FontWeight.w300,
//                               fontSize: 16.5,
//                               height: 1.5,
//                               color: Colors.white,
//                             ),
//                           ),
//                           TextSpan(
//                             text: 'terms and conditions',
//                             style: GoogleFonts.beVietnamPro(
//                               color: Colors.blue,
//                               fontStyle: FontStyle.italic,
//                             ),
//                             recognizer: TapGestureRecognizer()..onTap = () => PrivacyPolicyPage(),
//                           ),
//                         ],
// // =======
              Container(height: 55,
                margin: EdgeInsets.fromLTRB(16, 0, 16, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: Color(0xFF292938),
                ),

                child: TextField(
                  controller: _phoneController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    // Remove the default border to show the customized one
                    border: InputBorder.none,
                    hintText: 'Mobile number',
                    hintStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF637587),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF637587), // Border color when not focused
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFFE0E0E0), // Border color when focused
                        width: 1.5,
// <<<<<<< HEAD
// // >>>>>>> 9e3f3a1ad3317a5838219c59acad554d7748e289
// =======
// // // >>>>>>> 9e3f3a1ad3317a5838219c59acad554d7748e289
// >>>>>>> 3aa9a5af385f0477afcbf9c7282fe90ba960e750
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    if (!value.startsWith('+91 ')) {
                      _phoneController.text = '+91 ';
                      _phoneController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _phoneController.text.length),
                      );
                    }
                  },
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value ?? false;
                        });
                      },
                      activeColor: Color(0xFF2B8AE8),
                      checkColor: Colors.white,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'You agree to our ',
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w300,
                            fontSize: 16.5,
                            height: 1.5,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: 'privacy policy',
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.blue,
                                fontStyle: FontStyle.italic,
                              ),
                              recognizer: TapGestureRecognizer()

                                ..onTap = () => _navigateToPrivacyPolicy(context),
// >>>>>>> 3aa9a5af385f0477afcbf9c7282fe90ba960e750
                            ),
                            TextSpan(
                              text: ' and ',
                              style: GoogleFonts.beVietnamPro(
                                fontWeight: FontWeight.w300,
                                fontSize: 16.5,
                                height: 1.5,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'terms and conditions',
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.blue,
                                fontStyle: FontStyle.italic,
                              ),
                              recognizer: TapGestureRecognizer()

                                ..onTap = () => _navigateToTermsConditions(context),
                              // ..onTap = _navigateToTermsConditions ,

                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(16, 20, 15.8, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: isChecked
                              ? LinearGradient(
                            colors: [Color(0xffe5195e), Color(0xffc2185b)], // Gradient colors when checked
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null, // No gradient when unchecked
                          color: isChecked ? null : Color(0xFF637587), // Grey background when unchecked
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // Transparent to show container's color/gradient
                            shadowColor: Colors.transparent, // No shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: isChecked
                              ? () async {
                            await storage.write(key: 'phone_number', value: _phoneController.text);

                            _sendPhoneNumberToBackend(); // Send phone number to backendUrl
                          }
                              : null, // Disabled when unchecked
                          child: Text(
                            'Send OTP',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.5,
                              letterSpacing: 0.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 390,
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _navigateToPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
    );
  }
  void _navigateToTermsConditions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsConditionsScreen()),
    );
  }



}




// class _navigateToTermsConditions {
// }

// Create separate pages for Privacy Policy and Terms & Conditions


class PrivacyPolicyScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('Privacy Policy',style: TextStyle(color: Colors.black),)),
      body: SingleChildScrollView(
        child: Center(child: Text('''1. Introduction
PRIMESTAGE LIVE PVT LMT (hereinafter referred to as "we," "our," or "us") operates an online platform through a mobile application that connects users with artists for private, corporate, and public events. This Privacy Policy outlines how we collect, use, disclose, and safeguard your information when you use our app.

By using our app, you consent to the practices described in this policy.

2. Information We Collect
We may collect and process the following categories of personal data from you:

Personal Identification Information: Name, phone number, email address, physical address, and location.
Financial Information: For artists, we collect bank account details to facilitate payment transfers.
Event Details: Information related to your booking preferences, such as the event date, location, and artist selection.
Device Information: Data related to the device you use to access our app (e.g., IP address, browser type, device ID).
Cookies: We use cookies and similar tracking technologies to personalize advertisements, analyze user behavior, and offer tailored services. You can manage cookie preferences through your device settings.
3. Use of Information
We use the collected data for the following purposes:

To provide services: This includes processing bookings, managing user accounts, and communicating with you regarding your bookings and inquiries.
For payment processing: Artists' financial information is used solely for transferring payments. We do not store or access your financial data except as required for the transfer.
To improve user experience: Your data helps us optimize our app, offer tailored recommendations, and improve service quality.
For marketing purposes: We may use your data to show advertisements based on your interests and preferences. This includes both in-app advertisements and external advertising channels.
To comply with legal obligations: We may use your information to meet legal or regulatory requirements.
4. Cookies and Tracking Technologies
We use cookies to:

Track user activity within the app to analyze usage patterns.
Personalize and enhance your experience by delivering tailored advertisements.
Store preferences, such as language settings, and assist with login and authentication.
You can opt-out of personalized ads or tracking by adjusting your device or browser settings. However, doing so may limit certain functionalities of the app.

5. Third-Party Services
We utilize third-party services in some areas, particularly for payment processing and advertisement delivery. These services include but are not limited to:

Payment Gateways: Your financial information may be shared with secure payment processors for completing transactions.
Analytics and Advertising: We use third-party analytics tools to track user behavior and offer personalized advertising. These tools collect information about your device, app usage, and engagement metrics.
We ensure that these third-party service providers comply with applicable data protection laws and protect your personal information.

6. Data Sharing and Disclosure
Your personal data is not shared, sold, or disclosed to any unauthorized third party. We only share information in the following circumstances:

With your consent: We will seek your permission before sharing your personal data for any purpose not outlined in this policy.
Service Providers: Trusted partners involved in app operations (e.g., payment gateways, analytics providers) may access data solely to perform tasks on our behalf.
Legal Compliance: If required by law, regulation, or government request, we may disclose your data.
7. Data Security
We take appropriate security measures to protect your personal data from unauthorized access, misuse, alteration, or destruction. This includes:

Encryption of sensitive data such as financial information.
Limiting access to personal data only to employees, contractors, and third-party service providers who need access to perform their duties.
Despite our efforts, no security system is impenetrable, and we cannot guarantee the complete security of your data. However, we regularly review and update our security protocols to mitigate risks.

8. Data Retention
We retain your personal data for as long as necessary to fulfill the purposes outlined in this policy, unless a longer retention period is required by law. Once your data is no longer needed, we securely delete or anonymize it.

9. User Rights
You have the following rights regarding your personal data:

Right to Access: You can request details of the personal data we hold about you.
Right to Rectification: You can update or correct your personal information.
Right to Deletion: You may request the deletion of your personal data, subject to legal and contractual restrictions.
Right to Object to Processing: You can object to certain data processing activities, such as direct marketing.
To exercise any of these rights, please contact us at [Contact Email].

10. In-App Advertisements
We may show in-app advertisements in the future. These ads will be based on your interests and activity within the app. We use anonymized data for ad targeting and do not share any personally identifiable information with advertisers.

You may opt out of receiving personalized ads through your app settings or by contacting us.

11. Changes to the Privacy Policy
We reserve the right to update or modify this Privacy Policy at any time. If we make significant changes, we will notify you via email or in-app notifications.

12. Contact Us
If you have any questions or concerns about this Privacy Policy or how we handle your data, please contact us at:

Email: [support@primestage.in]
Address: [Salogara, Solan Himachal Pradesh 173212]
''',
        )),
      ),
    );

  }
}

class TermsConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('Terms and Conditions',style: TextStyle(color: Colors.black),)),
      body: SingleChildScrollView(
        child: Center(child: Text('''1. Introduction
Welcome to PRIMESTAGE LIVE PVT LMT. By using our app, you agree to these Terms and Conditions. Please read them carefully before using our services. If you do not agree with any part of these terms, you must not use our app.

These Terms and Conditions govern your access to and use of our app, which provides a platform for users to book artists for private, corporate, and public events.

2. Definitions
"App" refers to [App Name], including the website, mobile application, and associated services.
"User" refers to any individual using the app, including event organizers and artists.
"Artist" refers to performers or entertainers listed on our platform available for booking.
"Booking" refers to a confirmed agreement between a user and an artist for services to be rendered at an event.
3. Use of the Platform
Eligibility: You must be at least 8 years old to use our app. By accessing the app, you confirm that you are of legal age to form a binding contract.
Account Responsibility: You are responsible for maintaining the confidentiality of your login credentials and ensuring all information provided is accurate and up to date.
4. Artist Listings and Bookings
Artist Profiles: Artists provide information such as their names, contact details, and performance descriptions. We do not guarantee the accuracy or completeness of this information.
Bookings: Users are responsible for ensuring the event details are correct before confirming a booking. Once a booking is confirmed, a binding contract is formed between the user and the artist. We are not a party to this contract.
5. User and Artist Conduct
Behavioral Standards: All users and artists are expected to behave professionally and respectfully during their interactions, including communication and live events. We do not take responsibility for any inappropriate, unlawful, or unprofessional behavior of either party.
Disputes: Any disputes between users and artists must be resolved between the respective parties. We may assist in resolving disputes but are not legally responsible for outcomes.
6. Payments and Fees
Payment Process: Payments for artist bookings are processed via third-party payment gateways. By making a booking, you agree to pay the agreed-upon fees.
Refunds and Cancellations: Cancellation policies and refund eligibility vary depending on the artist and the specific booking. Users are responsible for reading and understanding the artist’s cancellation terms before booking.
7. Third-Party Services
Payment Gateways and Advertisements: We use third-party services for payment processing and advertisement delivery. We are not responsible for the performance or security of these third-party services.
Links to External Sites: Our app may contain links to external websites or services not operated by us. We are not responsible for the content, policies, or practices of any third-party services.
8. Liability Disclaimer
No Guarantees: We provide the platform on an "as-is" basis and make no warranties, express or implied, regarding the availability, accuracy, or reliability of the services provided by artists or the app itself.
Limited Liability: To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, or consequential damages arising from your use of the app, including, but not limited to, disputes between users and artists, loss of revenue, or harm caused by an artist or user.
9. Disclaimers Regarding User and Artist Behavior
No Liability for Behavior: We are not responsible for the behavior, actions, or omissions of users or artists. This includes, but is not limited to, inappropriate conduct, cancellations, failure to perform, or other disruptions at events.
Background Checks: We do not conduct background checks on artists or users. You are responsible for performing your own due diligence when booking or engaging with any individual on the platform.
10. Intellectual Property Rights
Ownership: All content and materials on the app, including logos, design, and text, are our intellectual property and may not be used without prior written permission.
User-Generated Content: Any content provided by users (e.g., reviews or feedback) remains the property of the user, but by submitting it to our app, you grant us a non-exclusive, royalty-free license to use, display, and distribute the content.
11. Termination of Accounts
We reserve the right to terminate or suspend your account at our sole discretion if you violate any terms of this agreement or engage in unlawful or inappropriate behavior on the platform.

12. Amendments to Terms and Conditions
We reserve the right to update or modify these Terms and Conditions at any time. If changes are made, we will notify users via email or app notifications. Continued use of the app following such changes will constitute acceptance of the new terms.

13. Governing Law and Jurisdiction
These Terms and Conditions are governed by and construed in accordance with the laws of India. Any disputes arising out of or in connection with these terms shall be subject to the exclusive jurisdiction of the courts in [Your City, India].

14. Contact Information
If you have any questions about these Terms and Conditions, please contact us at:

Email: [support@primestage.in]
Address: [salogara solan himachal pradesh 173212 ]'''
        )),
      ),

    );
  }
}
