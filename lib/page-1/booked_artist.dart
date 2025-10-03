import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:test1/page-1/review.dart';
import 'package:test1/page-1/user_bookings.dart';
import '../config.dart';
import '../main.dart';
import '../utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'bottom_nav.dart';



class Booked extends StatefulWidget {
  final String BookingId;
  final String artistId;
   bool? isEquipment;
  String? isteam;
  Booked({required this.BookingId, required this.artistId , this.isteam, this.isEquipment});

  @override
  _BookedState createState() => _BookedState();
}

class _BookedState extends State<Booked> {
  // Fetched text from backend

  String? name;
  String? price;
  String? image;
  String? phone_number;
  String? dateText ;
  String? timeText ;
  String? durationText ;
  String? priceText;
  String? locationText ;
  int? hour;
  double? ratings;
  int? minute;
  String? fcm_token;
  String? totalprice;
  int? status;
  String? skill;
  String? teamName;
  String? fcmToken;
  String? _durationText;
  int? sound_system_price;
  TextEditingController _locationController= TextEditingController();
  TextEditingController _dateTextController= TextEditingController();
  TextEditingController _timeTextController= TextEditingController();
 String? total_amount;
  // TextEditingController _durationTextController= TextEditingController();
  bool _isLoading = false;


  // Add a loading state for each editable field
  bool _isLoadingDate = false;
  bool _isLoadingTime = false;
  bool _isLoadingLocation = false;
  bool _isInitialLoading = true;

  final storage = FlutterSecureStorage();
  bool _isEditing = false;
  Future<void>? _fetchArtistBookingFuture;


