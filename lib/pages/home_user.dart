import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_state.dart';
import '../widgets/categories_section.dart';
import '../widgets/featured_artists_section.dart';
import '../widgets/custom_video_player.dart';
import '../widgets/support_button.dart';
import '../page-1/party_addons.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../page-1/searched_artist.dart';
import '../page-1/artist_showcase.dart';
import '../providers/search_provider.dart';
// import './artist_profile.dart';


class HomeUser extends ConsumerStatefulWidget {
  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends ConsumerState<HomeUser> with WidgetsBindingObserver {
  Timer? _bookingTimer;
  Timer? _artistTimer;






  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  void _initializeData() {
    if (!ref.read(homeStateProvider).hasCalledApi) {
      ref.read(homeStateProvider.notifier).fetchData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bookingTimer?.cancel();
    _artistTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeStateProvider);
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      backgroundColor: Color(0xFF121217),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 8 * fem, 0),
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
        children: [
          homeState.cachedData == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoriesSection(
                  categories: homeState.cachedData!['categories'] ?? [],
                  fem: fem,
                  ffem: ffem,
                ),
                _buildPrimeSpotlight(homeState, fem, ffem),
                _buildCountersSection(fem, ffem),
                FeaturedArtistsSection(
                  artists: homeState.cachedData!['featuredArtists'] ?? [],
                  fem: fem,
                  ffem: ffem,
                ),
                _buildRecommendedSection(
                  homeState.cachedData!['recommended'] ?? [],
                  fem,
                  ffem,
                ),
                _buildArtistsAroundYou(
                  homeState.cachedData!['combined'] ?? [],
                  fem,
                  ffem,
                ),

                _buildBestInBands(
                  homeState.cachedData!['seasonal'] ?? [],
                  fem,
                  ffem,
                ),
                _buildClientLogosCarousel(fem, ffem),
                _buildImageCarousel(fem, ffem),
                  _buildTopCurations(homeState.newsection, fem, ffem),
                _buildWeddingSpecial(homeState.bestArtists, fem, ffem),
                SizedBox(height: 40 * fem),
              ],
            ),
          ),
          CustomerSupportButton(fem: fem),
        ],
      ),
    );
  }

  // Add these methods inside _HomeUserState class

  Widget _buildPrimeSpotlight(HomeState homeState, double fem, double ffem) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/page-1/images/pexels-steve-johnson-1655046970-29666286.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16 * fem, 50 * fem, 0 * fem, 18 * fem),
              alignment: Alignment.centerLeft,
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
              height: 575 * fem,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.87, keepPage: true),
                scrollDirection: Axis.horizontal,
                itemCount: homeState.random.length,
                itemBuilder: (context, index) {
                  final item = homeState.random[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 6 * fem),
                    child: GestureDetector(
                      onTap: () async {
                        if (item['nav'] != null) {
                          if (item['nav'] == 'SoundSystem') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomizeSoundSystemPage(),
                              ),
                            );
                          } else {
                            final searchService = ref.read(searchServiceProvider);
                            final filteredData = await searchService.searchArtists(item['nav']);
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchedArtist(filteredArtistData: filteredData),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: _buildSpotlightItem(item, fem),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpotlightItem(Map<String, dynamic> item, double fem) {
    return Stack(
      children: [
        Container(
          width: 330 * fem,
          height: 495 * fem,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item['type'] == 'image'
                ? Image.asset(
              item['url'] ?? '',
              fit: BoxFit.cover,
            )
                : CustomVideoPlayer(
              source: item['url'] ?? '',
              isAsset: true,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10 * fem),
            ),
          ),
        ),
        Positioned(
          bottom: 100 * fem,
          left: 16 * fem,
          right: 16 * fem,
          child: Text(
            item['name'] ?? '',
            style: TextStyle(
              fontSize: 18 * fem,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountersSection(double fem, double ffem) {
    return VisibilityDetector(
      key: Key('counters'),
      onVisibilityChanged: (visibilityInfo) {
        if (!ref.read(homeStateProvider).hasAnimatedCounters &&
            visibilityInfo.visibleFraction > 0.5) {
          ref.read(homeStateProvider.notifier).setAnimatedCounters(true);
          _startCounterAnimations();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 40 * fem),
        color: Colors.black.withOpacity(0.7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCounter('Bookings', ref.watch(homeStateProvider).bookingCount, fem, ffem),
            _buildCounter('Artists', ref.watch(homeStateProvider).artistCount, fem, ffem),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(String label, int count, double fem, double ffem) {
    return Column(
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: count.toDouble()),
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
          label,
          style: TextStyle(
            fontSize: 18 * ffem,
            color: Color(0xFF9E9EB8),
          ),
        ),
      ],
    );
  }

  void _startCounterAnimations() {
    const animationDuration = Duration(milliseconds: 2000);
    const fps = 60;
    final totalFrames = (animationDuration.inMilliseconds / 1000 * fps).round();

    int bookingFrame = 0;
    int artistFrame = 0;

    _bookingTimer?.cancel();
    _artistTimer?.cancel();

    _bookingTimer = Timer.periodic(
      Duration(milliseconds: (1000 / fps).round()),
          (timer) {
        if (bookingFrame < totalFrames) {
          ref.read(homeStateProvider.notifier)
              .updateBookingCount((1000 * bookingFrame / totalFrames).round());
          bookingFrame++;
        } else {
          ref.read(homeStateProvider.notifier).updateBookingCount(1000);
          timer.cancel();
        }
      },
    );

    _artistTimer = Timer.periodic(
      Duration(milliseconds: (1000 / fps).round()),
          (timer) {
        if (artistFrame < totalFrames) {
          ref.read(homeStateProvider.notifier)
              .updateArtistCount((500 * artistFrame / totalFrames).round());
          artistFrame++;
        } else {
          ref.read(homeStateProvider.notifier).updateArtistCount(500);
          timer.cancel();
        }
      },
    );
  }

  Widget _buildRecommendedSection(List<dynamic> recommended, double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(12 * fem, 20 * fem, 0 * fem, 0 * fem),
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
            itemCount: recommended.length,
            itemBuilder: (context, index) => _buildRecommendedItem(
              recommended[index],
              fem,
              ffem,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedItem(Map<String, dynamic> item, double fem, double ffem) {
    return GestureDetector(
      onTap: () async {
        String? skill = item['skill'];
        if (skill != null) {
          if (skill == 'SoundSystem') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomizeSoundSystemPage(),
              ),
            );
          } else {
            final searchService = ref.read(searchServiceProvider);
            final filteredData = await searchService.searchArtists(skill);
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchedArtist(filteredArtistData: filteredData),
                ),
              );
            }
          }
        }
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
                child: item['type'] == 'image'
                    ? Image.network(
                  item['image'],
                  fit: BoxFit.cover,
                )
                    : CustomVideoPlayer(
                  source: item['image'],
                  isAsset: false,
                ),
              ),
            ),
            Text(
              item['subheading'] ?? '',
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
              child: Text(
                item['name'] ?? '',
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
  }


  // Continue adding these methods inside _HomeUserState class

  Widget _buildArtistsAroundYou(List<dynamic> combined, double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(15 * fem, 40 * fem, 0 * fem, 0 * fem),
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
          height: 330 * fem,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: combined.length,
            itemBuilder: (context, index) {
              final artist = combined[index];
              return GestureDetector(
                onTap: () {
                  String id = artist['artist_id'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProviderScope(
                        child: ArtistProfile(
                          artist_id: id.toString(),
                          isteam: 'false',
                        ),
                      ),
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
                            artist['image'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        artist['name'],
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
      ],
    );
  }

  Widget _buildBestInBands(List<dynamic> seasonal, double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(15 * fem, 0 * fem, 0 * fem, 0 * fem),
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
          height: 330 * fem,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: seasonal.length,
            itemBuilder: (context, index) {
              final band = seasonal[index];
              return GestureDetector(
                onTap: () {
                  String id = band['team_id'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistProfile(
                        artist_id: id.toString(),
                        isteam: 'true',
                      ),
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
                          borderRadius: BorderRadius.circular(12 * fem),
                          child: Image.network(
                            band['image'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        band['name'],
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
      ],
    );
  }


// In your _HomeUserState class, add this method:
  Widget _buildImageCarousel(double fem, double ffem) {
    return ImageCarousel(
      fem: fem,
      ffem: ffem,
    );
  }

  Widget _buildTopCurations(List<Map<String, dynamic>> newsection, double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(12 * fem, 20 * fem, 0 * fem, 0 * fem),
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
            itemCount: newsection.length,
            itemBuilder: (context, index) {
              final item = newsection[index];
              return GestureDetector(
                onTap: () async {
                  String? nav = item['nav'];
                  if (nav != null) {
                    if (nav == 'SoundSystem') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomizeSoundSystemPage(),
                        ),
                      );
                    } else {
                      final searchService = ref.read(searchServiceProvider);
                      final filteredData = await searchService.searchArtists(nav);
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchedArtist(filteredArtistData: filteredData),
                          ),
                        );
                      }
                    }
                  }
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
                          child: item['type'] == 'image'
                              ? Image.asset(
                            item['url'],
                            fit: BoxFit.cover,
                          )
                              : CustomVideoPlayer(
                            source: item['url'],
                            isAsset: true,
                          ),
                        ),
                      ),
                      Text(
                        item['subheading'] ?? '',
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
                        child: Text(
                          item['name'] ?? '',
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
      ],
    );
  }

  // In your _HomeUserState class, add this method:
  Widget _buildClientLogosCarousel(double fem, double ffem) {
    return ClientLogosCarousel(
      fem: fem,
      ffem: ffem,
    );
  }

  Widget _buildWeddingSpecial(List<Map<String, dynamic>> bestArtists, double fem, double ffem) {
    return Container(
      height: 790 * fem,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/page-1/images/bulbs.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
          Positioned(
            top: 65 * fem,
            left: 25 * fem,
            child: Text(
              'Wedding Special',
              style: TextStyle(
                fontSize: 22 * ffem,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 110 * fem,
            left: 0,
            right: 0,
            child: Container(
              width: 330 * fem,
              height: 495 * fem,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.87),
                scrollDirection: Axis.horizontal,
                itemCount: bestArtists.length,
                itemBuilder: (context, index) {
                  final artist = bestArtists[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () async {
                        final searchService = ref.read(searchServiceProvider);
                        final filteredData = await searchService.searchArtists(artist['nav']);
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchedArtist(filteredArtistData: filteredData),
                            ),
                          );
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 330 * fem,
                            height: 495 * fem,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: artist['type'] == 'image'
                                  ? Image.asset(
                                artist['url'] ?? '',
                                fit: BoxFit.cover,
                              )
                                  : CustomVideoPlayer(
                                source: artist['url'] ?? '',
                                isAsset: true,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 30 * fem,
                            left: 16 * fem,
                            right: 34 * fem,
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
          Positioned(
            bottom: 60 * fem,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'PRIMESTAGE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 40 * fem,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}


// Add this widget between Best in Bands and Top Curations sections

class ImageCarousel extends StatefulWidget {
  final double fem;
  final double ffem;

  ImageCarousel({
    required this.fem,
    required this.ffem,
  });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  // Add your carousel images here
  final List<String> carouselImages = [
    'assets/page-1/images/happy1.png',
    'assets/page-1/images/happy2.png',
    'assets/page-1/images/happy3.png',
    'assets/page-1/images/happy4.png',
    'assets/page-1/images/happy5.PNG',

    // Add more image paths as needed
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < carouselImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(15 * widget.fem, 40 * widget.fem, 0, 20 * widget.fem),
          child: Text(
            'Our Happy Customers',  // You can change this title
            style: TextStyle(
              fontSize: 22 * widget.ffem,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          height: 200 * widget.fem,  // Adjust height as needed
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: carouselImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8 * widget.fem),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 * widget.fem),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12 * widget.fem),
                  child: Image.asset(
                    carouselImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20 * widget.fem),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              carouselImages.length,
                  (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4 * widget.fem),
                width: 8 * widget.fem,
                height: 8 * widget.fem,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.white : Color(0xFF9E9EB8),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20 * widget.fem),
      ],
    );
  }
}


class ClientLogosCarousel extends StatefulWidget {
  final double fem;
  final double ffem;

  ClientLogosCarousel({
    required this.fem,
    required this.ffem,
  });

  @override
  _ClientLogosCarouselState createState() => _ClientLogosCarouselState();
}

class _ClientLogosCarouselState extends State<ClientLogosCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<List<String>> clientLogosPages = [
    [
      'assets/page-1/images/client1.jpg',
      'assets/page-1/images/client2.jpg',
      'assets/page-1/images/client3.png',
      'assets/page-1/images/client4.jpg',
      'assets/page-1/images/client13.png',
      'assets/page-1/images/client6.png',

    ],
    [
      // Second page of 9 logos
      'assets/page-1/images/client7.png',
      'assets/page-1/images/client8.png',
      'assets/page-1/images/client9.png',
      'assets/page-1/images/client10.png',
      'assets/page-1/images/client11.png',
      'assets/page-1/images/client12.png',

    ],
    // Add more pages as needed
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_currentPage < clientLogosPages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20 * widget.fem, horizontal: 16* widget.fem),
      color:  Color(0xFF0F0F12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Add this line
        children: [
          Text(
            'Our Clients',  // You can change this title
            style: TextStyle(
              fontSize: 22 * widget.ffem,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20 * widget.fem),
          Container(
            height: 200 * widget.fem, // Increased height to accommodate 3 rows
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: clientLogosPages.length,
              itemBuilder: (context, pageIndex) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1 * widget.fem),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 columns
                      crossAxisSpacing: 10 * widget.fem,
                      mainAxisSpacing: 10 * widget.fem,
                      childAspectRatio: 1.5, // Adjust this value to control the height of each grid item
                    ),
                    itemCount: 6, // 9 items per page (3x3 grid)
                    itemBuilder: (context, index) {
                      if (index < clientLogosPages[pageIndex].length) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8 * widget.fem),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            clientLogosPages[pageIndex][index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        );
                      }
                      return Container(); // Empty container for any remaining slots
                    },
                  ),
                );
              },
            ),
          ),
          // SizedBox(height: 2 * widget.fem),
          // Page indicators
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: List.generate(
          //     clientLogosPages.length,
          //         (index) => Container(
          //       margin: EdgeInsets.symmetric(horizontal: 4 * widget.fem),
          //       width: 8 * widget.fem,
          //       height: 8 * widget.fem,
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: _currentPage == index ? Colors.white : Color(0xFF9E9EB8),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}





