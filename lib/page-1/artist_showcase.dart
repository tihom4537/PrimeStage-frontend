import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test1/page-1/artist_booking.dart';
import 'package:test1/page-1/phone_varification.dart';
import 'package:test1/page-1/reviews.dart';
import 'package:video_player/video_player.dart';
import '../config.dart';
import '../utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';



class ArtistProfile extends StatefulWidget {
  late String  artist_id;
// <<<<<<< HEAD
  String? isteam;
// =======
//       String?  isteam;
// >>>>>>> 7843d0fd9f9f56e19be3ee78285dd0192d2cb138
  ArtistProfile( {required this.artist_id, this.isteam});


  @override
  _ArtistProfileState createState() => _ArtistProfileState();
}

class _ArtistProfileState extends State<ArtistProfile> {
  final List<String> demoSkills = []; // replace with backend data
  String? experience ; // replace with backend data (can be '3 months', '2 years', etc.)
  // final bool hasSoundSystem = true; // replace with backend data
  final storage = FlutterSecureStorage();
  String? artistName;
  String? teamName;
  String? artistRole;
  String? teamRole;
  String? skills;
  bool? hasSoundSystem;
  String? artistPrice;
  String? artistRatings;
  String? artistAboutText;
  String? teamAbout;
  String? artistSpecialMessage;
  String? artist_id;
  String? artist_address;
  late String profilePhoto='';
  String? image1;
  String? image2;
  String? image3;
  String? image4;
  String? video1;
  String? video2;
  String? video3;
  String? video4;
  String? video5;
  List<String> thumbnailPathsFromBackend=[];
  List<String> imagePathsFromBackend = [];
  List<String> VideoPathsFromBackend = [];// List to store image URLs
  double? avg;
  double? four;
  double? five;
  double? three;
  double? two;
  double? one;
  int? count;
  late Future<List<dynamic>> _teamMembersFuture;
  late Future<String> _availabilityStatusFuture;
  List<String>?  bookedDates;
  String? artist_previous;
  String? team_previous;
  String? trimmedArtistAbout;
  String? trimmedTeamAbout;
  bool _isLoading = true;
  String? _error;


  Future<String?> _getKind() async {
    return await storage.read(key: 'selected_value'); // Assuming you stored the token with key 'selected_value'
  }

  @override
  void initState() {
    super.initState();
    // Call the single initialization function
    initializeData();
    rating();

  }

  // Single function to handle multiple tasks
  void initializeData() {
    // Fetch profile data when screen initializes
    fetchArtistWorkInformation(widget.artist_id);
    print('aman is ');
print(widget.isteam);
    print('kunal; is ');
    // Cache the team members API call if the condition is met
    if (widget.isteam == 'true') {
      _teamMembersFuture = teamMembersFromBackend();
    }

    // Cache the availability status API call
    _availabilityStatusFuture = fetchAvailabilityStatus();
  }



  Future<void> fetchArtistWorkInformation(String artistId) async {
    String apiUrl;

    // Choose the correct API URL based on whether it's a team or an individual artist
    if (widget.isteam == 'true') {
      apiUrl = '${Config().apiDomain}/featured/team/$artistId';
    } else {
      apiUrl = '${Config().apiDomain}/featured/artist_info/$artistId';
    }

    String baseUrl = 'http://192.0.0.2:8000/storage'; // Your base URL

    try {
      // Making the GET request
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response
        List<dynamic> artistDataList = json.decode(response.body);
print(artistDataList);

        // Clear existing paths to avoid duplicates
        imagePathsFromBackend.clear();
        VideoPathsFromBackend.clear();
        thumbnailPathsFromBackend.clear();
        // Process each artist's data
        for (var artistData in artistDataList) {
          setState(() {
            artistName = artistData['name'] ;
            teamName = artistData['team_name'] ;
            artistRole = artistData['skills'] ;
            teamRole = artistData['skill_category'] ;
            // skills = artistData['skills'];
            artistPrice = (artistData['price_per_hour'] ?? 0.0).toStringAsFixed(2);
            artistAboutText = artistData['about_yourself'] ;
            teamAbout = artistData['about_team'] ;
            artistSpecialMessage = artistData['special_message'] ?? '';
            profilePhoto = artistData['profile_photo'] ?? '';
            artist_address =artistData['address'] ?? '';
            print( artist_address);
            // hasSoundSystem=artistData['sound_system'] == 1 ? true: false ;

            // Image and video URLs
            image1 = artistData['image1'];
            image2 = artistData['image2'];
            image3 = artistData['image3'];
            image4 = artistData['image4'];
            video1 = artistData['video1'];
            video2 = artistData['video2'];
            video3 = artistData['video3'];
            video4 = artistData['video4'];
            video5=artistData['video5'];
            print('videos $video3');
            print(video5);

            // Add non-null image URLs to the list
            if (image1 != null) imagePathsFromBackend.add(image1!);
            if (image2 != null) imagePathsFromBackend.add(image2!);
            if (image3 != null) imagePathsFromBackend.add(image3!);
            imagePathsFromBackend.add(profilePhoto!);

            //extract thumbnail from video column
            for (var videoField in [video1, video2, video3]) {
              if (videoField != null) {
                List<String> parts = videoField.split(',');
                if (parts.isNotEmpty) {
                  // First part is the video URL
                  String videoUrl = parts[0].trim();
                  VideoPathsFromBackend.add(videoUrl);

                  // Second part (if exists) is the thumbnail URL
                  if (parts.length > 1) {
                    thumbnailPathsFromBackend.add(parts[1].trim());
                  } else {
                    thumbnailPathsFromBackend.add('');
                  }
                }
              }
            }
            // For video4, video5 (YouTube videos)
            for (var videoField in [video4, video5]) {
              if (videoField != null) {
                // Just add the video URL without attempting to extract thumbnail
                VideoPathsFromBackend.add(videoField.trim());
                // Add empty thumbnail - will be handled by YouTube player
                thumbnailPathsFromBackend.add('');
              }
            }
            print('thumbnails');
            print(thumbnailPathsFromBackend);
          });
        }

        print('special message $artistSpecialMessage');

        artist_previous = artistAboutText?.split(',')[1].trim();
        team_previous = teamAbout?.split(',')[1].trim() ?? null;

        trimmedArtistAbout = artistAboutText?.split(',')[0].trim();
        trimmedTeamAbout = teamAbout?.split(',')[0].trim();
        List<String> parsedBackendSkills = artistRole!.split(',').map((skill) => skill.trim()).toList();
        // Combine both lists and remove duplicates
        // Add backend skills to demoSkills, avoiding duplicates
        for (String skill in parsedBackendSkills) {
          if (!demoSkills.contains(skill)) {
            demoSkills.add(skill);
          }
        }
        // print(demoSkills);

        print('skills is $skills');
        print('video is $video1,$video2, $video3,$video4');
        print('skill category is $teamRole');

      } else {
        print('Failed to fetch artist information. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error fetching artist information: $e');
    }
  }