  Future<String?> _getToken() async {
    return await storage.read(key: 'token'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getid() async {
    return await storage.read(key: 'id'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getbookingid() async {
    return await storage.read(key: 'booking_id'); // Assuming you stored the token with key 'token'
  }
  Future<String?> _getKind() async {
    return await storage.read(key: 'selected_value'); // Assuming you stored the token with key 'token'
  }
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _fetchArtistBookingFuture = fetchArtistBooking(widget.artistId);

  }
  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isInitialLoading = true;
      });

      await Future.wait([
        fetchBookingDetails(widget.BookingId),
        // fetchArtistBooking(widget.artistId),
        rating()
      ]);
    } catch (error) {
      print('Error fetching details: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch booking details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }
  Future<void> rating() async {


    String apiUrl;
    if (widget.isteam=='true') {
      apiUrl = '${Config().apiDomain}/team/${widget.artistId}/average-rating';
    }else{
      apiUrl = '${Config().apiDomain}/artist/${widget.artistId}/average-rating';
    }
    print(apiUrl);
    print('artist_id is ${widget.artistId}');

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);


        // Ensure count is not zero before dividing, to prevent division by zero.
        double safeDivide(int numerator, int denominator) {
          return denominator != 0 ? (numerator / denominator).toDouble() : 0.0;
        }

        setState(() {
          ratings = (responseData['average_rating']).toDouble();
          ratings = double.parse(ratings!.toStringAsFixed(1));
        });


      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        // return 'Error fetching availability status';
      }
    } catch (e) {
      print('Error fetching data: $e');
      // return 'Error fetching availability status';
    }
  }


  Future<String> calculateTotalAmount(String pricePerHour, int? hours, int? minutes) async {
    // Convert total time to hours
    if (hours == null || minutes == null) return '0';

    double totalTimeInHours = hours + (minutes / 60.0);

    // Convert pricePerHour to double
    double pricePerHourDouble = double.tryParse(pricePerHour) ?? 0.0;
    // double? sound_price=sound_system_price?.toDouble();
    // Calculate the total amount
    double totalAmount = totalTimeInHours * pricePerHourDouble ;

    // Format the amount to two decimal places
    String formattedAmount = totalAmount.toStringAsFixed(2) ;

    return formattedAmount;
  }


  Future<String?> fetchBookingDetails(String BookingId)async{

    print('booking id is nck ${widget.BookingId}');
    String? token = await _getToken();
    String? booking_id = await _getbookingid();

    String apiUrl= '${Config().apiDomain}/booking/$BookingId';
    print(apiUrl);

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> userData = json.decode(response.body);
        print("hello mmohuit");
        print(userData);
        print("bye");

        // Check if] the widget is mounted before calling setState

        setState(() {
          _durationText = userData['duration'] ?? '';
          _locationController.text = userData['location'] ?? '';
          _dateTextController.text = userData['booking_date'] ?? '';
          _timeTextController.text = userData['booked_from'] ?? '';
          total_amount=userData['total_amount'] ?? '';
          // status= userData['status'] ?? '';
          sound_system_price= userData['sound_system_price'] ;

        });
        print(' price isb  $sound_system_price');
        // Split the string by spaces
        List<String>? parts = _durationText?.split(' ');

        // // Initialize hour and minute variables
        // int hours = 0;
        // int minutes = 0;

        // Iterate over the parts and extract the values
        for (int i = 0; i < parts!.length; i++) {
          if (parts[i] == "hour" || parts[i] == "hours") {
            hour = int.parse(parts[i - 1]) as int?;
          } else if (parts[i] == "minute" || parts[i] == "minutes") {
            minute = int.parse(parts[i - 1]) as int?;
          }
        }

        // Print the extracted values
        print('Hours: $hour');
        print('Minutes: $minute');

// setState(() async {
//   totalprice=await calculateTotalAmount( price!, hour as int , minute as int );
//
//   totalprice;
// });



      }

      else {
        print('Failed to fetch user information. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user sssssssinformation: $e');
    }
    return null;
  }




  Future<void> fetchArtistBooking(String artistId) async {
    // String? token = await _getToken();
    String? id = await _getid();
    // String? kind = await _getKind();
    print(id);
    print('widget ka istemn kya hai :${widget.isteam}');


    String apiUrl;
    if (widget.isteam =='true') {
      apiUrl= '${Config().apiDomain}/featured/team/$artistId';
      print(apiUrl);

    }else{
      apiUrl = '${Config().apiDomain}/featured/artist_info/$artistId';
    }

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> userDataList = json.decode(response.body);
// print('the dtata is $userDataList');
        // Check if the widget is mounted before calling setState
        if (mounted) {
          for (var userData in userDataList) {
            // setState(() {
            // teamName=
            name = userData['name'] ?? userData['team_name'] ?? '';
            price = (userData['price_per_hour']).toString() ?? '' ;
            image = '${userData['profile_photo']}' ;
            phone_number=userData['phone_number'] ?? '';
            fcm_token=userData['fcm_token']??'';
            skill=  userData['skill_category'] ?? '';
            print('token is $fcm_token');
            // });
          }
        }
      } else {
        print('Failed to fetch user information. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user informationss: $e');
    }
  }

  // Modify the save booking details function to handle field-specific loading states
  Future<bool> _saveBookingDetails() async {
    print('saveBooking is working');

    // Set loading state for specific fields that are being updated
    setState(() {
      if (_dateTextController.text != dateText) _isLoadingDate = true;
      if (_timeTextController.text != timeText) _isLoadingTime = true;
      if (_locationController.text != locationText) _isLoadingLocation = true;
    });

    String apiUrl = '${Config().apiDomain}/booking/${widget.BookingId}';
    Map<String, dynamic> formData = {
      'booking_date': _dateTextController.text,
      'booked_from': _timeTextController.text,
      'location': _locationController.text,
    };

    try {
      var response = await http.patch(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _isEditing = false;
            dateText = _dateTextController.text;
            timeText = _timeTextController.text;
            locationText = _locationController.text;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking details saved successfully')),
        );

        return true;
      } else {
        _showErrorSnackBar('Failed to save booking details');
        return false;
      }
    } catch (e) {
      print('Error saving booking details: $e');
      _showErrorSnackBar('Error saving booking details');
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDate = false;
          _isLoadingTime = false;
          _isLoadingLocation = false;
        });
      }
    }
  }

