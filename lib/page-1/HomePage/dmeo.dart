import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1/page-1/artist_showcase.dart';
import 'package:test1/page-1/customer_support.dart';
import 'package:test1/page-1/party_addons.dart';
import 'package:test1/page-1/searched_artist.dart';
// import 'package:test1/page-1/team_showcase.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import '../../config.dart';
import 'package:visibility_detector/visibility_detector.dart';


bool hasCalledApi = false;
Map<String, List<dynamic>>? _cachedData;

class Home_user extends StatefulWidget {
  @override
  _Home_userState createState() => _Home_userState();
}

class _Home_userState extends State<Home_user> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver{
  final storage = FlutterSecureStorage();

  // Add these variables at the top of your _Home_userState class
  int _bookingCount = 0;
  int _artistCount = 0;
  bool _hasAnimatedCounters = false;
  Timer? _bookingTimer;
  Timer? _artistTimer;
  late VideoPlayerController _controller;
  Future<Map<String, List<dynamic>>>? _fetchAssetsFuture;
  // Dummy data for testing. Replace it with actual data from your backend.
  final List<Map<String, dynamic>> categories = [

  ];

   List<Map<String, dynamic>> featuredArtists = [
    // Add more data as needed
  ];

  final List<Map<String, dynamic>> bestArtists = [
    {

      'name':'Live Music That Captures the Heart of Your Celebration',
      'type': 'video',
      'url': 'assets/page-1/images/homemarrage.mov',
      'nav':'Singer'
    },
    {
      'name': 'Exclusive Haldi Entertainment to Complement Your Traditional Celebration',
      'type': 'video',
      'url': 'assets/page-1/images/homestage2.mov',
      'nav': 'Instrumentalist'


    },
    {
      'name': 'Dance That Brings Your Celebration to Life',
      'type': 'video',
      'url': 'assets/page-1/images/cfcffa41920c1c8f63a3414483055651.mov',
      'nav':'Dancer'

    },
    // {
    //   'name': 'Exclusive Haldi Entertainment to Complement Your Traditional Celebration',
    //   'type': 'video',
    //   'url': 'assets/page-1/images/b6d72c6ab8ae0d23b322e019cab0b565.mp4',
    //   'nav':'Dancer'
    //
    // },

  ];
  final List<Map<String, dynamic>> newsection = [
    {

      'name':'Anchor who brings warmth and poise to your gathering.',
      'subheading': 'Seamless Hosting',
      'type':'image',
      'url': 'assets/page-1/images/anchor.jpg',
      'nav':'Anchor'
    },

    {
      'name': 'Immerse your guests in finely-tuned instrumental sounds',
      'subheading': 'Refined Musical Craftsmanship',
      'type':'image',
      'url': 'assets/page-1/images/pexels-yankrukov-9002001 2.jpg',
      'nav': 'Instrumentalist'


    },
    {
      'name': 'Turn your moments into lasting art with a Sketch Artist',
      'subheading': 'Art That Transcends Time',
      'type':'image',
      'url': 'assets/page-1/images/514f5c2e851363191bb1b020237eec7b.jpg',
      'nav':'Sketch Artist'

    },

  ];

  final List<Map<String, dynamic>> random = [
    {

      'name':'Elevate your event with unmatched vocal talent',
      'type': 'video',
      'url': 'assets/page-1/images/6273824-uhd_2160_3840_30fps.mov',
      'nav':'Singer'
    },

    {
      'name': 'Tailored Audio Solutions for Elite Events ',
      'type': 'image',
      'url': 'assets/page-1/images/0091cab0989eb9eb56ae106b3d5e4181 2.jpg',
      'nav': 'SoundSystem'


    },
    {
      'name': 'Soulful Melodies for a Blessed Occasion',
      'type': 'video',
      'url': 'assets/page-1/images/e5ccca38898b29f3851c4588c8327c44.mov',
      'nav':'Devotional'

    },
    {
      'name': 'Treat your elite guests to culinary perfection',
      'type': 'video',
      'url': 'assets/page-1/images/b6d72c6ab8ae0d23b322e019cab0b565.mp4',
      'nav':'Chef'

    },

  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!hasCalledApi) {
      // fetchAllData();
       fetchData();
      hasCalledApi = true;
    }


