import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test1/page-1/page_0.3_artist_home.dart';
import 'package:test1/page-1/review.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../utils.dart';
import 'booked_artist.dart';
import 'booked_equipments.dart';

bool isCacheLoaded = false;
Map<String, List<dynamic>>? cachedData;
class UserBookings extends StatefulWidget {
  String? isteam;
   // Add this parameter
  
  UserBookings({this.isteam,});

  @override
  _UserBookingsState createState() => _UserBookingsState();
}

class _UserBookingsState extends State<UserBookings> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool isLoading = true;

  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBookings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _resetCache(); // Clear cache on app closure
    }
  }

  Future<void> _loadBookings({bool forceReload = false}) async {
    if (isCacheLoaded && !forceReload) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // First API call for bookings
      final bookingsResponse = await http.get(
          Uri.parse('${Config().apiDomain}/user/bookings/$userId')
      );

      // Second API call for equipment
      final equipmentsResponse = await http.get(
          Uri.parse('${Config().apiDomain}/show-equipments/$userId')
      );

      // Print raw responses for debugging
      print('Raw bookings response: ${bookingsResponse.body}');
      print('Raw equipment response: ${equipmentsResponse.body}');

      if (bookingsResponse.statusCode == 200 && equipmentsResponse.statusCode == 200) {
        // First try to decode without type casting to see the structure
        final rawBookings = json.decode(bookingsResponse.body);
        final rawEquipments = json.decode(equipmentsResponse.body);

        print('Decoded bookings type: ${rawBookings.runtimeType}');
        print('Decoded equipments type: ${rawEquipments.runtimeType}');

        // Now handle based on actual types
        setState(() {
          cachedData = {
            'bookings': (rawBookings as List).map((e) => Map<String, dynamic>.from(e)).toList(),
            'equipments': rawEquipments is List
                ? rawEquipments.map((e) => Map<String, dynamic>.from(e)).toList()
                : [rawEquipments], // If it's a single map, wrap it in a list
          };
          isCacheLoaded = true;
          isLoading = false;
        });
      } else {
        _handleError('Failed to load data');
      }
    } catch (e) {
      print('Error details: $e');  // Detailed error logging
      _handleError(e.toString());
    }
  }
  void _handleError(String message) {
    setState(() {
      isLoading = false;
    });
    print('Error: $message');
  }

  Future<String?> _getUserId() async {
    return await storage.read(key: 'user_id');
  }

  void _resetCache() {
    cachedData = null;
    isCacheLoaded = false;
  }

  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }


  // Fetch artist bookings and cache the data
  Future<bool> fetchArtistBooking(int artistId) async {
    String apiUrl;
    if (widget.isteam == 'true') {
      apiUrl = '${Config().apiDomain}/featured/team/$artistId';
    } else {
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

        // if (mounted) {
        //   for (var userData in userDataList) {
        //     phoneNumber = userData['manager_phone_number'] ?? '';
        //
        //   }
        // }

        return true;
      } else {
        print('Failed to fetch user information. Status code: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error fetching user information: $e');
      return false;
    }
  }

  // Function to initiate a phone call
  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Widget _buildRequestCard(String Category, String booking_date, String Time,
      int booking_id, int artist_id, String isteam,  int index) {
    double baseWidth = 390;
    final bookings = cachedData?['bookings'] ?? [];

    double fem = MediaQuery
        .of(context)
        .size
        .width / baseWidth;
    double ffem = fem * 0.97;

    final booking = bookings[index];
    phoneNumber = booking['manager_phone_number'] ?? '';
    final status = booking['status']; // Get the status from the booking object
    double progress = 0.0;

    // Set progress based on booking status
    if (status == 0) {
      progress = 0.33; // Booking Initiated
    } else if (status == 1) {
      progress = 0.66; // Artist Response accepted
    } else if (status == 2) {
      progress = 0.0; // Event rejected by artist
    } else if (status == 3) {
      progress = 1.0; // completed, no progress
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              Booked(BookingId: booking_id.toString(),
                  artistId: artist_id.toString(),
                  isteam: isteam)),
        );
      },
      child: Stack(
        children: [
          Card(
            color: Color(0xFF292938),
            margin: EdgeInsets.fromLTRB(5, 0, 5, 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(23, 16, 25, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking for $Category',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('At:  $Time',
                    style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFFB4B4DF)
                    ),
                  ),
                  SizedBox(height: 5),
                  Text('On Date:  $booking_date,',
                    style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFFB4B4DF)
                    ),
                  ),
                  SizedBox(height: 16),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0), // Adjust corner radius as needed
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffe5195e)),
                          minHeight: 8,
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * progress - 30,
                        top: -4,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.black,
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Initiated',
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Artist Response',
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Completion',
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
              status != 3
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 3, right: 3),
                    child: ElevatedButton(
                      onPressed: () async {
                        bool wait = await fetchArtistBooking(artist_id);
                        if (wait) {
                          _makePhoneCall(phoneNumber ?? '');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * fem),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 6.5 * fem,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Call Event Manager',
                          style: SafeGoogleFont(
                            'Be Vietnam Pro',
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w700,
                            height: 1.5 * ffem / fem,
                            letterSpacing: 0.24 * fem,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 3, right: 3),
                    child: ElevatedButton(
                      onPressed: () {
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * fem),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 6.5 * fem,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Booking Completed',
                          style: SafeGoogleFont(
                            'Be Vietnam Pro',
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w700,
                            height: 1.5 * ffem / fem,
                            letterSpacing: 0.24 * fem,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 18, // Adjust the distance from the top of the card
            right: 10, // Adjust the distance from the right of the card
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

  Widget build(BuildContext context) {
    super.build(context);
    final bookings = cachedData?['bookings'] ?? [];
    final equipments = cachedData?['equipments'] ?? [];

    // Sort bookings by creation date in descending order
    bookings.sort((a, b) {
      DateTime createdAtA = DateTime.parse(a['created_at']);
      DateTime createdAtB = DateTime.parse(b['created_at']);
      return createdAtB.compareTo(createdAtA);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF121217),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Bookings',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF121217),
      ),
      body: (bookings.isEmpty && equipments.isEmpty)
          ? Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Image.asset(
          'assets/page-1/images/booking.png',
          height: 220,
        ),
        SizedBox(height: 10),
        Text(
          "You haven't made any bookings yet",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      ],
    ),
    )
        : ListView(
    padding: const EdgeInsets.all(16),
    children: [
    // Display equipment bookings
    if (equipments.isNotEmpty) ...[
    Text(
    'Equipment Bookings',
    style: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    ),
    ),
    SizedBox(height: 15),
    ...equipments.map((equipment) => _buildEquipmentCard(equipment)).toList(),
    SizedBox(height: 20),
    ],

    // Display artist/team bookings
    if (bookings.isNotEmpty) ...[
    Text(
    'Artist Bookings',
    style: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    ),
    ),
    SizedBox(height: 15),
    ...bookings.asMap().entries.map((entry) {
    final index = entry.key;
    final booking = entry.value;
    final idToUse = booking['artist_id'] ?? booking['team_id'];
    String isteam = (booking['team_id'] != '0' && booking['team_id'] != null)
    ? 'true'
        : 'false';
    return _buildRequestCard(
    booking['category'],
    booking['booking_date'],
    booking['booked_from'],
    booking['id'],
    idToUse,
    isteam,
    index,
    );
    }).toList(),
    ],
    ],
    ),
    );

  }




  // Add a new method to build equipment cards
  Widget _buildEquipmentCard(Map<String, dynamic> equipment) {


    double baseWidth = 390;
    double fem = MediaQuery
        .of(context)
        .size
        .width / baseWidth;
    double ffem = fem * 0.97;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
        BookingDetailScreen(bookingData: equipment),
          ),
        );
      },
      child: Card(
        color: Color(0xFF292938),
        margin: EdgeInsets.fromLTRB(5, 0, 5, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Equipment: ${equipment['item_names'] ?? 'Unknown'}',
                style: SafeGoogleFont(
                  'Be Vietnam Pro',
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Booking Date: ${equipment['booking_date'] ?? 'Not specified'}',
                style: SafeGoogleFont(
                  'Be Vietnam Pro',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFFB4B4DF),
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  // bool wait = await fetchArtistBooking(artist_id);
                  // if (wait) {
                     _makePhoneCall(phoneNumber ?? '');
                  // }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * fem),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 6.5 * fem,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Call Event Manager',
                    style: SafeGoogleFont(
                      'Be Vietnam Pro',
                      fontSize: 16 * ffem,
                      fontWeight: FontWeight.w700,
                      height: 1.5 * ffem / fem,
                      letterSpacing: 0.24 * fem,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Add more equipment details as needed
            ],
          ),

        ),
      ),
    );
  }
}