// Helper function to show an error SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // TODO: implement build
  //   throw UnimplementedError();
  // }
  // }

  Future<String> _calculateTotalPrice() async {
    if (hour == null || minute == null) {
      return '0';  // Default value while waiting for data
    }
    return calculateTotalAmount(price ?? '', hour!, minute!);
  }





  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    bool _isValidDateFormat(String input) {
      final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');  // yyyy-MM-dd
      return dateRegex.hasMatch(input);
    }

    // Function to format date safely (optional use)
    String? _formatDate(String input) {
      try {
        final parsedDate = DateFormat('yyyy-MM-dd').parseStrict(input);
        return DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        return null;  // Return null if formatting fails
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<void>(
            future: _fetchArtistBookingFuture, // Fetch the booking details once
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(), // Show loading bar while fetching data
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error fetching data!'), // Show error message if there's an issue
                );
              } else {
                // Data fetched successfully
                return Container(
                  color: Colors.grey,
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar section
                        Container(
                          padding: EdgeInsets.fromLTRB(1 * fem, 1 * fem, 1 * fem, 2 * fem),
                          width: double.infinity,
                          height: 62 * fem,
                          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BottomNav(
                                        isteam: widget.isteam,
                                        initialPageIndex: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Booking Details',
                                    style: SafeGoogleFont(
                                      'Be Vietnam Pro',
                                      fontSize: 21 * ffem,
                                      fontWeight: FontWeight.w500,
                                      height: 1.25 * ffem / fem,
                                      letterSpacing: -0.27 * fem,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 48), // Space to center the title
                            ],
                          ),
                        ),

                        // Booking details section
                        InkWell(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0 * fem, 0.15 * fem, 0 * fem, 0.15 * fem),
                            padding: EdgeInsets.fromLTRB(1 * fem, 8 * fem, 1 * fem, 10 * fem),
                            width: 540 * fem,
                            height: 160 * fem,
                            color: Color(0xFFFFFFFF),
                            child: Row(
                              children: [
                                // Artist image section
                                Container(
                                  margin: EdgeInsets.fromLTRB(16 * fem, 0 * fem, 15 * fem, 0 * fem),
                                  width: 110 * fem,
                                  height: 140 * fem,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10 * fem),
                                    child: Image.network(
                                      image ?? '', // Display the fetched image
                                      fit: BoxFit.cover, // Ensure the image covers the container
                                    ),
                                  ),
                                ),

                                // Artist details section
                                Container(
                                  padding: EdgeInsets.fromLTRB(10 * fem, 10 * fem, 5 * fem, 8 * fem),
                                  width: 247 * fem,
                                  height: double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Artist name
                                      Text(
                                        name ?? '',
                                        style: SafeGoogleFont(
                                          'Be Vietnam Pro',
                                          fontSize: 18 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5 * ffem / fem,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 7 * fem),

                                      // Price and rating details
                                      Text(
                                        'Event Price: ${price ?? ''}',
                                        style: SafeGoogleFont(
                                          'Be Vietnam Pro',
                                          fontSize: 16 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5 * ffem / fem,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 7 * fem),

                                      Text(
                                        'Rating: ${ratings ?? 'null/5'}',
                                        style: SafeGoogleFont(
                                          'Be Vietnam Pro',
                                          fontSize: 16 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5 * ffem / fem,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 7 * fem),

                                      // Artist skill details
                                      Text(
                                        'Skill: ${skill ?? ''}',
                                        style: SafeGoogleFont(
                                          'Be Vietnam Pro',
                                          fontSize: 16 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5 * ffem / fem,
                                          color: Colors.black,
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
                          margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem,
                              0.15 * fem),
                          // depth1frame51h9 (9:1715)
                          padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 16 * fem,
                              10 * fem),
                          width: double.infinity,
                          height: 80 * fem,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 249 * fem,
                                height: 24 * fem,
                                child: Text(
                                  'Date:',
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 19 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10 * fem),
                              Container(
                                width: 249 * fem,
                                height: 24 * fem,
                                child: TextField(
                                  controller: _dateTextController,
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 17 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5 * ffem / fem,
                                    color: _isEditing ? Colors.blue : Color(0xff876370),
                                  ),
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.datetime,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'\d|[-]')),  // Allow only digits and '-'
                                    LengthLimitingTextInputFormatter(10),  // Limit input to 'yyyy-MM-dd'
                                  ],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'yyyy-MM-dd',  // Placeholder to indicate the required format
                                  ),
                                  onChanged: (value) {
                                    if (_isEditing && !_isValidDateFormat(value)) {
                                      // Optionally provide feedback or reset the field
                                      print('Invalid date format. Use yyyy-MM-dd.');
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 *
                            fem, 0.15 * fem),
                          // depth1frame6vBq (9:1724)
                          padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 16 * fem,
                              10 * fem),
                          width: double.infinity,
                          height: 80 * fem,
                          decoration: BoxDecoration(
                            color: Colors.white
                            ,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // depth4frame0nE3 (9:1727)
                                width: 249 * fem,
                                height: 24 * fem,
                                child: Text(
                                  'Time:',
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 19 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10 * fem,),
                              Container(
                                width: 249 * fem,
                                height: 24 * fem,
                                child: TextField(
                                  controller: _timeTextController,
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 17 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5 * ffem / fem,
                                    color: _isEditing ? Colors.blue : Color(
                                        0xff876370),
                                  ),
                                  enabled: _isEditing,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 *
                            fem, 0.15 * fem),
                          // depth1frame7BGB (9:1733)
                          padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 16 * fem,
                              10 * fem),
                          width: double.infinity,
                          height: 80 * fem,
                          decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 249 * fem,
                                height: 24 * fem,

                                child: Text(
                                  'Duration:',
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 19 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Colors.black,

                                  ),
                                ),
                              ),
                              SizedBox(height: 10 * fem,),
                              Container(
                                width: 249 * fem,
                                height: 24 * fem,

                                child: Text(
                                  _durationText ?? '',
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 17 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5 * ffem / fem,
                                    color:  Color(
                                        0xff876370),
                                  ),
                                  // enabled: _isEditing,
                                  // decoration: InputDecoration(
                                  //   border: InputBorder.none,
                                  // ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 *
                            fem, 0.15 * fem),
                          // depth1frame8U8o (9:1742)
                          padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 16 * fem,
                              10 * fem),
                          width: double.infinity,
                          height: 80 * fem,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF)
                            ,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: 249 * fem,
                                  height: 24 * fem,
                                  child: Text(
                                    'Total Price',
                                    style: SafeGoogleFont(
                                      'Be Vietnam Pro',
                                      fontSize: 19 * ffem,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5 * ffem / fem,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10 * fem,),
                              // Use FutureBuilder to handle async calculation
                              Container(
                                width: 249 * fem,
                                height: 24 * fem,

                                child: Text(
                                  '$total_amount',
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 17 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5 * ffem / fem,
                                    color:  Color(
                                        0xff876370),
                                  ),
                                  // enabled: _isEditing,
                                  // decoration: InputDecoration(
                                  //   border: InputBorder.none,
                                  // ),
                                ),
                              ),
                            ],
                          ),

                        ),
                        Container(margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 *
                            fem, 0.15 * fem),
                          padding: EdgeInsets.fromLTRB(16 * fem, 10 * fem, 16 * fem,
                              1 * fem),
                          width: double.infinity,
                          height: 150 * fem,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 349 * fem,
                                height: 34 * fem,
                                child: Text(
                                  'Location:',
                                  style: SafeGoogleFont(
                                    'Be Vietnam Pro',
                                    fontSize: 19 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 0 * fem,),
                              Expanded(
                                child: Container(
                                  width: 349 * fem,
                                  child: SingleChildScrollView(
                                    child: TextField(
                                      controller: _locationController,
                                      style: SafeGoogleFont(
                                        'Be Vietnam Pro',
                                        fontSize: 17 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5 * ffem / fem,
                                        color: _isEditing ? Colors.blue : Color(0xff876370),
                                      ),
                                      enabled: _isEditing,
                                      maxLines: null, // Allow unlimited lines with scroll
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      textAlignVertical: TextAlignVertical.top,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.fromLTRB(16 * fem, 20 * fem, 16 * fem, 12 * fem),
                          width: double.infinity,
                          height: 250 * fem,  // Adjust height to accommodate the new button
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Write Review Button
                              Padding(
                                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 8),
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Navigate to review page or show review dialog
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ReviewPage(artistId: widget.artistId, isteam: widget.isteam)),
                                    );

                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10 * fem),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16 * fem,
                                      vertical: 8 * fem,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Write Review',
                                      style: SafeGoogleFont(
                                        'Be Vietnam Pro',
                                        fontSize: 16 * ffem,
                                        fontWeight: FontWeight.w700,
                                        height: 1.5 * ffem / fem,
                                        letterSpacing: 0.2399999946 * fem,
                                        color: Color(0xff171111),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Edit Booking Button
                              Padding(
                                padding: const EdgeInsets.only(left: 25, right: 25),
                                child: OutlinedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _isEditing = !_isEditing;
                                      _isLoading = false;// Update editing state
                                    });

                                    // Only update if _isEditing is set to false (meaning the user clicked "Save Changes")
                                    if (!_isEditing) {
                                      final inputDate = _dateTextController.text;
                                      final formattedDate = _formatDate(inputDate);

                                      if (formattedDate == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Invalid date format. Please use yyyy-MM-dd.'),
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } else {
                                        _dateTextController.text = formattedDate;

                                        setState(() {
                                          _isLoading = true;  // Start loading state
                                        });

                                        try {
                                          bool success = await _saveBookingDetails();

                                          setState(() {
                                            _isLoading = false;  // End loading state
                                            if (success) {
                                              sendNotifications(context, fcm_token!, false);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Retry, Failed to update booking details'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          });
                                        } catch (e) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          print('Error updating booking details: $e');
                                        }
                                      }
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10 * fem),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16 * fem,
                                      vertical: 8 * fem,
                                    ),
                                  ),
                                  // Update OutlinedButton text based on _isLoading
                                  child: Center(
                                    child: Text(
                                      _isLoading ? 'Saving...' : (_isEditing ? 'Save Changes' : 'Edit Booking'),
                                      style: SafeGoogleFont(
                                        'Be Vietnam Pro',
                                        fontSize: 16 * ffem,
                                        fontWeight: FontWeight.w700,
                                        height: 1.5 * ffem / fem,
                                        letterSpacing: 0.2399999946 * fem,
                                        color: Color(0xff171111),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 8 * fem),

                              // Cancel Booking Button Logic
                              Padding(
                                padding: const EdgeInsets.only(left: 25, right: 25),
                                child: (status == 2)
                                    ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Booking Canceled, You can still change your decision',
                                      style: GoogleFonts.epilogue(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        height: 1.5,
                                        color: Color(0xffe5195e),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          status = 0;
                                        });
                                        cancelBooking(context, widget.BookingId, '0');
                                        fetchArtist( widget.artistId, false);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 8.5),
                                      ),
                                      child: Center(
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
                                    ),
                                  ],
                                )
                                    :OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      status = 2;
                                      _showCancelConfirmationDialog(context, widget.BookingId, widget.artistId);
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.black,
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
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                );


              }
            }
        ),
      ),
    );
  }

  // Show dialog with modified fetchArtist function
  void _showCancelConfirmationDialog(BuildContext context, String booking_id, String artist_id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xfffff5f8),
          title: Text('Cancel Booking'),
          content: Text(
            'Are you sure you want to cancel the booking?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'No',
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                bool wait = await cancelBooking(context, booking_id, '2'); // Call the cancel booking function
                if (wait) {
                  fetchArtist(artist_id, true); // Pass artist_id only, avoid context dependency
                } else {
                  print('Error occurred while fetching user');
                }
              },
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

