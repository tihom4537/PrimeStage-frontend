import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios, // iOS-style back arrow icon
            color: Color(0xFF21160C), // Match your color theme
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: Text(
          'Support',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontSize: 22,
            fontWeight: FontWeight.w500,
            height: 1.25,
            letterSpacing: -0.8,
            color: Color(0xFF21160C),
          ),
        ),
        centerTitle: true, // Ensures the title stays centered
        backgroundColor: Colors.white, // Optional: Set a background color
        elevation: 0, // Optional: Remove shadow for a flat design
      ),

      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'How may we help you?',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: Color(0xFF0D141C),
                  ),
                ),
              ),
              SizedBox(height: 12),
              _buildSupportOption(
                title: 'Call Us: 9588179288 / 8538948208',
              ),
              _buildSupportOption(
                title: 'Email us: support@primestage.in',
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  'FAQs',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: Color(0xFF0D141C),
                  ),
                ),
              ),
              _buildFaqItem(
                question: 'What is your refund policy?',
                answer:
                'Our refund policy allows for a full refund if the booking is canceled more than 36 hours before the performance. If the booking is canceled between 36 and 24 hours before the performance, 70% will be refunded, and if canceled between 24 and 12 hours before the performance, 50% will be refunded. Taxes will not be refunded at any time of cancellation.You will be eligible for complete refund including taxes if the request is cancelled by the artist.In this case if user want we will find a suitable replacement if the user will be ok with it so that the event can go flawless',),
              _buildFaqItem(
                question: 'Will the artist perform on requested songs?',
                answer:
                'Yes, the artist will perform requested songs, provided that the requests are communicated in advance or the artist is familiar with the songs given at the event. However, the final setlist will be at the artist’s discretion based on what best suits the performance and the event’s atmosphere.',
              ),
        _buildFaqItem(
          question: 'Who will ensure that the artist and sound system arrive on time?',
          answer:'We will provide a dedicated event manager for every event, who will ensure that everything, including the artist and sound system, goes as planned.',),
        _buildFaqItem(
          question: ' Is the traveling fee of the artist included in their hourly price?',
          answer:'Most of the artists you will find in this app are from your city, and their traveling fees are included in the hourly price. However, in rare cases where the artist is not from your city, any additional travel charges will be discussed with you.',),
              _buildFaqItem(
                question: 'Can the performance time be extended during the event?',
                answer:
                'Increasing the performance time during the event may be possible, depending on the artist’s availability and agreement, but this may result in additional charges other than the hourly charges of artist. So, we suggest that you edit the duration on the app before the onset of the event to ensure everything is arranged smoothly.',
              ),
              _buildFaqItem(question: 'What if the artist does not arrive on time?',
                  answer: 'We always make sure that the artist arrives on time, and punctuality is our priority. However, a small variation in arrival time may occur due to unforeseen circumstances like weather or traffic, though this is very rare. If the artist is more than 40-50 minutes late, we will refund the cost of one hour of the performance, and appropriate action will be taken against the artist. Your satisfaction is our topmost priority'),
              _buildFaqItem(
                question: 'What if the artist cancels the request at the last moment?',
                answer: 'The artist will respond to your request within a few hours. In the rare event that the artist cancels the request at the last moment, we will make every effort to'
                    ' find a suitable replacement which will be discussed with you well in advance. If a replacement cannot be arranged, you will be eligible for a full refund including taxes. While mishaps are not anticipated '
                    'as artists are expected to arrive on their own, we understand the inconvenience this may cause and will prioritize finding a resolution as quickly as possible.'
                    ' Your satisfaction and the success of your event are our top priorities.',),
              _buildFaqItem(
                question: 'Where I can discuss the event details with the artists or chefs?',
                answer: 'You will be provided the phone no once the booking is made. You can provide'
                    ' the special requests in the section provided in the booking page.',),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportOption({required String title}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF0D141C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF0D141C),
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              answer,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF0D141C),
              ),
            ),
          ),
        ],
        tilePadding: EdgeInsets.all(0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        backgroundColor: Color(0xFFF7FAFC),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }
}