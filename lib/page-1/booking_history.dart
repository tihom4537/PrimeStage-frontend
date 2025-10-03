import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';
import '../utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class booking_history extends StatefulWidget {
  late String  artist_id;
  booking_history( {required this.artist_id});
  @override
  _booking_historyState createState() => _booking_historyState();
}

class _booking_historyState extends State<booking_history>{

  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  late List<String> feedback;
  // bool isLoading = false;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadBookings(widget.artist_id); // Fetch profile data when screen initializes
  }

  Future<String?> _getTeamid() async {
    return await storage.read(key: 'team_id'); // Assuming you stored the token with key 'id'
  }

  Future<String?> _getKind() async {
    return await storage.read(key: 'selected_value'); // Assuming you stored the token with key 'selected_value'
  }


  Future<void> _loadBookings(String artist_id) async {

    // String? id = await _getArtist_id();
    String? team_id= await _getTeamid();
    String? kind = await _getKind();

    String apiUrl;
    if (kind=='solo_artist'){
      apiUrl='${Config().apiDomain}/artist/bookings/completed/$artist_id';
    }else{
    apiUrl='${Config().apiDomain}/team/bookings/completed/$team_id';
    }
    print(apiUrl);

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> decodedList = json.decode(response.body);
      bookings = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
      print('bookings are :$bookings ');

//Extract feedback from each booking's reviews
      for (var booking in bookings) {
        List<dynamic> reviews = booking['reviews'];

        // Extract review_text values
        feedback = reviews.map((review) => review['review_text'] as String).toList();

        print('Booking ID: ${booking['id']} Feedback: $feedback');
      }
      // Define the date format for parsing and formatting
      // DateFormat inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'");
      // DateFormat outputDateFormat = DateFormat('yyyy-MM-dd');
      // DateFormat outputTimeFormat = DateFormat('HH:mm:ss');

      // for (var booking in bookings) {
      //   DateTime createdAt = inputFormat.parse(booking['created_at']);
      //   String formattedDate = outputDateFormat.format(createdAt);
      //   String formattedTime = outputTimeFormat.format(createdAt);
      //
      //
      //
      //   print('Booking ID: ${booking['id']}');
      //   print('Created Date: $formattedDate');
      //   print('Created Time: $formattedTime');
      //   print('---');
      // }

      setState(() {
        isLoading = false;
      });
    } else {
      // Handle the error case
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // bookings.sort((a, b) {
    //   DateTime createdAtA = DateTime.parse(a['created_at']);
    //   DateTime createdAtB = DateTime.parse(b['created_at']);
    //   return createdAtB.compareTo(createdAtA); // Descending order
    // });

    return Scaffold(
      backgroundColor: Color(0xFF121217),
      appBar: AppBar(
        backgroundColor: Color(0xFF121217),
        title: Text(
          'Booking History',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : bookings.isEmpty

          ? Center(
        child: Text(
          'No Booking Event Completed Yet ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      )
           :ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildRequestCard(
            booking['category'],
            booking['booking_date'],
            booking['average_rating'],
            booking['reviews'].map<String>((review) => review['review_text'] as String).toList(),
            // "booking['booked_from']",
            10,
            11,
            10,

          );
        },
      ),
    );
  }
  Widget _buildRequestCard(
      String category, String bookingDate, var rating, List<String> review, int user_id,int artist_id, int index) {
    // final booking = bookings[index];
    // final status = booking['status'];

    return GestureDetector(
      // onTap: () {
      //   print('booking_id : $booking_id');
      //   String bookingId = booking_id.toString();
      //   String artistId =artist_id.toString();
      //   print(index);
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => EventDetails(bookingId: bookingId,artistId: artistId)),
      //   );
      // },
      child: Stack(
        children: [
          Card(
            margin: EdgeInsets.only(bottom: 16),
            color: Color(0xFF292938),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.black54,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 30, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Completed for the  $category',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Booking Date: $bookingDate',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF9494C7),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'feedback: $review',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF9494C7),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Text(
                  //   'Rating by the Host: $rating',
                  //   style: GoogleFonts.epilogue(
                  //     fontWeight: FontWeight.w400,
                  //     fontSize: 14,
                  //     height: 1.5,
                  //     color: Color(0xFF9494C7),
                  //   ),
                  // ),

                      ],
                    )

            ),
              ),
            ],
          ),

    );
  }

}