    // fetchFeaturedTeams();
    // fetchAssets();
  }
  // Future<void> fetchAllData() async {
  //   await Future.wait([_fetchAssetsFuture = fetchData(), fetchFeaturedArtists(),  fetchFeaturedTeams()]);
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("App lifecycle state changed: $state");
    if (state == AppLifecycleState.detached) {
      print("App is being closed. Resetting API call flag.");
      // Reset the flag when the app is closed completely
      hasCalledApi = false;
    }
  }
  @override
  bool get wantKeepAlive => true; // This keeps the state alive

  @override
  void dispose() {
    // Unregister the observer
    WidgetsBinding.instance.removeObserver(this);
    _bookingTimer?.cancel();
    _artistTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      // Fetch latitude and longitude from secure storage
      String? latitude = await storage.read(key: 'latitude');
      String? longitude = await storage.read(key: 'longitude');

      // Define URLs for featured artists, teams, and sections
      String featuredArtistsUrl = '${Config().apiDomain}/home/featured?lat=$latitude&lng=$longitude';
      String featuredTeamsUrl = '${Config().apiDomain}/home/featured/team?lat=$latitude&lng=$longitude';
      String sectionsUrl = '${Config().apiDomain}/sections';

      // Perform multiple parallel HTTP requests
      final responses = await Future.wait([
        http.get(Uri.parse(featuredArtistsUrl)),
        http.get(Uri.parse(featuredTeamsUrl)),
        http.get(Uri.parse(sectionsUrl)),
      ]);

      // Handle featured artists response
      if (responses[0].statusCode == 200) {
        List<dynamic> artistData = jsonDecode(responses[0].body);
        setState(() {
          featuredArtists.clear();
          for (var item in artistData) {
            featuredArtists.add({
              'id': item['id'],
              'name': item['name'],
              'image': '${item['profile_photo']}',
              'skill': item['skill_category'],
              'average_rating': item['average_rating'],
            });
          }
        });
      } else {
        print('Failed to fetch featured artists: ${responses[0].body}');
      }

      // Handle featured teams response
      if (responses[1].statusCode == 200) {
        List<dynamic> teamData = jsonDecode(responses[1].body);
        setState(() {
          for (var item in teamData) {
            featuredArtists.add({
              'id': item['id'],
              'name': item['team_name'],
              'image': '${item['profile_photo']}',
              'skill': item['skill_category'],
              'team': 'true',
              'average_rating': item['average_rating'],
            });
          }
        });
      } else {
        print('Failed to fetch featured teams: ${responses[1].body}');
      }

      // Handle sections response
      if (responses[2].statusCode == 200) {
        List<dynamic> sectionData = jsonDecode(responses[2].body);
        categories.clear();
        recommended.clear();
        seasonal.clear();
        combined.clear();

        for (var section in sectionData) {
          if (section == null) continue;

          String? sectionName = section['section_name'];
          List<dynamic>? items = section['items'];

          if (sectionName == 'Recommended' && items != null) {
            for (var item in items) {
              List<String> parts = item['item_name']?.split('/') ?? [];
              recommended.add({
                'subheading': parts.isNotEmpty ? parts[0].trim() : '',
                'name': parts.length > 1 ? parts[1].trim() : '',
                'type': parts.length > 2 ? parts[2].trim() : '',
                'image': item['item_data'] ?? '',
                'skill': parts.length > 3 ? parts[3].trim() : '',
              });
            }
          } else if (sectionName == 'Categories' && items != null) {
            for (var item in items) {
              categories.add({
                'name': item['item_name'] ?? 'Unknown',
                'type': 'image',
                'image': item['item_data'] ?? '',
              });
            }
          } else if (sectionName == 'Seasonal' && items != null) {
            for (var item in items) {
              List<String> parts = item['item_name']?.split('/') ?? [];
              seasonal.add({
                'name': parts.isNotEmpty ? parts[0].trim() : '',
                'team_id': parts.length > 1 ? parts[1].trim() : '',
                'image': item['item_data'] ?? '',
              });
            }
          } else if (sectionName == 'Best_Artist' && items != null) {
            for (var item in items) {
              List<String> parts = item['item_name']?.split('/') ?? [];
              combined.add({
                'name': parts.isNotEmpty ? parts[0].trim() : '',
                'artist_id': parts.length > 1 ? parts[1].trim() : '',
                'image': item['item_data'] ?? '',
              });
            }
          }
        }

        print('Categories: $categories');
      } else {
        print('Failed to fetch sections: ${responses[2].body}');
      }

      // Cache the fetched data
      _cachedData = {
        'featuredArtists': featuredArtists,
        'categories': categories,
        'recommended': recommended,
        'seasonal': seasonal,
        'combined': combined,
      };
      print("Fetched data cached successfully at: ${DateTime.now()}");

    } catch (error) {
      print('Error fetching data: $error');
    }
  }


  final List<Map<String, dynamic>> seasonal = [

  ];
  final List<Map<String, dynamic>> combined = [

  ];

  final List<Map<String, dynamic>> recommended = [

  ];

  final List<Map<String, dynamic>> best = [
    {

      'name':'Experience Unforgettable Entertainment for Your Grand Wedding',
      'type': 'video',
      'url': 'assets/page-1/images/b6d72c6ab8ae0d23b322e019cab0b565.mp4',
      'nav':'Comedian'
    },
    {
      'name': 'Exclusive Haldi Entertainment to Complement Your Traditional Celebration',
      'type': 'video',
      'url': 'assets/page-1/images/b6d72c6ab8ae0d23b322e019cab0b565.mp4',
      'nav':'Dancer'

    },
    {

      'name': 'Enhance Your Mehndi Event with Exquisite Talent and Elegant Performances',
      'type': 'video',
      'url': 'assets/page-1/images/b6d72c6ab8ae0d23b322e019cab0b565.mp4',
      'nav':'Comedian, Dancer'

    },
  ];

  Future<String?> _getLatitude() async {
    return await storage.read(key: 'latitude');
  }

  Future<String?> _getLongitude() async {
    return await storage.read(key: 'longitude');
  }


  Future<List<Map<String, dynamic>>> searchArtists(String searchTerm) async {
    String? latitude = await _getLatitude();
    String? longitude = await _getLongitude();

    final String apiUrl1 = '${Config().apiDomain}/artist/search';
    final String apiUrl2 = '${Config().apiDomain}/team/search';

    final Uri uri1 = Uri.parse(apiUrl1).replace(queryParameters: {
      'skill': searchTerm,
      'lat': latitude,
      'lng': longitude,
    });

    final Uri uri2 = Uri.parse(apiUrl2).replace(queryParameters: {
      'skill': searchTerm,
      'lat': latitude,
      'lng': longitude,
    });
print(uri1);
    try {
      final responses = await Future.wait([
        http.get(uri1, headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        }),
        http.get(uri2, headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        }),
      ]);

      final response1 = responses[0];
      final response2 = responses[1];

      if (response1.statusCode == 200 && response2.statusCode == 200) {
        List<dynamic> data1 = jsonDecode(response1.body);
        List<dynamic> data2 = jsonDecode(response2.body);

        List<Map<String, dynamic>> mergedData = [
          ...data1.map((artist) => {
            ...artist,
            'profile_photo': artist['profile_photo'],
            'isTeam': 'false',
          }),
          ...data2.map((artist) => {
            ...artist,
            'profile_photo': artist['profile_photo'],
            'isTeam': 'true',
          }),
        ];
        return mergedData;
      } else {
        print('Failed to load artists');
        return [];
      }
    } catch (e) {
      print('Error occurred: $e');
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery
        .of(context)
        .size
        .width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(backgroundColor: Color(0xFF121217),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 8*fem, 0),
          child: Center(
            child: Text(
              'Home',
              style: TextStyle(
                fontSize: 22 * fem,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xFF0F0F12),
      ),
      body: Stack(
        children:[ FutureBuilder<Map<String, List<dynamic>>>(
            future: _cachedData != null ? Future.value(_cachedData) : _fetchAssetsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Display a loading indicator while waiting for the data
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
        
              if (snapshot.hasError) {
                // Display an error message if there's an issue
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
        
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                // Cache the data after it's successfully fetched
                _cachedData ??= snapshot.data;
        
                // Extract cached data into individual variables for UI use
                var categories = _cachedData?['categories'];
                var recommended = _cachedData?['recommended'];
                var seasonal = _cachedData?['seasonal'];
                var combined = _cachedData?['combined'];
                var featuredArtist = _cachedData?['featuredArtists'];
        
                print('Cached data: $_cachedData');
        
                // If no data is present, display a "No Data" message
                if (categories == null || categories.isEmpty) {
                  return const Center(
                    child: Text('An error occured ,please reload '),
                  );
                }
                return Container(
                  color: Color(0xFF0F0F12),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(12 * fem, 10 * fem,
                                0 * fem, 18 * fem),
                            child: Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 22 * ffem,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GridView.builder(
                            padding: EdgeInsets.fromLTRB(12 * fem, 0 * fem, 12 * fem, 30 * fem),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15.0*fem,
                              mainAxisSpacing: 15.0*fem,
                              childAspectRatio: 2.5*fem,
                            ),
                            itemCount: categories?.length ?? 0,
                            itemBuilder: (context, index) {
                              final category = categories?[index];
        // <<<<<<< HEAD
                              if (category == null) {
                                return SizedBox(); // Return an empty widget if category is null
                              }
        
                              return GestureDetector(
                                onTap: () async {
                                  if (category != null && category['name'] != null) {
                                    List<Map<String, dynamic>> filteredData = await searchArtists(category['name']);
                                    // Navigate to a new page on tap, passing the category data if needed
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchedArtist(filteredArtistData: filteredData),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  height: 83.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      begin: Alignment(0, 1),
                                      end: Alignment(0, -1),
                                      colors: <Color>[
                                        Color(0x66000000),
                                        Color(0x00000000),
                                        Color(0x1A000000),
                                        Color(0x00000000),
                                      ],
                                      stops: <double>[0, 1, 1, 1],
                                    ),
                                    image: category != null && category['image'] != null
                                        ? DecorationImage(
                                      fit: BoxFit.cover,
        
                                      image: NetworkImage(category['image']),
                                    )
                                        : DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage('assets/page-1/images/depth-4-frame-0-Kvf.png'), // Add a placeholder image
        
                                    ),
        
        //
                                  ),
        // <<<<<<< HEAD
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Container(
                                      margin: EdgeInsets.all(16),
                                      child: Text(
                                        category['name'] ?? '',
                                        style: GoogleFonts.getFont(
                                          'Be Vietnam Pro',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          height: 1.3,
                                          color: Color(0xFFFFFFFF),
                                        ),
        // =======
        //                                 image: DecorationImage(
        //                                   fit: BoxFit.cover,
        //                                   image: NetworkImage(category['image']),
        //                                 ),
        //                               ),
        //                               child: Align(
        //                                 alignment: Alignment.bottomLeft,
        //                                 child: Container(
        //                                   margin: EdgeInsets.all(16*fem),
        //                                   child: Text(
        //                                     category['name'],
        //                                     style: GoogleFonts.getFont(
        //                                       'Be Vietnam Pro',
        //                                       fontWeight: FontWeight.w600,
        //                                       fontSize: 16*fem,
        //                                       height: 1.3,
        //                                       color: Color(0xFFFFFFFF),
        // >>>>>>> 9e3f3a1ad3317a5838219c59acad554d7748e289
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
        
        
                          Stack(
                            children: [
                              // Background image with semi-transparent overlay
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/page-1/images/pexels-steve-johnson-1655046970-29666286.jpg'), // Replace with your background image path
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.7), // Semi-transparent overlay, adjust opacity here
                                  ),
                                ),
                              ),
        
                              // Content stacked on top of the background and overlay
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(16 * fem, 50 * fem, 0 * fem, 18 * fem),
                                    alignment: Alignment.centerLeft,  // Align the text to the left
                                    child: Text(
                                      'Prime Spotlight',
                                      style: TextStyle(
                                        fontSize: 22 * ffem,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 575*fem,
                                    margin: EdgeInsets.zero,
                                    child: PageView.builder(
                                      controller: PageController(viewportFraction: 0.87, keepPage: true),
                                      scrollDirection: Axis.horizontal,
                                      itemCount:  random.length,
                                      itemBuilder: (context, index) {
                                        final artist =  random[index];
                                        if (artist == null) {
                                          return SizedBox(); // Return an empty SizedBox if the artist is null
                                        }
                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 6*fem),
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (artist != null && artist['nav'] != null) {
                                                if (artist['nav'] == 'SoundSystem') {
                                                  // Navigate to CustomizeSoundSystemPage if 'nav' is 'sound system'
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => CustomizeSoundSystemPage(),
                                                    ),
                                                  );
                                                } else {
                                                  // Otherwise, perform the search and navigate to SearchedArtist page
                                                  List<Map<String, dynamic>> filteredData = await searchArtists(artist['nav']);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => SearchedArtist(filteredArtistData: filteredData),
                                                    ),
                                                  );
                                                }
                                              }
        
                                            },
                                            child: Stack(
                                              children: [
                                                // Main image or video
                                                Container(
                                                  width: 330*fem,
                                                  height: 495*fem,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: artist['type'] == 'image'
                                                        ? Image.asset(
                                                      artist['url'] ?? '', // Image from assets
                                                      fit: BoxFit.cover,
                                                    )
                                                        : CustomVideoPlayer(
                                                      source: artist['url'] ?? '', // Video from assets
                                                      isAsset: true,
                                                    ),
                                                  ),
                                                ),
                                                // Semi-transparent overlay on individual cards
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.1), // Adjust transparency for individual items
                                                      borderRadius: BorderRadius.circular(10*fem),
                                                    ),
                                                  ),
                                                ),
                                                // Artist name text
                                                Positioned(
                                                  bottom: 100*fem,
                                                  left: 16*fem,
                                                  right: 16*fem,
                                                  child: Text(
                                                    artist['name'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 18*fem,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),


                          // Replace the counter section with this code
                          VisibilityDetector(
                            key: Key('counters'),
                            onVisibilityChanged: (visibilityInfo) {
                              if (!_hasAnimatedCounters && visibilityInfo.visibleFraction > 0.5) {
                                setState(() {
                                  _hasAnimatedCounters = true;
                                });

                                // Cancel any existing timers
                                _bookingTimer?.cancel();
                                _artistTimer?.cancel();

                                const animationDuration = Duration(milliseconds: 2000);
                                const fps = 60;
                                final totalFrames = (animationDuration.inMilliseconds / 1000 * fps).round();

                                int bookingFrame = 0;
                                int artistFrame = 0;

                                _bookingTimer = Timer.periodic(Duration(milliseconds: (1000 / fps).round()), (timer) {
                                  if (bookingFrame < totalFrames) {
                                    setState(() {
                                      _bookingCount = (1000 * bookingFrame / totalFrames).round();
                                    });
                                    bookingFrame++;
                                  } else {
                                    setState(() {
                                      _bookingCount = 1000;
                                    });
                                    timer.cancel();
                                  }
                                });

                                _artistTimer = Timer.periodic(Duration(milliseconds: (1000 / fps).round()), (timer) {
                                  if (artistFrame < totalFrames) {
                                    setState(() {
                                      _artistCount = (500 * artistFrame / totalFrames).round();
                                    });
                                    artistFrame++;
                                  } else {
                                    setState(() {
                                      _artistCount = 500;
                                    });
                                    timer.cancel();
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 40 * fem),
                              color: Color(0xFF1A1A1D),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      TweenAnimationBuilder(
                                        tween: Tween<double>(begin: 0, end: _bookingCount.toDouble()),
                                        duration: Duration(milliseconds: 500),
                                        builder: (context, double value, child) {
                                          return Text(
                                            '${value.round()}+',
                                            style: TextStyle(
                                              fontSize: 40 * ffem,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                      Text(
                                        'Bookings',
                                        style: TextStyle(
                                          fontSize: 18 * ffem,
                                          color: Color(0xFF9E9EB8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      TweenAnimationBuilder(
                                        tween: Tween<double>(begin: 0, end: _artistCount.toDouble()),
                                        duration: Duration(milliseconds: 500),
                                        builder: (context, double value, child) {
                                          return Text(
                                            '${value.round()}+',
                                            style: TextStyle(
                                              fontSize: 40 * ffem,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                      Text(
                                        'Artists',
                                        style: TextStyle(
                                          fontSize: 18 * ffem,
                                          color: Color(0xFF9E9EB8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
        
        
        
        
        
                          Container(
                            padding: EdgeInsets.fromLTRB(15 * fem, 38 * fem,
                                0 * fem, 0 * fem),
                            child: Text(
                              'Master Performers',
                              style: TextStyle(
                                fontSize: 22 * ffem,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            height: 350*fem,
                            // Set a specific height for the Container
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: featuredArtist?.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.only(right: 0 * fem),
                                  width: 180 * fem,
                                  padding: EdgeInsets.fromLTRB(
                                      12 * fem, 16 * fem, 0 * fem, 10 * fem),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          // Get the id of the selected artist
                                          String? id = featuredArtist?[index]['id']
                                              .toString() ?? ''; // Convert id to String
                                         String isteam= featuredArtist?[index]['team'] ?? '';
                                         print('isteam $isteam');
                                          // Navigate to the ArtistProfile screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ArtistProfile(
                                                    artist_id: id.toString(), isteam : isteam ),
                                            ),
                                          );
        
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              bottom: 12 * fem),
                                          width: 175 * fem,
                                          height: 223 * fem,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                12 * fem),
                                            child: Image.network(
                                              featuredArtist?[index]['image'] ?? '',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        featuredArtist?[index]['name'] ?? '',
                                        style: TextStyle(
                                          fontSize: 17 * ffem,
                                          fontWeight: FontWeight.w600,
                                          height: 1.5 * ffem / fem,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 3*fem),
                                      Row(
                                        children: [
                                          Text(
                                            '${featuredArtist?[index]['skill']}' ?? '',
                                            style: TextStyle(
                                              fontSize: 16 * ffem,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF9E9EB8),
                                            ),
                                          ),
                                          Spacer(),
        
                                          Padding(
                                            padding:  EdgeInsets.fromLTRB(
                                                0, 0, 5*fem, 0),
                                            child: Text(
                                              ' ${featuredArtist?[index]['average_rating']}/5' ?? '',
                                              style: TextStyle(
                                                fontSize: 16 * ffem,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF9E9EB8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
        
        
        
        
        
        
                          Container(
                            padding: EdgeInsets.fromLTRB(12 * fem, 20 * fem,
                                0 * fem, 0 * fem),
                            child: Text(
                              'Recommended',
                              style: TextStyle(
                                fontSize: 22 * ffem,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            height: 430 * fem,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recommended?.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    // Handle the tap event here
                                  // String id = recommended?[index]['id'];
                                  // String isteam = recommended?[index]['isteam'];
                                    String skill = recommended?[index]['skill'];
        
                                    if (skill != null) {
                                      if (skill == 'SoundSystem') {
                                        // Navigate to CustomizeSoundSystemPage if the skill is 'sound system'
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CustomizeSoundSystemPage(),
                                          ),
                                        );
                                      } else {
                                        // Otherwise, search for artists based on the skill and navigate to SearchedArtist page
                                        List<Map<String, dynamic>> filteredData = await searchArtists(skill);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SearchedArtist(filteredArtistData: filteredData),
                                          ),
                                        );
                                      }
                                    }
                                    // You can perform any action, like navigating to a details page
                                  },
                                  child: Container(
                                    width: 300 * fem,
                                    padding: EdgeInsets.fromLTRB(12 * fem, 16 * fem, 0 * fem, 16 * fem),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 12 * fem),
                                          width: 305 * fem,
                                          height: 313 * fem,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8 * fem),
                                            child: recommended?[index]['type'] == 'image'
                                                ? Image.network(
                                              recommended?[index]['image'],
                                              fit: BoxFit.cover,
                                            )
                                                : CustomVideoPlayer(
                                                source: recommended?[index]['image'],
                                                isAsset: false),
                                          ),
                                        ),
                                        Text(
                                          recommended?[index]['subheading'],
                                          style: TextStyle(
                                            fontSize: 14 * ffem,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5 * ffem / fem,
                                            color: Color(0xFF9E9EB8),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          width: 260 * fem,
                                          // Set the desired width here
                                          child: Text(
                                            recommended?[index]['name'],
                                            style: TextStyle(
                                              fontSize: 18 * ffem,
                                              fontWeight: FontWeight.w400,
                                              height: 1.3625 * ffem / fem,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
        
        
                          Container(
                            padding: EdgeInsets.fromLTRB(15 * fem, 40 * fem,
                                0 * fem, 0 * fem),
                            child: Text(
                              'Artists Around You',
                              style: TextStyle(
                                fontSize: 22 * ffem,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            height: 330 * fem,  // Set a specific height for the Container
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: combined?.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    // Perform your desired action on tap
                                    String id =combined?[index]['artist_id'];
        
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ArtistProfile(
                                                artist_id: id.toString(), isteam : 'false' ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 180 * fem,
                                    padding: EdgeInsets.fromLTRB(12 * fem, 16 * fem, 0 * fem, 0 * fem),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 12 * fem),
                                          width: 175 * fem,
                                          height: 223 * fem,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10 * fem),
                                            child: Image.network(
                                              combined?[index]['image'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          combined?[index]['name'],
                                          style: TextStyle(
                                            fontSize: 17 * ffem,
                                            fontWeight: FontWeight.w400,
                                            height: 1.5 * ffem / fem,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(15 * fem, 0 * fem,
                                0 * fem, 0 * fem),
                            child: Text(
                              'Best in Bands',
                              style: TextStyle(
                                fontSize: 22 * ffem,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            height: 330 * fem, // Set a specific height for the Container
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: seasonal?.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    // Perform your desired action on tap
                                    String id =seasonal?[index]['team_id'];
        
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ArtistProfile(
                                                artist_id: id.toString(), isteam : 'true' ),
                                      ),
                                    );
                                    // You can also navigate to another page if needed:
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage()));
                                  },
                                  child: Container(
                                    width: 180 * fem,
                                    padding: EdgeInsets.fromLTRB(12 * fem, 16 * fem, 0 * fem, 0 * fem),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 12 * fem),
                                          width: 175 * fem,
                                          height: 223 * fem,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12 * fem),
                                            child: Image.network(
                                              seasonal?[index]['image'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          seasonal?[index]['name'],
                                          style: TextStyle(
                                            fontSize: 17 * ffem,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5 * ffem / fem,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
        
                          Container(
                            padding: EdgeInsets.fromLTRB(12 * fem, 20 * fem,
                                0 * fem, 0 * fem),
                            child: Text(
                              'Top Curations',
                              style: TextStyle(
                                fontSize: 22 * ffem,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            height: 430 * fem,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: newsection?.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    // Handle the tap event here
                                    // String id = recommended?[index]['id'];
                                    // String isteam = recommended?[index]['isteam'];
                                    String skill = newsection?[index]['nav'];
        
                                    if (skill != null) {
                                      if (skill == 'SoundSystem') {
                                        // Navigate to CustomizeSoundSystemPage if the skill is 'sound system'
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CustomizeSoundSystemPage(),
                                          ),
                                        );
                                      } else {
                                        // Otherwise, search for artists based on the skill and navigate to SearchedArtist page
                                        List<Map<String, dynamic>> filteredData = await searchArtists(skill);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SearchedArtist(filteredArtistData: filteredData),
                                          ),
                                        );
                                      }
                                    }
                                    // You can perform any action, like navigating to a details page
                                  },
                                  child: Container(
                                    width: 300 * fem,
                                    padding: EdgeInsets.fromLTRB(12 * fem, 16 * fem, 0 * fem, 16 * fem),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 12 * fem),
                                          width: 305 * fem,
                                          height: 313 * fem,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8 * fem),
                                            child: newsection?[index]['type'] == 'image'
                                                ? Image.asset(
                                              newsection?[index]['url'],
                                              fit: BoxFit.cover,
                                            )
                                                : CustomVideoPlayer(
                                                source: newsection?[index]['url'],
                                                isAsset: false),
                                          ),
                                        ),
                                        Text(
                                          newsection?[index]['subheading'],
                                          style: TextStyle(
                                            fontSize: 14 * ffem,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5 * ffem / fem,
                                            color: Color(0xFF9E9EB8),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          width: 260 * fem,
                                          // Set the desired width here
                                          child: Text(
                                            newsection?[index]['name'],
                                            style: TextStyle(
                                              fontSize: 18 * ffem,
                                              fontWeight: FontWeight.w400,
                                              height: 1.3625 * ffem / fem,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 40),
                          Container(
                            height: 790*fem, // Full height for the container
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/page-1/images/bulbs.jpg'), // Background image
                                fit: BoxFit.cover, // Adjust image to cover the container
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Semi-transparent overlay over the entire container
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7), // Control opacity here
                                    ),
                                  ),
                                ),
                                // "Best Teams" title at the top
                                Positioned(
                                  top: 65*fem, // Adjust top padding as needed
                                  left: 25*fem, // Adjust left padding as needed
                                  child: Text(
                                    'Wedding Special',
                                    style: TextStyle(
                                      fontSize: 22 * ffem,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // PageView for videos or images
                                Positioned(
                                  top: 110*fem, // Position this below the "Best Teams" title
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    width: 330*fem,
                                    height: 495*fem,// Full height for PageView to match the container
                                    child: PageView.builder(
                                      controller: PageController(viewportFraction: 0.87),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: bestArtists.length,
                                      itemBuilder: (context, index) {
                                        final artist = bestArtists[index];
                                        if (artist == null) {
                                          return SizedBox(); // Return an empty SizedBox if the artist is null
                                        }
                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 6),
                                          child: GestureDetector(
                                            onTap: () async {
                                              List<Map<String, dynamic>> filteredData =
                                              await searchArtists(artist['nav']);
                                              // Navigate to a new page on tap, passing the category data if needed
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => SearchedArtist(filteredArtistData: filteredData),
                                                ),
                                              );
                                            },
                                            child: Stack(
                                              children: [
                                                // Main image or video
                                                Container(
                                                  width: 330*fem,
                                                  height: 495*fem,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: artist['type'] == 'image'
                                                        ? Image.asset(
                                                      artist['url'] ?? '', // Image from assets
                                                      fit: BoxFit.cover,
                                                    )
                                                        : CustomVideoPlayer(
                                                      source: artist['url'] ?? '', // Video from assets
                                                      isAsset: true,
                                                    ),
                                                  ),
                                                ),
                                                // Semi-transparent overlay on each video/image
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.2), // Adjust transparency
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                                // Artist name text on each image/video
                                                Positioned(
                                                  bottom: 30*fem, // Position near the bottom of each video/image
                                                  left: 16*fem,
                                                  right: 34*fem,
                                                  child: Text(
                                                    artist['name'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // HomeStage text at the bottom
                                Positioned(
                                  bottom: 60*fem, // Position the text 30 pixels from the bottom
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text(
                                      'PRIMESTAGE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 40*fem,
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
                );
              }
             else {
                return Center(
                  child: Text('No data found'), // Handle empty data case
                );
              }
            }
        ),
          Positioned(
            bottom: 25*fem, // Adjust based on bottom nav height
            right: 7*fem,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SupportScreen()),
                );              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.headset_mic, // Customer support icon
                  color: Color(0xffe5195e),
                  size: 30,
                ),
              ),
            ),
          ),

      ],


      ),
    );
  }

}


// import 'package:video_player/video_player.dart';
// import 'package:flutter/material.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String source;
  final bool isAsset;

  CustomVideoPlayer({required this.source, this.isAsset = false, Key? key})
      : super(key: key);

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isDisposed = false;
  DateTime? _lastVisibilityChange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    _controller.dispose();

    super.dispose();
  }


  Future<void> _initializeVideo() async {
    try {
      _controller = widget.isAsset
          ? VideoPlayerController.asset(widget.source)
          : VideoPlayerController.networkUrl(Uri.parse(widget.source));

      // Start initializing immediately to prevent delays
      await _controller.initialize();
      _controller.setLooping(true);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print("Error initializing video: $e");
    }
  }

  // Future<void> _initializeVideo() async {
  //   try {
  //     _controller = widget.isAsset
  //         ? VideoPlayerController.asset(widget.source)
  //         : VideoPlayerController.networkUrl(Uri.parse(widget.source));
  //
  //     await _controller.initialize();
  //     if (mounted) {
  //       setState(() {
  //         _isInitialized = true;
  //       });
  //     }
  //     _controller.setLooping(true);
  //   } catch (e) {
  //     print("Error initializing video: $e");
  //   }
  // }

  void _playPauseVideo(bool visible) async {
    if (_isDisposed || !_isInitialized) return;

    await Future.delayed(Duration(milliseconds: 100)); // Small delay to stabilize visibility state

    if (visible && !_isPlaying) {
      _controller.play();
      setState(() {
        _isPlaying = true;
      });
    } else if (!visible && _isPlaying) {
      _controller.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.source),
      onVisibilityChanged: (visibilityInfo) {
        var now = DateTime.now();
        if (_lastVisibilityChange != null &&
            now.difference(_lastVisibilityChange!) < Duration(milliseconds: 200)) {
          return; // Debounce to prevent rapid toggles
        }
        _lastVisibilityChange = now;

        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        _playPauseVideo(visiblePercentage > 30);
      },
      child: _isInitialized
          ? AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}