  Future<void> rating() async {
    String apiUrl;
    if (widget.isteam == 'true') {
     apiUrl = '${Config().apiDomain}/team/${widget.artist_id}/average-rating';
    } else {
      apiUrl = '${Config().apiDomain}/artist/${widget.artist_id}/average-rating';
    }
    // print(apiUrl);
    // print('artist_id is ${widget.artist_id}');

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

        double safeDivide(int numerator, int denominator) {
          return denominator != 0 ? (numerator / denominator).toDouble() : 0.0;
        }

        setState(() {
          _isLoading = false;
          avg = double.parse(responseData['average_rating'].toDouble().toStringAsFixed(1));
          count = responseData['total_ratings'];
          four = safeDivide(responseData['four_star_ratings'], count!);
          five = safeDivide(responseData['five_star_ratings'], count!);
          three = safeDivide(responseData['three_star_ratings'], count!);
          two = safeDivide(responseData['two_star_ratings'], count!);
          one = safeDivide(responseData['one_star_ratings'], count!);
        });
      } else {
        Map<String, dynamic> errorResponse = json.decode(response.body);
        if (errorResponse['error'] == 'No reviews found for this artist') {
          setState(() {
            _isLoading = false;
            _error = errorResponse['error'];
          });
        }
        print('Failed to fetch data. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<String> callSecondApi(String artistId) async {

    String apiUrl;

    // Choose the correct API URL based on whether it's a team or an individual artist
    if (widget.isteam == 'true') {
      apiUrl = '${Config().apiDomain}/team/booking-date/$artistId';
    } else {
      apiUrl = '${Config().apiDomain}/artist/booking-date/$artistId';
    }

    // String apiUrl = '${Config().apiDomain}/artist/booking-date/$artistId';
    // print('Calling availability API: $apiUrl');

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        // Check status from response
        String status = responseData['status'];

        switch (status) {
          case 'unavailable':
            return 'Not Available';

          case 'available':
            return 'Available for Bookings';

          case 'has_bookings':
            List<dynamic> bookingDates = responseData['data'];
            if (bookingDates.isEmpty) {
              return 'Available for Bookings';
            }
            return 'Booked On: ${bookingDates.join(', ')}';

          default:
            print('Unexpected status: $status');
            return 'Unable to fetch availability';
        }
      } else if (response.statusCode == 404) {
        print('Artist not found');
        return 'Artist not found';
      } else {
        print('Failed to fetch availability. Status code: ${response.statusCode}');
        print('Error response: ${response.body}');
        return 'Unable to fetch availability';
      }
    } catch (e) {
      print('Error calling availability API: $e');
      return 'Unable to fetch availability';
    }
  }

  Future<String> fetchAvailabilityStatus() async {

    String apiUrl;

    // Choose the correct API URL based on whether it's a team or an individual artist
    if (widget.isteam == 'true') {
      apiUrl = '${Config().apiDomain}/artist/team_info/${widget.artist_id}';
    } else {
      apiUrl = '${Config().apiDomain}/artist/info/${widget.artist_id}';
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
        Map<String, dynamic> responseData = json.decode(response.body);

        int status = responseData['data']['attributes']['booked_status'];
        print('status is $status ');

        if (status == 0) {
          return await callSecondApi(widget.artist_id);
          return 'Available for Bookings';
        } else   {
          // Call the second API if status is 1 and return its result directly

          return 'Not Available';
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        return 'Error fetching availability status';
      }
    } catch (e) {
      print('Error fetching data: $e');
      return 'Error fetching availability status';
    }
  }


  Future<List<dynamic>> teamMembersFromBackend() async {
    String apiUrl = '${Config().apiDomain}/artist/team_member/${widget.artist_id}';
    // print(apiUrl);

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);
        print('team members aress $responseData');


        // Assuming responseData contains a list of team members
        // List<dynamic> teamMembers = responseData['data']['team_members'];
        return responseData;
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        return []; // Return an empty list if there's an error
      }
    } catch (e) {
      print('Error fetching data: $e');
      return []; // Return an empty list in case of an exception
    }
  }





  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;



    // Function to fetch the special message from the backend
    Future<String> fetchSpecialMessage() async {
      // Simulated delay to mimic network request
      await Future.delayed(Duration(seconds: 2));

      // Simulated data fetched from the backend
      String specialMessage = 'Thank you for hosting! We are excited to be part of your event.';

      // Return the fetched special message
      return specialMessage;
    }


    Widget buildAvailabilityText(String status, {List<String>? bookedDates}) {
      Color lightColor;

      // Determine the lightColor based on the status.
      switch (status) {
        case 'Available for Bookings':
          lightColor = Colors.green;
          break;
        case 'Booked For Today':
          lightColor = Colors.orange;
          break;
        case 'Not Available':
          lightColor = Colors.red;
          break;
        default:
          lightColor = Colors.yellow;
      }

      // Safely handle bookedDates (null or empty).
      String statusText = (bookedDates != null && bookedDates.isNotEmpty)
          ? 'Not Available on: ${bookedDates.join(', ')}'
          : status;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
        crossAxisAlignment: CrossAxisAlignment.center, // Align content vertically in the center
        children: [
          Container(
            margin: EdgeInsets.only(right: 8), // Space between icon and text
            width: 12 * fem,
            height: 12 * fem,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lightColor,
              boxShadow: [
                BoxShadow(
                  color: lightColor.withOpacity(0.5),
                  spreadRadius: 3 * fem,
                  blurRadius: 7 * fem,
                  offset: Offset(0, 0), // Adjusts shadow position
                ),
              ],
            ),
          ),
          // Use Flexible to prevent overflow and align text properly.
          Flexible(
            child: Text(
              statusText,
              textAlign: TextAlign.center, // Center the text within its space
              style: TextStyle(
                fontSize: 16 * fem,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              softWrap: true, // Allow text to wrap if necessary
            ),
          ),
        ],
      );
    }


    return Scaffold(
      appBar: AppBar(title: Text('Artist Profile',style:
      TextStyle(color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 22*fem),),
        leading: IconButton(color: Colors.black,
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            // Use Navigator.pop() to close the current screen (Scene2) and go back to the previous screen (Scene1)
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Container(
            width: double.infinity,
            height: 1950*fem,
            decoration: BoxDecoration (
              color: Color(0xffffffff),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Container(
                    // autogroupw2njBkj (JkS1Ti6a5oTyiELwzGW2nj)
                    margin: EdgeInsets.fromLTRB(16*fem, 16*fem, 5*fem, 11.5*fem),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: double.infinity,
                          margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 12 * fem),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(9.0), // Set the radius to make the corners round
                                child: Container(
                                  width: 115 * fem,
                                  height: 150 * fem,
                                  color: Colors.grey[200], // Placeholder color
                                  child: Image.network(
                                    profilePhoto,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(17*fem,0*fem, 0*fem, 10*fem),
                                padding: EdgeInsets.fromLTRB(0*fem, 5*fem, 0*fem, 0*fem),
                                // depth4frame1YUo (15:2131)
                                width:220*fem,
                                height: 150*fem,
                                child: Column(  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // FutureBuilder to fetch and display name
                                    Text(
                                      artistName ?? teamName ?? '', // Use the artistName variable directly
                                      style: TextStyle(
                                        fontSize: 20 * ffem,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),


                                    // FutureBuilder to fetch and display role (e.g., Artist)
                                    Text(
                                      teamRole ?? '', // Use the artistRole variable directly
                                      style: TextStyle(
                                        fontSize: 17 * ffem,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff964f66),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4*fem,
                                    ),

                                    // FutureBuilder to fetch and display ratings
                                    Row(
                                      children: [
                                        Text(
                                          'Rating:  $avg/5', // Static text
                                          style: TextStyle(
                                            fontSize: 17 * ffem,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          artistRatings ?? '', // Use the artistRatings variable directly
                                          style: TextStyle(
                                            fontSize: 17 * ffem,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),

                                    // FutureBuilder to fetch and display price per hour
                                    Row(
                                      children: [
                                        Text(
                                          'Event Price: ₹ ',
                                          style: TextStyle(
                                            fontSize: 17 * ffem,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          artistPrice ?? '',
                                          style: TextStyle(
                                            fontSize: 17 * ffem,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 8), // Add some spacing

                                      ],
                                    ),
                                    Text(
                                      '(Includes taxes & travel charges)', // Static text
                                      style: TextStyle(
                                        fontSize: 15 * ffem,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),


                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder<String>(
                          future: _availabilityStatusFuture, // Use the cached future
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Show loading indicator
                            } else if (snapshot.hasData) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0),
                                child: buildAvailabilityText(snapshot.data!, bookedDates: bookedDates), // Use the fetched availability status
                              );
                            } else {
                              return Text(
                                'Error fetching availability status',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              );
                            }
                          },
                        ),

                        SizedBox(height: 15 * fem),

                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 15, bottom: 25),
                          child: ElevatedButton(
                            onPressed: ()  async{
                              String? isSignedUp=await storage.read(key: 'user_signup');
                              print('mohit is cool $isSignedUp');
                              if(isSignedUp=='true') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        booking_artist(
                                            artist_id: widget.artist_id,
                                            isteam: widget.isteam
                                        ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PhoneNumberInputScreen(
                                            artist_id: widget.artist_id,
                                            isteam: widget.isteam
                                        ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,  // Remove default padding to apply gradient correctly
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9 * fem),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xffe5195e), Color(0xffd11b4f)],  // Adjusted the darker color to be lighter
                                  begin: Alignment.centerLeft,  // Start from the left side
                                  end: Alignment.centerRight,   // End at the right side
                                ),
                                borderRadius: BorderRadius.circular(9 * fem),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16 * fem,
                                  vertical: 12 * fem,
                                ),
                                constraints: BoxConstraints(minWidth: double.infinity, minHeight: 14 * fem),
                                child: Center(
                                  child: Text(
                                    'Book Artist',
                                    style: SafeGoogleFont(
                                      'Be Vietnam Pro',
                                      fontSize: 17 * ffem,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5 * ffem / fem,
                                      letterSpacing: 0.2399999946 * fem,
                                      color: Color(0xffffffff),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (widget.isteam == 'true')
                        // Team members section - only show if data exists
                          FutureBuilder<List<dynamic>>(
                            future: _teamMembersFuture, // Use cached future
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: CircularProgressIndicator(), // Show loading indicator
                                );
                              } else if (snapshot.hasError) {
                                return SizedBox.shrink(); // Hide section on error
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return SizedBox.shrink(); // Hide entire section when no data
                              }

                              List<dynamic> teamMembers = snapshot.data!;

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Team Members:',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff1c0c11),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: teamMembers.length,
                                      itemBuilder: (context, index) {
                                        final member = teamMembers[index];
                                        return Container(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Container(
                                                  width: 70,
                                                  height: 85,
                                                  color: Colors.grey[200],
                                                  child: member['profile_photo'] != null
                                                      ? Image.network(
                                                    member['profile_photo'],
                                                    fit: BoxFit.cover,
                                                  )
                                                      : Icon(Icons.person),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    member['member_name'] ?? 'Unknown',
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xff1c0c11),
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    member['role'] ?? 'Unknown role',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
                                                      color: Color(0xff1c0c11),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),



                        Container(

                          margin: EdgeInsets.fromLTRB(0*fem, 15*fem, 0*fem, 4*fem),
                          child: Text(
                            'About',
                            style: SafeGoogleFont (
                              'Be Vietnam Pro',
                              fontSize: 22*ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.25*ffem/fem,
                              letterSpacing: -0.3300000131*fem,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 12*fem,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row for Skills
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Expanded(
                                  child: Wrap(
                                    spacing: 10.0,
                                    runSpacing: 10.0,
                                    children: demoSkills.map((skill) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 9.0),
                                        decoration: BoxDecoration(
                                          color: Color(0xfff5e1e5) ,
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Text(
                                          skill,
                                          style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.0*fem),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon on the left
                                Icon(
                                  Icons.access_alarms, // Use any icon that fits your design
                                  size: 24.0,
                                  color: Colors.grey, // Adjust color to match your theme
                                ),
                                SizedBox(width: 8.0), // Space between icon and text
                                // Subheading for Experience
                                Text(
                                  'Event Duration: ',
                                  style: TextStyle(
                                    fontSize: 19.0 * fem,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                // Display Experience from backend
                                Expanded( // Ensures proper wrapping of text
                                  child: Text(
                                     '2 - 2.5 hours',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0*fem),

                            // Row for Experience
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon on the left
                                Icon(
                                  Icons.work, // Use any icon that fits your design
                                  size: 24.0,
                                  color: Colors.grey, // Adjust color to match your theme
                                ),
                                SizedBox(width: 8.0), // Space between icon and text
                                // Subheading for Experience
                                Text(
                                  'Experience : ',
                                  style: TextStyle(
                                    fontSize: 19.0 * fem,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                // Display Experience from backend
                                Expanded( // Ensures proper wrapping of text
                                  child: Text(
                                    trimmedArtistAbout?? trimmedTeamAbout ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0*fem),
                            // Row for previous bookings
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon on the left
                                Icon(
                                  Icons.event, // Use any icon that fits your design
                                  size: 24.0,
                                  color: Colors.grey, // Adjust color to match your theme
                                ),
                                SizedBox(width: 8.0), // Space between icon and text
                                // Subheading for Experience
                                Text(
                                  'Previous Bookings : ',
                                  style: TextStyle(
                                    fontSize: 19.0 * fem,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                // Display Experience from backend
                                Expanded( // Ensures proper wrapping of text
                                  child: Text(
                                    artist_previous ?? team_previous ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0*fem),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon on the left
                                Icon(
                                  Icons.location_on_outlined, // Use any icon that fits your design
                                  size: 24.0,
                                  color: Colors.grey, // Adjust color to match your theme
                                ),
                                SizedBox(width: 8.0), // Space between icon and text
                                // Subheading for Experience
                                Text(
                                  'Base Location: ',
                                  style: TextStyle(
                                    fontSize: 19.0 * fem,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                // Display Experience from backend
                                Expanded( // Ensures proper wrapping of text
                                  child: Text(
                                    artist_address ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0*fem),

                            // Row for Sound System
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon on the left
                                Icon(
                                  Icons.speaker, // Choose an appropriate icon
                                  size: 24.0,
                                  color: Colors.grey, // Adjust color to fit your theme
                                ),
                                SizedBox(width: 8.0 * fem), // Space between icon and text
                                // Text content for the row
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Subheading for Sound System
                                      Text(
                                        'Sound System:',
                                        style: TextStyle(
                                          fontSize: 19.0 * fem,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 5 * fem), // Optional spacing for better readability
                                      // Display Yes/No for Sound System
                                      Text(
                                        hasSoundSystem != null && hasSoundSystem!
                                            ? 'Yes'
                                            : 'Managed by PrimeStage',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17.0 * fem,
                                          color: hasSoundSystem != null ? Colors.green : Colors.pink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),



                        // Container(
                        //
                        //           margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 28*fem),
                        //           width: 2222*fem,
                        //           height: 100,
                        //           child: artistAboutText != null
                        //               ? Text(
                        //             artistAboutText!,
                        //             style: TextStyle(
                        //               fontSize: 16 * ffem,
                        //               fontWeight: FontWeight.w400,
                        //               height: 1.5 * ffem / fem,
                        //               color: Color(0xff1c0c11),
                        //             ),
                        //           )
                        //               : Text(
                        //             'Error fetching about data',
                        //             style: TextStyle(
                        //               fontSize: 16 * ffem,
                        //               fontWeight: FontWeight.w400,
                        //               color: Colors.red,
                        //             ),
                        //           ),
                        //
                        //         ),

                      ],
                    ),
                  ),


                  Container(
                    margin: EdgeInsets.fromLTRB(7 * fem, 15, 0 * fem, 0),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0 * fem ,0,0,0),
                          child: Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: 22 * ffem,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 12 * fem),
                        // GridView builder for the gallery
                        SizedBox(
                          height: 200 * fem,

                          child:ListView.builder(
                            scrollDirection: Axis.horizontal, // Set scroll direction to horizontal
                            itemCount: imagePathsFromBackend.length, // Total count
                            itemBuilder: (context, index) {
                              if (index < imagePathsFromBackend.length) {
                                // Display images in the carousel
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to fullscreen view on image tap
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenView(
                                          imagePath: imagePathsFromBackend[index],
                                          allImages: imagePathsFromBackend,
                                          initialIndex: index,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 160 * fem, // Set width of each item in the carousel
                                    margin: EdgeInsets.symmetric(horizontal: 5.5 * fem), // Add margin between items
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(9 * fem), // Example border radius
                                      child: Image.network(
                                        imagePathsFromBackend[index], // Network image path
                                        fit: BoxFit.cover, // Fit the image within the container
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                // Placeholder when index exceeds the image list
                                return Container(
                                  width: 150 * fem, // Placeholder width
                                  margin: EdgeInsets.symmetric(horizontal: 5.5 * fem), // Placeholder margin
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9 * fem), // Example border radius
                                    color: Colors.grey[200], // Placeholder color
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  //VideoPathsFromBackend.length
                  Container(
                    margin: EdgeInsets.fromLTRB(7 * fem, 25*fem, 0 * fem, 0),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0 * fem ,0,0,0),
                          child: Text(
                            'Video Samples',
                            style: TextStyle(
                              fontSize: 22 * ffem,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 12 * fem),
                        // GridView builder for the gallery
                        // Usage in ListView
                        SizedBox(
                          height: 200 * fem,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: VideoPathsFromBackend.length,
                            itemBuilder: (context, index) {
                              if (index < VideoPathsFromBackend.length) {
                                return CarouselVideoItem(
                                  videoUrl: VideoPathsFromBackend[index],
                                  thumbnailUrl: index < thumbnailPathsFromBackend.length
                                      ? thumbnailPathsFromBackend[index]
                                      : '',
                                  fem: fem,
                                );
                              } else {
                                return Container(
                                  width: 160 * fem,
                                  margin: EdgeInsets.symmetric(horizontal: 5.5 * fem),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9 * fem),
                                    color: Colors.grey[200],
                                  ),
                                );
                              }
                            },
                          ),
                        ),

                      ],
                    ),
                  ),





                  Container(
                    padding: EdgeInsets.fromLTRB(16, 30, 16, 11.5),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 23.5),
                          child: Text(
                            'Message for the Host',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 32),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xffe8d1d6)),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: 38, // Minimum height remains 38
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: artistSpecialMessage != null
                                  ? Text(
                                artistSpecialMessage!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              )
                                  : Center(
                                child: Text(
                                  'Error fetching special message',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),


// Reviews section heading
                        Text(
                          'Reviews',
                          style: SafeGoogleFont(
                            'Epilogue',
                            fontSize: 22 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.25 * ffem / fem,
                            letterSpacing: -0.33 * fem,
                            color: Color(0xff1c0c11),
                          ),
                        ),
                        SizedBox(height: 10 * fem),

// Add the ReviewsSection or loading/error widgets here
                        _isLoading
                            ? Center(
                          child: CircularProgressIndicator(), // Show loader while fetching data
                        )
                            : _error != null
                            ? Center(
                          child: Text(
                            "No reviews Yet",
                            style: TextStyle(color: Colors.red,
                                fontSize: 22 * ffem),
                          ),
                        )
                            : ReviewsSection(
                          averageRating: avg?.toDouble() ?? 0.0, // Safely provide default value
                          totalReviews: count ?? 0, // Safely provide default value
                          isteam :widget.isteam ?? '',
                          ratingDistribution: {
                            5: five?.toDouble() ?? 0.0, // Safely provide default value
                            4: four?.toDouble() ?? 0.0, // Safely provide default value
                            3: three?.toDouble() ?? 0.0, // Safely provide default value
                            2: two?.toDouble() ?? 0.0, // Safely provide default value
                            1: one?.toDouble() ?? 0.0, // Safely provide default value
                          },
                          artist_id: widget.artist_id,
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 5 * fem, top: 20 * fem, right: 5 * fem, bottom: 45 * fem),
                          child: ElevatedButton(
                            onPressed: ()  async{
                              String? isSignedUp=await storage.read(key: 'user_signup');
                              print('mohit is cool $isSignedUp');
                              if(isSignedUp =='true') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        booking_artist(
                                            artist_id: widget.artist_id,
                                            isteam: widget.isteam
                                        ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PhoneNumberInputScreen(
                                            artist_id: widget.artist_id,
                                            isteam: widget.isteam
                                        ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero, // Removed default padding to apply gradient correctly
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12 * fem),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xffe5195e), Color(0xffd11b4f)], // Gradient from light to slightly darker
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12 * fem),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16 * fem,
                                  vertical: 12 * fem,
                                ),
                                constraints: BoxConstraints(minWidth: double.infinity, minHeight: 14 * fem),
                                child: Center(
                                  child: Text(
                                    'Book Artist',
                                    style: SafeGoogleFont(
                                      'Be Vietnam Pro',
                                      fontSize: 16 * ffem,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5 * ffem / fem,
                                      letterSpacing: 0.2399999946 * fem,
                                      color: Color(0xffffffff),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],),
            ),
          ),),),);
  }
}

// Fullscreen view for images
class FullScreenView extends StatefulWidget {
  final String imagePath;
  final List<String> allImages;
  final int initialIndex;

  FullScreenView({
    required this.imagePath,
    required this.allImages,
    required this.initialIndex,
  });

  @override
  _FullScreenViewState createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${currentIndex + 1}/${widget.allImages.length}',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.allImages.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: Image.network(
                widget.allImages[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 8),
                        Text('Image failed to load',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}



class VideoThumbnail extends StatelessWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final double fem;
  final VoidCallback onTap;

  const VideoThumbnail({
    Key? key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.fem,
    required this.onTap,
  }) : super(key: key);

  // Extract YouTube video ID
  String? getYoutubeId(String url) {
    return YoutubePlayer.convertUrlToId(url);
  }

  @override
  Widget build(BuildContext context) {
    // Check if this is a YouTube video
    final youtubeId = getYoutubeId(videoUrl);
    final isYouTube = youtubeId != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170 * fem,
        margin: EdgeInsets.symmetric(horizontal: 5.0 * fem),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9 * fem),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // For YouTube videos, use YouTube thumbnail
              if (isYouTube)
                Image.network(
                  'https://img.youtube.com/vi/$youtubeId/0.jpg',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black87,
                      height: double.infinity,
                      width: double.infinity,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.black54,
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                )
              // For non-YouTube videos, use provided thumbnail or fallback
              else if (thumbnailUrl.isNotEmpty)
                Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black87,
                      height: double.infinity,
                      width: double.infinity,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.black54,
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  color: Colors.black87,
                  height: double.infinity,
                  width: double.infinity,
                ),

              // Play icon
              Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 40 * fem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// // Improved CarouselVideoItem with lazy loading
class CarouselVideoItem extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final double fem;

  const CarouselVideoItem({
    Key? key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.fem,
  }) : super(key: key);

  @override
  CarouselVideoItemState createState() => CarouselVideoItemState();
}

// Update the CarouselVideoItem's onTap method to pass all required data
class CarouselVideoItemState extends State<CarouselVideoItem> {
  bool isVideoInitialized = false;
  late VideoPlayerController videoController;
  bool isVisible = false;

  @override
  void dispose() {
    if (isVideoInitialized) {
      videoController.dispose();
    }
    super.dispose();
  }

  void _initializeVideo() {
    // Only initialize if not already initialized
    if (!isVideoInitialized) {
      setState(() {
        isVideoInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoThumbnail(
      videoUrl: widget.videoUrl,
      thumbnailUrl: widget.thumbnailUrl,
      fem: widget.fem,
      onTap: () {
        // Get the VideoList parent widget's data
        // Since we can't directly access parent widget's state, we'll use a more direct approach

        // This code assumes we're in a ListView.builder context
        // We'll need to gather this data from the parent widget

        // Find the nearest ancestor that contains the ListView.builder
        final parentContext = context.findAncestorWidgetOfExactType<ListView>();

        // Get the data from the parent context
        // Since we can't directly access the VideoPathsFromBackend and thumbnailPathsFromBackend,
        // we'll pass the current video and get the adjacent videos from the parent

        // Here's a simpler approach that doesn't rely on external variables:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenVideoView(
              videoUrl: widget.videoUrl,
              allVideos: _getAdjacentVideos(context),
              allThumbnails: _getAdjacentThumbnails(context),
              initialIndex: 0, // Current video will be at index 0
            ),
          ),
        );
      },
    );
  }

  // Helper method to get adjacent videos
  List<String> _getAdjacentVideos(BuildContext context) {
    // This is a simplified approach
    // In a real-world scenario, you'd have a more robust way to get these values

    // For now, we'll just return the current video URL as a single-item list
    // This will still allow the carousel to work, but with only one video
    return [widget.videoUrl];
  }

  // Helper method to get adjacent thumbnails
  List<String> _getAdjacentThumbnails(BuildContext context) {
    // Similar to above, this is a simplified approach
    return [widget.thumbnailUrl];
  }
}



// Improved FullScreenVideoView with carousel functionality and landscape mode support
class FullScreenVideoView extends StatefulWidget {
  final String videoUrl;
  final List<String> allVideos;
  final List<String> allThumbnails;
  final int initialIndex;

  const FullScreenVideoView({
    Key? key,
    required this.videoUrl,
    required this.allVideos,
    required this.allThumbnails,
    required this.initialIndex,
  }) : super(key: key);

  @override
  FullScreenVideoViewState createState() => FullScreenVideoViewState();
}

class FullScreenVideoViewState extends State<FullScreenVideoView> {
  late PageController _pageController;
  late int currentIndex;

  // Map to store controllers for each video
  final Map<int, VideoPlayerController> videoControllers = {};
  final Map<int, ChewieController?> chewieControllers = {};
  final Map<int, YoutubePlayerController?> youtubeControllers = {};
  final Map<int, bool> initializedStates = {};

  // Flag to track if we're in "virtual" landscape mode
  bool isVirtualLandscape = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);

    // Initialize the current video
    initializeVideo(currentIndex);

    // Pre-initialize the next video if it exists
    if (currentIndex + 1 < widget.allVideos.length) {
      initializeVideo(currentIndex + 1);
    }

    // Pre-initialize the previous video if it exists
    if (currentIndex - 1 >= 0) {
      initializeVideo(currentIndex - 1);
    }
  }

  bool isYouTube(String url) {
    return YoutubePlayer.convertUrlToId(url) != null;
  }

  void initializeVideo(int index) {
    if (initializedStates[index] == true) return;

    final String videoUrl = widget.allVideos[index];
    final bool isYoutubeVideo = isYouTube(videoUrl);

    if (isYoutubeVideo) {
      youtubeControllers[index] = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(videoUrl)!,
        flags: YoutubePlayerFlags(
          autoPlay: index == widget.initialIndex,
          mute: false,
          forceHD: true,
        ),
      );
      initializedStates[index] = true;
    } else {
      videoControllers[index] = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      videoControllers[index]!.initialize().then((_) {
        if (mounted) {
          setState(() {
            chewieControllers[index] = ChewieController(
              videoPlayerController: videoControllers[index]!,
              aspectRatio: videoControllers[index]!.value.aspectRatio,
              autoPlay: index == currentIndex,
              looping: false,
              allowMuting: true,
              allowPlaybackSpeedChanging: true,
              allowFullScreen: false, // We'll handle our own fullscreen mode
            );
            initializedStates[index] = true;
          });
        }
      }).catchError((error) {
        print("Error initializing video at index $index: $error");
        initializedStates[index] = false;
      });
    }
  }

  void pauseAllVideosExcept(int activeIndex) {
    videoControllers.forEach((index, controller) {
      if (index != activeIndex && controller.value.isPlaying) {
        controller.pause();
      }
    });

    youtubeControllers.forEach((index, controller) {
      if (index != activeIndex && controller != null) {
        controller.pause();
      }
    });
  }

  void handlePageChange(int newIndex) {
    setState(() {
      currentIndex = newIndex;
    });

    // Pause all other videos
    pauseAllVideosExcept(newIndex);

    // Initialize the next video if it exists and hasn't been initialized yet
    if (newIndex + 1 < widget.allVideos.length && initializedStates[newIndex + 1] != true) {
      initializeVideo(newIndex + 1);
    }

    // Initialize the previous video if it exists and hasn't been initialized yet
    if (newIndex - 1 >= 0 && initializedStates[newIndex - 1] != true) {
      initializeVideo(newIndex - 1);
    }

    // Play the current video if it's initialized
    if (initializedStates[newIndex] == true) {
      if (isYouTube(widget.allVideos[newIndex])) {
        youtubeControllers[newIndex]?.play();
      } else if (chewieControllers[newIndex] != null) {
        videoControllers[newIndex]?.play();
      }
    }
  }

  void toggleVirtualLandscape() {
    setState(() {
      isVirtualLandscape = !isVirtualLandscape;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    // Dispose all controllers
    videoControllers.forEach((index, controller) {
      controller.dispose();
    });

    chewieControllers.forEach((index, controller) {
      controller?.dispose();
    });

    youtubeControllers.forEach((index, controller) {
      controller?.dispose();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isVirtualLandscape
          ? null  // Hide app bar in landscape mode
          : AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '${currentIndex + 1}/${widget.allVideos.length}',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // This is the main video container that rotates
            Center(
              child: isVirtualLandscape
                  ? RotatedBox(
                quarterTurns: 1,  // Rotate 90 degrees clockwise
                child: Container(
                  width: screenHeight,  // Swap width and height
                  height: screenWidth,
                  child: _buildVideoPlayer(),
                ),
              )
                  : _buildVideoPlayer(),
            ),
            // Rotation toggle button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Icon(
                  isVirtualLandscape ? Icons.screen_rotation : Icons.stay_current_portrait,
                  color: Colors.white,
                ),
                onPressed: toggleVirtualLandscape,
              ),
            ),
            // Back button when in landscape mode (app bar is hidden)
            if (isVirtualLandscape)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.allVideos.length,
      onPageChanged: handlePageChange,
      scrollDirection: isVirtualLandscape ? Axis.vertical : Axis.horizontal,  // Changed to Axis.vertical and Axis.horizontal
      itemBuilder: (context, index) {
        final bool isYoutubeVideo = isYouTube(widget.allVideos[index]);
        final bool isInitialized = initializedStates[index] == true;

        // If video is not initialized, show thumbnail with loading indicator
        if (!isInitialized) {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Show thumbnail as background while loading
                if (index < widget.allThumbnails.length && widget.allThumbnails[index].isNotEmpty)
                  Image.network(
                    widget.allThumbnails[index],
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.black);
                    },
                  ),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          );
        }

        // Show the video player
        return Center(
          child: isYoutubeVideo
              ? YoutubePlayer(controller: youtubeControllers[index]!)
              : Chewie(controller: chewieControllers[index]!),
        );
      },
    );
  }
}


// // VideoCarousel.dart
// class VideoCarousel extends StatelessWidget {
//   final List<String> VideoPathsFromBackend;
//   final double fem;
//
//   const VideoCarousel({
//     Key? key,
//     required this.VideoPathsFromBackend,
//     required this.fem,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 200 * fem,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: VideoPathsFromBackend.length,
//         itemBuilder: (context, index) {
//           if (index < VideoPathsFromBackend.length) {
//             return CarouselVideoItem(
//               videoUrl: VideoPathsFromBackend[index],
//               fem: fem,
//             );
//           } else {
//             return Container(
//               width: 160 * fem,
//               margin: EdgeInsets.symmetric(horizontal: 5.5 * fem),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(9 * fem),
//                 color: Colors.grey[200],
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }




class ReviewsSection extends StatelessWidget {
  late String artist_id;
  final num averageRating;
  final int totalReviews;
  final String isteam;
  final Map<int, double> ratingDistribution; // Star rating and its percentage

  ReviewsSection({
    required this.averageRating,
    required this.totalReviews,
    required this.isteam,
    required this.ratingDistribution,
    required this.artist_id
  });

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390; // Your base width for scaling
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average Rating Row
        Row(
          children: [
            Icon(Icons.star, color: Color(0xFFFFB300), size: 30 * fem), // Scaled icon size
            SizedBox(width: 8 * fem),
            Text(
              averageRating.toStringAsFixed(1),
              style: TextStyle(fontSize: 24 * fem, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8 * fem),
            Text(
              " ($totalReviews reviews)",
              style: TextStyle(
                color: Colors.black,
                fontSize: 17 * fem,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 16 * fem),

        // Rating Distribution (5-star, 4-star, etc.)
        Column(
          children: List.generate(5, (index) {
            int starCount = 5 - index;
            return _buildRatingLine(starCount, ratingDistribution[starCount] ?? 0.0, fem);
          }),
        ),

        SizedBox(height: 16 * fem),

        // Button to see all reviews
        Center(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to a page that shows all reviews
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllReviewsPage(artist_id : artist_id, isteam: isteam ),
                ),
              );
            },
            child: Text(
              "See All Reviews",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 16 * fem,
              ),
            ),
          ),
        ),
      ],
    );
  }

// Helper function to build rating lines
  Widget _buildRatingLine(int starCount, double percentage, double fem) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(5.0 * fem, 0, 0, 0),
          child: Text(
            "$starCount star",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18 * fem, // Scale the font size
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8 * fem),
        Padding(
          padding: EdgeInsets.fromLTRB(12.0 * fem, 0, 0, 0),
          child: Container(
            width: 270 * fem, // Scale the width
            height: 9 * fem,  // Scale the height
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5 * fem), // Scale border radius
              child: LinearProgressIndicator(
                value: percentage, // Percentage of reviews for this star
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xffe5195e)),
              ),
            ),
          ),
        ),
      ],
    );
  }}

class AllReviewsPage extends StatefulWidget {

  late String  artist_id;
  late String  isteam;
  AllReviewsPage( { required this.artist_id , required this.isteam} );
  // Simulating reviews fetched from backend
  @override
  _AllReviewsPageState createState() => _AllReviewsPageState();

}

class _AllReviewsPageState extends State<AllReviewsPage>{



  List<Map<String, dynamic>> reviews = [
  ];
  @override
  void initState() {
    super.initState();
    // Call the single initialization function

    rating();

  }

  Future<void> sendUserIdsAndFetchNames(List<Map<String, dynamic>> reviews) async {
    // Collect user IDs from reviews
    List<int?> userIds = reviews
        .map((review) => review['user_id'] as int?)
        .where((id) => id != null) // Filter out null user_ids
        .toList();
    print('user idfs are $userIds');
    // API URL for sending user IDs and fetching names
    final String apiUrl = '${Config().apiDomain}/review/usernames';

    // Create the request body
    Map<String, dynamic> body = {
      'user_ids': userIds,
    };

    try {
      // Make the POST request with a timeout to fetch user names
      final response = await http
          .post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 10)); // 10 seconds timeout

      // Check for success
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        // Get the list of user names
        List<dynamic> userNames = responseData['names'] ?? [];
        print('namwe are $userNames');

        // Add names to reviews, ensuring fallback for null names
        for (int i = 0; i < reviews.length; i++) {
          reviews[i]['user_name'] = (i < userNames.length && userNames[i] != null)
              ? userNames[i].toString()
              : 'Unknown User'; // Fallback if name is null
        }

        print('Names fetched successfully: $userNames');
      } else {
        print('Failed to fetch user names. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error fetching names: $e');
    }
  }

  bool isLoading = true; // Add a loading flag

  Future<void> rating() async {
    setState(() {
      isLoading = true; // Set loading to true when the function starts
    });
    String apiUrl;
print(widget.isteam);
    if(widget.isteam=="false") {
      apiUrl = '${Config().apiDomain}/review/${widget.artist_id}';
    }else{
      apiUrl = '${Config().apiDomain}/review/team/${widget.artist_id}';
    }
    print(apiUrl);

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        // Decode the raw JSON response
        List<dynamic> rawReviews = json.decode(response.body);

        // Convert the dynamic list to a List<Map<String, dynamic>>
        reviews = List<Map<String, dynamic>>.from(rawReviews);

        try {
          await sendUserIdsAndFetchNames(reviews);
        } catch (e) {
          print('Error while sending user IDs and fetching names: $e');
        }

        setState(() {
          reviews = rawReviews.cast<Map<String, dynamic>>();
          isLoading = false; // Stop loading after successful data fetching
        });
      } else {
        print('Failed to fetch data. Status code: ${response.body}');
        setState(() {
          isLoading = false; // Stop loading even in failure case
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false; // Stop loading even in case of exception
      });
    }
  }



  // Star rating widget
  Widget buildStarRating(int rating) {
    double baseWidth = 390;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Color(0xFFFFB300),
          size: 22,
        );
      }),
    );
  }

  // Single review item widget
  Widget buildReviewItem(Map<String, dynamic> review, double fem, double ffem, BuildContext context) {
    String reviewText = review['review_text'] ?? '';
    List<String> words = reviewText.split(' '); // Split by spaces

    String heading = words.isNotEmpty ? words[0] : '';
    String description = words.length > 1 ? words.sublist(1).join(' ') : ''; // Join the rest of the words

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15 * fem, horizontal: 16 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular profile picture or default grey icon
              CircleAvatar(
                radius: 26 * fem,
                backgroundColor: Colors.grey[200], // Grey background
                child: ClipOval(
                  child: review['profile'] != null && review['profile'].isNotEmpty
                      ? Image.network(
                    review['profile'],
                    width: 52 * fem, // Size should match the radius
                    height: 52 * fem,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to default icon if image fails to load
                      return Icon(
                        Icons.account_circle,
                        size: 52 * fem,
                        color: Colors.grey[400],
                      );
                    },
                  )
                      : Icon(
                    Icons.account_circle,
                    size: 52 * fem, // Matching size
                    color: Colors.grey[400],
                  ),
                ),
              ),
              SizedBox(width: 12 * fem),

              // Review content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // User's name from fetched data
                        Text(
                          review['user_name'] ?? 'Anonymous',
                          style: TextStyle(
                            fontSize: 17 * ffem,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        buildStarRating(review['rating']),
                      ],
                    ),
                    SizedBox(height: 4 * fem),

                    // Heading
                    Text(
                      heading,
                      style: TextStyle(
                        fontSize: 15 * ffem,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4 * fem),

                    // Review text
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15 * ffem,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10 * fem),

          // Review photo and video section (center-aligned)
          Padding(
            padding: const EdgeInsets.fromLTRB(70,0,0,0),
            child: Row(
              // Center-aligns the content horizontally
              children: [
                // Review photo section (display only if available)
                if (review['photo'] != null && review['photo'].isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      showMediaFullScreen(context, review['photo'], true);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        review['photo'],
                        width: 100, // Adjust as needed
                        height: 100, // Adjust as needed
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Handle error while loading review photo
                          return SizedBox(
                            height: 100,
                            width: 100,
                            child: Center(child: Text('Image not available')),
                          );
                        },
                      ),
                    ),
                  ),

                // // Review video section (display only if available)
                // if (review['photo'] != null && review['photo'].isNotEmpty)
                //   GestureDetector(
                //     onTap: () {
                //       showMediaFullScreen(context, review['photo'], false);
                //     },
                //     child: Container(
                //       width: 100, // Adjust size as needed
                //       height: 100, // Adjust size as needed
                //       decoration: BoxDecoration(
                //         color: Colors.black,
                //         image: DecorationImage(
                //           image: NetworkImage(review['photo']), // Thumbnail for video
                //           fit: BoxFit.cover,
                //         ),
                //       ),
                //       child: Icon(Icons.play_circle_filled, color: Colors.white, size: 40), // Play icon over video thumbnail
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Function to show the media (photo/video) in fullscreen
  void showMediaFullScreen(BuildContext context, String mediaUrl, bool isPhoto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaPage(mediaUrl: mediaUrl, isPhoto: isPhoto),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    double fem = MediaQuery.of(context).size.width / 390;
    double ffem = fem * 0.97;



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'All Reviews',
          style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            // Use Navigator.pop() to close the current screen (Scene2) and go back to the previous screen (Scene1)
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show a loader if reviews are not yet fetched
          : ListView.builder(
        itemCount: reviews.length, // Number of reviews from the backend
        itemBuilder: (context, index) {
          return buildReviewItem(reviews[index], fem, ffem,context);
        },
      ),
    );



  }


}

// Full screen media page (either photo or video)
class FullScreenMediaPage extends StatelessWidget {
  final String mediaUrl;
  final bool isPhoto;

  const FullScreenMediaPage({Key? key, required this.mediaUrl, required this.isPhoto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: isPhoto
            ? Image.network(
          mediaUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text('Image not available', style: TextStyle(color: Colors.white));
          },
        )
            : AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoThumbnail(videoUrl: mediaUrl,
            fem: MediaQuery.of(context).size.width / 390,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenVideoView(
                    videoUrl: mediaUrl, allVideos: [], allThumbnails: [], initialIndex:0,
                  ),
                ),
              );
            }, thumbnailUrl: '',), // Assuming you have a VideoPlayerWidget
        ),
      ),
    );
  }
}
