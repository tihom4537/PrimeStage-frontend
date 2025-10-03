import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import 'booked_artist.dart';
import 'booking_details.dart';

class AllBookings extends StatefulWidget {
  final String? newBookingTitle;
  final String? newBookingDateTime;



  AllBookings({this.newBookingTitle, this.newBookingDateTime, required Map<String, dynamic> data});

  @override
  _AllBookingsState createState() => _AllBookingsState();
}

class _AllBookingsState extends State<AllBookings> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  final storage = FlutterSecureStorage();
  late final String bookingId;
  String? user_phonenumber;

  DateFormat inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'");
  DateFormat outputDateFormat = DateFormat('yyyy-MM-dd');
  DateFormat outputTimeFormat = DateFormat('HH:mm:ss');



  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _makePhoneCall(String phoneNumber) async {
    // Remove any spaces and special characters
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Remove country code (91) if it exists
    if (phoneNumber.startsWith('91')) {
      phoneNumber = phoneNumber.substring(2); // Remove the first two characters
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );



    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri'; // Log the actual URI
    }
  }

  Future<String?> _getid() async {
    return await storage.read(key: 'artist_id'); // Assuming you stored the token with key 'id'
  }

  Future<String?> _getTeamid() async {
    return await storage.read(key: 'team_id'); // Assuming you stored the token with key 'id'
  }

  Future<String?> _getKind() async {
    return await storage.read(key: 'selected_value'); // Assuming you stored the token with key 'selected_value'
  }

  Future<void> _loadBookings() async {
    String? id = await _getid();
    String? team_id= await _getTeamid();
    String? kind = await _getKind();

    // String? id = await _getArtist_id();

    String apiUrl;
    if(kind =='solo_artist') {
      apiUrl='${Config().apiDomain}/artist/bookings/$id';

    }else{
      apiUrl='${Config().apiDomain}/team/bookings/$team_id';
    }
    print(apiUrl);

    final response = await http.get(
        Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List<dynamic> decodedList = json.decode(response.body);
      bookings = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
      // Define the date format for parsing and formatting
      print(decodedList);

      for (var booking in bookings) {
        DateTime createdAt = inputFormat.parse(booking['created_at']);
        String formattedDate = outputDateFormat.format(createdAt);
        String formattedTime = outputTimeFormat.format(createdAt);

      }

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

  Future <void> fetchUser(BuildContext context,int user_id,bool status) async{
    // Initialize API URLs for different kinds
    print(user_id);
    String? user_fcmToken;

    String apiUrl = '${Config().apiDomain}/info/$user_id';

    try {
      var uri = Uri.parse(apiUrl);
      var response = await http.get(
        uri,
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        // body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('user fetched successfully: ${response.body}');
        Map<String, dynamic> user= json.decode(response.body);


        user_fcmToken=user['fcm_token'];
        user_phonenumber=user['phone_number'];
        sendNotification( context,  user_fcmToken!,status);



      } else {
        print('user fetch unsuccessful Status code: ${response.body}');

      }
    } catch (e) {
      print('Error sending notification: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Notification has been sent to the artist'),
      //     backgroundColor: Colors.green,
      //   ),
      // );
    }

  }


  Future<void> sendNotification(BuildContext context, String fcm_token,bool status ) async {
    // Initialize API URLs for different kinds
    String apiUrl = '${Config().apiDomain}/send-notification_user';

    Map<String, dynamic> requestBody = {
      'type':'user',
      'user_fcmToken':fcm_token,
      'status':status,
    };

    try {
      var uri = Uri.parse(apiUrl);
      var response = await http.post(
        uri,
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        // Show snackbar on successful notification send
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification has been sent to the user'),
            backgroundColor: Colors.green,
          ),
        );
        print('notification sent successfully: ${response.body}');
      } else {
        print('Failed to send notification. Status code: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification unsuccessfull'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error sending notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error sending Notification  to the user'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }




  Widget _buildRequestCard(
      String category, String bookingDate, String BookingTime, int booking_id, int user_id,int artist_id, String duration,String phone_number,int index) {
    final booking = bookings[index];
    final status = booking['status'];

    return GestureDetector(
      onTap: () {
        print('booking_id : $booking_id');
        String bookingId = booking_id.toString();
        String artistId =artist_id.toString();
        print(index);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventDetails(bookingId: bookingId,artistId: artistId)),
        );
      },
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
                    'You have got Booking for $category',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.5,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Booking Date: $bookingDate',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF9494C7),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Booked From: $BookingTime',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF9494C7),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Duration: 2- 2.5 hours',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF9494C7),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (status == 0) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _rejectBooking(booking_id,2);
                              fetchUser(context, user_id, false);
                              setState(() {
                                booking['status'] = 2; // Mark as rejected
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(0xFF121217),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 9.5),
                            ),
                            child: Text(
                              'Reject',
                              style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _acceptBooking(booking_id);
                              fetchUser(context, user_id, true);
                              setState(() {
                                booking['status'] = 1; // Mark as accepted
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 9.5),
                              side: BorderSide(
                                color: Colors.black, // Set the border color to black
                                width: 2, // You can adjust the width of the border as needed
                              ),
                            ),
                            child: Text(
                              'Accept',
                              style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ] else if (status == 2) ...[
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Booking Rejected',
                                style: GoogleFonts.epilogue(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {
                              _rejectBooking(booking_id,0);
                              setState(() {
                                booking['status'] = 0; // Undo rejection
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 9.5,horizontal:130),
                              side: BorderSide(
                                color: Colors.black, // Set the border color to black
                                width: 2, // You can adjust the width of the border as needed
                              ),
                            ),
                            child: Text(
                              'Undo',
                              style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ] else ...[
                    Column(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            _makePhoneCall(phone_number);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 9.5),
                            side: BorderSide(
                              color: Colors.black, // Set the border color to black
                              width: 2, // You can adjust the width of the border as needed
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Call Event Manager',
                              style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            // Cancel booking logic here
                            _rejectBooking(booking_id,2);

                            setState(() {
                              booking['status'] = 2; // Mark as rejected
                            });
                            fetchUser(context, user_id, false);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.black, // Orange color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 9.5),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel Booking',
                              style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 8,
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    bookings.sort((a, b) {
      DateTime createdAtA = DateTime.parse(a['created_at']);
      DateTime createdAtB = DateTime.parse(b['created_at']);
      return createdAtB.compareTo(createdAtA); // Descending order
    });

    return Scaffold(
      backgroundColor: Color(0xFF121217),
      appBar:  AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: Center(
            child: Text(
              'Bookings',
              style: TextStyle(
                fontSize: 22 ,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xFF121217),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : bookings.isEmpty
          ? Center(
        child: Text(
          'No Booking request found ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final idToUse = booking['artist_id'] ?? booking['team_id'];
          return _buildRequestCard(
            booking['category'],
            booking['booking_date'],
            booking['booked_from'],
            booking['id'],
            booking['user_id'],
            idToUse,
            booking['duration'],
            booking['manager_number'],
            index,
          );
        },
      ),
    );
  }


  void _acceptBooking(int bookingId) async {
    final response = await http.patch(
      Uri.parse('${Config().apiDomain}/booking/$bookingId'),
      headers: <String, String>{
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json',
      },
      body: json.encode({
        'status': 1,
      }),
    );

    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      print(decodedResponse);
      print('Booking updated successfully');
      // _updateBookingstatus(1);

      // Update the status of the booking locally
      setState(() {
        final booking = bookings.firstWhere(
              (b) => b['id'] == bookingId,
          orElse: () => <String, dynamic>{},
        );

        if (booking.isNotEmpty) {
          booking['status'] = 1;
        }
      });

      // Show success dialog
      _showDialog('Success', 'Booking accepted successfully');
    } else {
      // Handle the error case
      print('Failed to update booking: ${response.statusCode}');
      // Show error dialog
      _showDialog('Error', 'Failed to accept booking');
    }
  }


  void _rejectBooking(int bookingId,int status ) async {
    // Your logic to reject the booking

    final response = await http.patch(
      Uri.parse('${Config().apiDomain}/booking/$bookingId'),
      headers: <String, String>{
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json',
        // 'Authorization': 'Bearer $token', // Include the token in the header
      },
      body: json.encode({
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      print(decodedResponse);
      print('Booking updated successfully');
      // _updateBookingstatus(0);
      _showDialog('Success', 'Booking rejected successfully');
      // Optionally, refresh the bookings list or update the UI
    } else {
      // Handle the error case
      print('Failed to update booking: ${response.statusCode}, ${response.body}');
      _showDialog('Error', 'Failed to accept booking');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



}