// Modified fetchArtist without context dependency
  Future<void> fetchArtist(String artist_id, bool status) async {
    String apiUrl = '${Config().apiDomain}/artist/info/$artist_id';

    try {
      var uri = Uri.parse(apiUrl);
      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> artist = json.decode(response.body);
        String? fcmToken = artist['data']['attributes']['fcm_token'];

        if (fcmToken != null) {
          sendNotification(fcmToken, status); // Avoid using context in sendNotification as well
        }
      } else {
        print('User fetch unsuccessful: ${response.body}');
      }
    } catch (e) {
      print('Error fetching artist: $e');
      // Use app-level navigator key if available for showing a snackbar, instead of context
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Notification has been sent to the artist'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

// Send notification without context dependency
  Future<void> sendNotification(String fcm_token, bool status) async {
    if (!mounted) return;

    String apiUrl = '${Config().apiDomain}/send-notification';
    Map<String, dynamic> requestBody = {
      'type': 'artist',
      'fcm_token': fcm_token,
      'status': status,
    };

    try {
      var uri = Uri.parse(apiUrl);
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        _showDialog(
          status ? 'Delete success' : 'Request initiated again',
          status
              ? 'Your booking has been deleted successfully and notification has been sent to the artist'
              : 'Notification has been sent to the artist again.',
        );
      } else {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Notification unsuccessful'),
            backgroundColor: Colors.green,
          ),
        );
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }



  Future<bool> cancelBooking(BuildContext context, String booking_id, String status ) async {
    print(booking_id);
    final response = await http.patch(
        Uri.parse('${Config().apiDomain}/booking/$booking_id'),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
        body: json.encode({
          'status':status,
        })

    );

    if (response.statusCode == 200) {
      // var decodedResponse = json.decode(response.body);
      // print(decodedResponse);
      print('Booking deleted successfully');
      print(response.body);
      // _loadBookings();
      return true;

      // Show success dialog
      // _showDialog('Success', 'Booking deleted successfully');
    } else {
      // Handle the error case
      print('Failed to update booking: ${response.body}');
      // Show error dialog
      // _showDialog('Error', 'Failed to delete booking');

    }
    return false;
  }

  void _showDialog( String title, String message) {
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

  Future<void> sendNotifications(BuildContext context, String fcm_token,bool status ) async {
    // Initialize API URLs for different kinds
    String apiUrl = '${Config().apiDomain}/send-notification_user';
    print('sendnotoify');
    print(fcm_token);

    Map<String, dynamic> requestBody = {
      'type':'artist',
      'fcm_token':fcm_token,
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
}





