import 'package:flutter/material.dart';

class AccountManagementPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      backgroundColor: Color(0xFF121217),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: Text(
            'Legal',
            style: TextStyle(
              fontSize: 22 * fem,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);  // Navigates back to the previous page
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,   // Ensure the icon is visible
          ),
        ),
        backgroundColor: Color(0xFF121217),
      ),

      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Privacy Policy
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPolicyPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.privacy_tip,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      SizedBox(width: 12.0),
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 0.5,
                indent: 16.0, // Matches the padding
                endIndent: 16.0,
              ),

              // Terms and Conditions
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TermsConditionsPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      SizedBox(width: 12.0),
                      Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 0.5,
                indent: 16.0,
                endIndent: 16.0,
              ),

              // Refund Policy
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RefundPolicyPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.money_off,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      SizedBox(width: 12.0),
                      Text(
                        'Refund Policy',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 0.5,
                indent: 16.0,
                endIndent: 16.0,
              ),
            ],
          ),

        ),
      ),
    );
  }

  // Function to build the option tile
  Widget _buildOptionTile(double fem, double ffem, String text, Color textColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 6 * fem, 10 * fem),
      width: double.infinity,
      height: 56 * fem,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 17 * ffem,
                  fontWeight: FontWeight.w400,
                  height: 1.5 * ffem / fem,
                  color: textColor,
                ),
              ),
            ),
          ),
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
    );
  }
}

// Placeholder pages for navigation
class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy',style: TextStyle(fontSize: 19,color: Colors.black),),
      ),
      body: SingleChildScrollView(
        child: Center(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('''
1. Introduction
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
''',style: TextStyle(fontSize: 16),),
        )),
      ),
    );
  }
}

class TermsConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions',style: TextStyle(fontSize:19,color: Colors.black ),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
Address: [salogara solan himachal pradesh 173212 ]
''',style: TextStyle(fontSize: 16),)),
        ),
      ),
    );
  }
}

class RefundPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Refund Policy',style: TextStyle(fontSize: 19,color: Colors.black),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text('''
At PRIMESTAGE LIVE PVT LTD, we value customer satisfaction and aim to ensure a seamless experience for both users and artists. Our refund policy outlines the terms and conditions for canceling a booking and requesting a refund. Please read this policy carefully before making any bookings on our platform.

1. Refund Eligibility
Full Refund: You are eligible for a full refund if the booking is canceled more than 36 hours before the scheduled performance. This includes the full amount of the booking fee, but taxes will not be refunded.

70% Refund: If the booking is canceled between 36 and 24 hours before the performance, 70% of the booking fee will be refunded. Taxes will not be refunded.

50% Refund: If the booking is canceled between 24 and 12 hours before the performance, 50% of the booking fee will be refunded. Taxes will not be refunded.

No Refund: Cancellations made less than 12 hours before the performance will not be eligible for a refund.

Artist Cancellation: If the artist cancels the booking at any time, you are eligible for a complete refund, including taxes.

2. Non-Refundable Taxes
Please note that any applicable taxes charged at the time of booking will not be refunded for user-initiated cancellations, regardless of when the cancellation is made.

3. Payment Processing
Refunds will be processed within 5 business days of the cancellation request.

The refund will be credited to the original payment method used during the booking process.

4. Bank and Payment Gateway Issues
We are not liable for any delays, errors, or issues caused by bank-side errors or payment gateway malfunctions.

If we do not receive the payment or experience errors outside of our control, we cannot process the refund.

5. How to Request a Refund
To cancel a booking and request a refund, please follow these steps:

Step 1: Log in to your account on [App Name].

Step 2: Go to your bookings and select the booking you want to cancel.

Step 3: Follow the on-screen instructions to cancel the booking. The applicable refund amount will be automatically calculated based on the time of cancellation.

6. Changes to Refund Policy
We reserve the right to modify or amend this refund policy at any time. Any changes to the policy will be communicated to users via email or in-app notifications. Continued use of the app after changes to the policy implies acceptance of the updated terms.

7. Contact Information
If you have any questions or concerns about your refund, please contact our customer support team at:

Email: [support@primestage.in]
Phone: [9588179288]''',style: TextStyle(fontSize: 17),)),
        ),
      ),
    );
  }
}
