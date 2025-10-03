import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1/page-1/page_0.3_artist_home.dart';

import '../config.dart';

class EventDetails extends StatefulWidget {
  final String bookingId;
  final String  artistId;

  EventDetails({required this.bookingId, required this.artistId});

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  String? location;
  String? Category;
  String? TotalAmount;
  String? SpecialRequest;
  String? BookingDate;
  String? booked_from;
  String? booked_to;
  int? artist_id;
  String? amount;
  String? duration;
  String? user_id;
  String? number ;
  late Future<void> fetchFuture;
  String? audience_size;
  String? user_name;
  String? phone_number;
  String? total_amount;


  @override
  void initState() {
    super.initState();
    fetchFuture = fetchDetails();
    // fetchBookingDetails(
    //     widget.bookingId); // Fetch profile data when screen initializes
    // fetchArtist(widget.artistId);
  }

  Future<String?> _getid() async {
    return await storage.read(
        key: 'artist_id'); // Assuming you stored the token with key 'id'
  }

  Future<String?> _getTeamid() async {
    return await storage.read(
        key: 'team_id'); // Assuming you stored the token with key 'id'
  }

  Future<String?> _getKind() async {
    return await storage.read(
        key: 'selected_value'); // Assuming you stored the token with key 'selected_value'
  }

  Future<void> fetchDetails() async {
    await Future.wait([
      fetchArtist(widget.artistId),
      fetchBookingDetails(widget.bookingId),
    ]);
  }

  Future<void> fetchArtist(String artist_id) async {
    String? team_id = await _getTeamid();
    String? kind = await _getKind();

    String apiUrl;
    if (kind == 'solo_artist') {
      apiUrl = '${Config().apiDomain}/artist/info/$artist_id';
    } else if (kind == 'team') {
      apiUrl = '${Config().apiDomain}/artist/team_info/$team_id';
    } else {
      return;
    }

    try {
      var uri = Uri.parse(apiUrl);
      var response = await http.get(
        uri,
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> user = json.decode(response.body);
        if (mounted) {
          setState(() {
            amount = (user['data']['attributes']['price_per_hour']).toString();
          });
        }
      } else {
        print('user fetch unsuccessful Status code: ${response.body}');
      }
    } catch (e) {
      print('Error fetching artist: $e');
    }
  }

  Future<void> fetchBookingDetails(String booking_id) async {
    String apiUrl = '${Config().apiDomain}/booking/$booking_id';

    try {
      var uri = Uri.parse(apiUrl);
      var response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> booking = json.decode(response.body);
        print(booking);
        if (mounted) {
          setState(() {
            location = booking['location'];
            BookingDate = booking['booking_date'];
            Category = booking['category'];
            SpecialRequest = booking['special_request'];
            duration = booking['duration'];
            booked_from=booking['booked_from'];
            booked_to=booking['booked_to'];
            user_id=booking['user_id'].toString();
            audience_size=booking['audience_size'];
            total_amount=booking['total_amount'];

          });
        }
        _saveUserInformation(user_id);
      } else {
        print('Booking fetch unsuccessful: ${response.body}');
      }
    } catch (e) {
      print('Error fetching booking details: $e');
    }
  }


  void _saveUserInformation(String? user_id) async {

    // Example URL, replace with your actual API endpoint
    String apiUrl = '${Config().apiDomain}/info/$user_id';

    // // Prepare data to send to the backend
    // Map<String, dynamic> userData = {
    //   'first_name': nameController.text,
    // };

    try {
      // Make PATCH request to the API
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',

        },
        // body: jsonEncode(userData),
      );

      // Check if request was successful (status code 200)
      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        setState(() {
        user_name=userData['first_name'];
        phone_number=userData['phone_number'];
        });
        print(user_name);
        // User information saved successfully, handle response if needed
        print('User information saved successfully');
        // Example response handling
        print('Response: ${response.body}');
      } else {
        // Request failed, handle error
        print('Failed to save user information. Status code: ${response.statusCode}');
        // Example error handling
        print('Error response: ${response.body}');
      }
    } catch (e) {
      // Handle network errors
      print('Error saving user information: $e');
    }
  }




  String calculateTotalAmount(String duration, String pricePerHour) {
    // Extract hours and minutes from the duration string
    List<String> durationParts = duration.split(' ');

    int hours = 0;
    int minutes = 0;

    for (int i = 0; i < durationParts.length; i++) {
      if (durationParts[i] == 'hours') {
        hours = int.parse(durationParts[i - 1]);
      } else if (durationParts[i] == 'minutes') {
        minutes = int.parse(durationParts[i - 1]);
      }
    }

    // Convert total duration to hours as a double
    double totalHours = hours + (minutes / 60.0);

    // Parse the price per hour string
    double price = double.parse(pricePerHour);

    // Calculate the total amount
    double totalAmount = totalHours * price / 1.18;
    // Calculate 18% discount
    // double discount = totalAmount * 0.18;
    //
    // totalAmount = totalAmount - discount;
    // Format the total amount to a string with 2 decimal places
    return totalAmount.toStringAsFixed(2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121217),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: Center(
            child: Text(
              'Event Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xFF121217),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                await generateOtp(context); // Call OTP generation function
                showOtpDialog(context); // Show OTP dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Generate OTP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: fetchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: [
                  SizedBox(height: 15),
                  Text(
                    'Congrats, you’ve received a booking!',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 21,
                      height: 1.3,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(height: 23),

                  Text(
                    'Name:   $user_name',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                      height: 1.5,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(height: 23),
                  Text(
                    'On Date:   $BookingDate',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                      height: 1.5,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'From:   $booked_from  ',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                      height: 1.5,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Duration:   $duration',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                      height: 1.5,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(height: 16),
              _buildInfoSection(
                title: 'Exact amount you will receive',
                info: '$total_amount'
               // info: calculateTotalAmount(duration!, amount!), // Calling the function directly
              ),
                  _buildInfoSection(
                    title: 'Type of Booking',
                    info: Category ?? 'N/A',
                  ),
                  _buildInfoSection(
                    title: 'Audience Size',
                    info: audience_size ?? 'N/A',
                  ),
                  _buildInfoSection(
                    title: 'Location',
                    info: location ?? 'N/A',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Special Requests',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      height: 1.5,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    SpecialRequest ?? 'N/A',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      height: 1.5,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> generateOtp(BuildContext context) async {
    String phoneNumber = phone_number!.trim();
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
      print(response.statusCode );
      // Handle the response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        number = responseData['number']; // Display only in testing, remove in production
        _showSnackBar('OTP sent successfully! ');

      } else {
        print('error sending otp ');
        final errorMessage = jsonDecode(response.body)['response']['message'];
        print(errorMessage);
      }
    } catch (e) {
      print(e);
      _showSnackBar('Something went wrong: $e');
    }
  }
// Function to generate OTP
//   Future<void> generateOtp(BuildContext context) async {
//     // Your OTP generation logic here
//     final String apiUrl = '${Config().apiDomain}/sms/user/$user_id'; // Replace with the correct API URL
//
//     try {
//       final response = await http.get(
//         Uri.parse(apiUrl),
//         headers: {'Accept': 'application/json',
//         'Content-Type': 'application/json',},
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//          number = responseData['number']; // Display only in testing, remove in production
//         _showSnackBar('OTP sent successfully! ');
//       } else {
//         print('error sending otp ');
//         final errorMessage = jsonDecode(response.body)['response']['message'];
//         print(errorMessage);
//         // _showSnackBar(errorMessage ?? 'Failed to send OTP');
//       }
//     } catch (e) {
//       print(e);
//       // _showSnackBar('Error: $e');
//     }
//   }

  // Function to display a Snackbar with the provided message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

/// Function to show OTP dialog
  void showOtpDialog(BuildContext context) {
    TextEditingController otpController = TextEditingController();
    bool isVerified = false; // Track verification status

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing without user action
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Text('Enter OTP'),
                  SizedBox(width: 10),
                  if (isVerified) // Show tick mark if verified
                    Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              content: TextField(
                controller: otpController,
                decoration: InputDecoration(
                  hintText: 'Enter OTP sent to the user',
                ),
                keyboardType: TextInputType.number,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Handle OTP verification logic
                    String enteredOtp = otpController.text;

                    print('Entered OTP: $enteredOtp');

                    bool verify = await _verifyOTP(phone_number!, enteredOtp);

                    if (verify) {
                      _bookingCompleted(widget.bookingId);
                      setState(() {
                        isVerified = true; // Update verification status
                      });

                      // Optionally close dialog after showing the tick for a short period
                      await Future.delayed(Duration(seconds: 1));
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid OTP!')),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }



  void _bookingCompleted(String bookingId) async {
    final response = await http.patch(
      Uri.parse('${Config().apiDomain}/booking/$bookingId'),
      headers: <String, String>{
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json',
      },
      body: json.encode({
        'status': 3,
      }),
    );

    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      print(decodedResponse);
      print('Booking updated successfully');
// <<<<<<< HEAD


      // // Update the status of the booking locally
      // setState(() {
      //   final booking = bookings.firstWhere(
      //         (b) => b['id'] == bookingId,
      //     orElse: () => <String, dynamic>{},
      //   );
      //
      //   if (booking.isNotEmpty) {
      //     booking['status'] = 1;
      //   }
      // });

      // Show success dialog
      // _showDialog('Success', 'Booking accepted successfully');
    } else {
      // Handle the error case
      print('Failed to update booking: ${response.statusCode}');
      // Show error dialog
      // _showDialog('Error', 'Failed to accept booking');
// =======
//       // _updateBookingstatus(1);
//
//     } else {
//       // Handle the error case
//       print('Failed to update booking: ${response.statusCode}');
//
// >>>>>>> 71fc5321e6356695c1a1f769543a7c429f07c784
    }
  }
  Future<bool> _verifyOTP(String phoneNumber, String otpCode) async {
    // Your backend endpoint that verifies the OTP via Twilio
    final String url = '${Config().apiDomain}/verify';
    // String? userType = await _getSelectedValue();
    if (phoneNumber.startsWith('+91')) {
      phoneNumber = phoneNumber.substring(3).trim();
    }
    print(phoneNumber);

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json'},
      body: jsonEncode({'numbers': phoneNumber, 'otp': otpCode}),
    );

    if (response.statusCode == 200) {
      print('OTP verified successfully');
      // Navigate to the relevant home page
      // _navigateToHome(userType);
      return true;
    } else {
      print('Failed to verify OTP: ${response.body}');
      return false;
      _showSnackBar('Invalid OTP. Please try again.');
    }
    return false;
  }

  // Future<bool> _verifyOTP(String otpCode) async {
  //   // Your backend endpoint that verifies the OTP via Twilio
  //   final String url = '${Config().apiDomain}/verify/user';
  //   // String? userType = await _getSelectedValue();
  //   // if (phoneNumber.startsWith('+91')) {
  //   //   phoneNumber = phoneNumber.substring(3).trim();
  //   // }
  //   // print(phoneNumber);
  //
  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {'Content-Type': 'application/vnd.api+json',
  //       'Accept': 'application/vnd.api+json'},
  //     body: jsonEncode({'user_id': user_id, 'otp': otpCode}),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     print('OTP verified successfully');
  //     // Navigate to the relevant home page
  //
  //     return true;
  //   } else {
  //     print('Failed to verify OTP: ${response.body}');
  //     return false;
  //     _showSnackBar('Invalid OTP. Please try again.');
  //   }
  //   return false;
  // }


  Widget _buildInfoSection({required String title, required String info}) {
    return Container(
      margin: EdgeInsets.only(bottom: 1),
      padding: EdgeInsets.symmetric(vertical: 13.5),
      color: Color(0xFF121217),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.epilogue(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              height: 1.5,
              color: Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 4),
          Text(
            info,
            style: GoogleFonts.epilogue(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              height: 1.5,
              color: Color(0xFF9494C7),
            ),
          ),
        ],
      ),
    );
  }
}


