import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test1/page-1/page_0.3_artist_home.dart';
import 'package:test1/page-1/searched_artist.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config.dart';
import 'package:flutter/material.dart';
// search.dart





class SearchState {
  final bool isSearchBarSelected;
  final List<Map<String, dynamic>> searchResults;
  final bool isLoading;

  SearchState({
    this.isSearchBarSelected = false,
    this.searchResults = const [],
    this.isLoading = false,
  });

  SearchState copyWith({
    bool? isSearchBarSelected,
    List<Map<String, dynamic>>? searchResults,
    bool? isLoading,
  }) {
    return SearchState(
      isSearchBarSelected: isSearchBarSelected ?? this.isSearchBarSelected,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState());

  void setSearchBarSelected(bool selected) {
    state = state.copyWith(isSearchBarSelected: selected);
  }

  String mapSearchTermToSkill(String searchTerm) {
    final Map<String, String> skillMap = {
      'dance artist': 'dancer',
      'Videographer': 'Photographer',
      'Bhangra dancer': 'dancer',
      'Giddha dancer': 'dancer',
      'Fusion dancer': 'dancer',
      'Nati dancer': 'dancer',
      'Classical dancer': 'dancer',
      'Contemporary dancer': 'dancer',
      'Hip Hop dancer': 'dancer',
      'singer artist': 'singer',
      'Punjabi Singer': 'singer',
      'Ghazal/Sufi Singer': 'singer',
      'Bollywood Singer': 'singer',
      'Suffi Singer': 'singer',
      'Ghazal Singer': 'singer',
      'Devotional Singer': 'singer',
      'Indie/Pop Singer': 'singer',
      'English Covers Singer': 'singer',
      'music artist': 'musician',
      'comedy artist': 'comedian',
      'guitar artist': 'guitarist',
      'Dhol artist': 'dhol',
      'Anchor': 'Anchor',
    };

    String normalizedTerm = searchTerm.toLowerCase().trim();
    return skillMap[normalizedTerm] ?? normalizedTerm;
  }

  Future<void> searchArtists(String searchTerm, String? latitude, String? longitude) async {
    state = state.copyWith(isLoading: true);

    String skill = mapSearchTermToSkill(searchTerm);

    final String apiUrl1 = '${Config().apiDomain}/artist/search';
    final String apiUrl2 = '${Config().apiDomain}/team/search';

    final Uri uri1 = Uri.parse(apiUrl1).replace(queryParameters: {
      'skill': skill,
      'lat': latitude,
      'lng': longitude,
    });

    final Uri uri2 = Uri.parse(apiUrl2).replace(queryParameters: {
      'skill': skill,
      'lat': latitude,
      'lng': longitude,
    });

    try {
      final responses = await Future.wait([
        http.get(uri1, headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        }),
        http.get(uri2, headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        })
      ]);

      final response1 = responses[0];
      final response2 = responses[1];

      if (response1.statusCode == 200 && response2.statusCode == 200) {
        List<dynamic> data1 = jsonDecode(response1.body);
        List<dynamic> data2 = jsonDecode(response2.body);

        List<Map<String, dynamic>> mergedData = [
          ...List<Map<String, dynamic>>.from(data1.map((artist) {
            artist['profile_photo'] = artist['profile_photo'];
            artist['isTeam'] = 'false';
            return artist;
          })),
          ...List<Map<String, dynamic>>.from(data2.map((artist) {
            artist['profile_photo'] = artist['profile_photo'];
            artist['isTeam'] = 'true';
            return artist;
          })),
        ];

        state = state.copyWith(
          searchResults: mergedData,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          searchResults: [],
          isLoading: false,
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      state = state.copyWith(
        searchResults: [],
        isLoading: false,
      );
    }
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});



class Search extends ConsumerStatefulWidget {
  final VideoPlayerController controller;

  Search({required this.controller});

  @override
  ConsumerState<Search> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> with WidgetsBindingObserver {
  final FocusNode _searchFocusNode = FocusNode();
  final storage = FlutterSecureStorage();

  final List<String> skills = [
    'Comedian',
    'Anchor',
    'Musician',
    'DJ',
    'Dhol Artist',
    'Ghazal',
    'Magician',
    'Band',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
    WidgetsBinding.instance.addObserver(this);
    readAllStorage();
  }

  Future<void> readAllStorage() async {
    Map<String, String> allValues = await storage.readAll();
    allValues.forEach((key, value) {
      print('Key: $key, Value: $value');
    });
  }

  Future<String?> _getLatitude() async {
    return await storage.read(key: 'latitude');
  }

  Future<String?> _getLongitude() async {
    return await storage.read(key: 'longitude');
  }

  void _onSearchFocusChange() {
    ref.read(searchProvider.notifier).setSearchBarSelected(_searchFocusNode.hasFocus);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controller.play();
    } else if (state == AppLifecycleState.paused) {
      widget.controller.pause();
    }
  }

  void searchBySkill(String skill) async {
    final latitude = await _getLatitude();
    final longitude = await _getLongitude();

    await ref.read(searchProvider.notifier).searchArtists(skill, latitude, longitude);

    widget.controller.pause();

    final returnedValue = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchedArtist(
            filteredArtistData: ref.read(searchProvider).searchResults
        ),
      ),
    );

    if (returnedValue != null) {
      print('Returned value: $returnedValue');
    }

    widget.controller.play();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: widget.controller.value.size?.width ?? 0,
                height: widget.controller.value.size?.height ?? 0,
                child: VideoPlayer(widget.controller),
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15 * fem),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Search',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 22 * ffem,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * fem),
                    Container(
                      height: 60 * fem,
                      child: TextFormField(
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF292938).withOpacity(0.75),
                          hintText: 'Musician/ Band/ Dhol Artist....',
                          hintStyle: TextStyle(color: Color(0xFF9E9EB8)),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF9E9EB8)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16 * fem),
                            borderSide: BorderSide(
                              color: searchState.isSearchBarSelected
                                  ? Color(0xffe5195e)
                                  : Color(0xFFA63B5E),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16 * fem),
                            borderSide: BorderSide(color: Color(0xFF9E9EB8)),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        onFieldSubmitted: (value) async {
                          final latitude = await _getLatitude();
                          final longitude = await _getLongitude();

                          await ref.read(searchProvider.notifier)
                              .searchArtists(value, latitude, longitude);

                          widget.controller.pause();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchedArtist(
                                  filteredArtistData: ref.read(searchProvider).searchResults
                              ),
                            ),
                          ).then((_) => widget.controller.play());
                        },
                      ),
                    ),


                    SizedBox(height: 20 * fem),
// Skill buttons
                    Wrap(
                      spacing: 12 * fem,
                      runSpacing: 12 * fem,
                      children: skills.map((skill) {
                        return GestureDetector(
                          onTap: () {
                            searchBySkill(skill);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16 * fem, vertical: 8 * fem),
                            decoration: BoxDecoration(
                              color: Color(0xFF292938).withOpacity(0.75), // Transparent background
                              borderRadius: BorderRadius.circular(10 * fem),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15 * ffem,
                                fontWeight: FontWeight.w500,
                                height: 1.5 * ffem / fem,
                                color: Color(0xFF9E9EB8),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20 * fem),
// Nearby and Top Rated options
                    Container(
                      child: Text('Most Popular',style: TextStyle(
                        color: Color(0xFF9E9EB8),
                        fontSize: 18*fem,
                        fontStyle: FontStyle.italic,
                      ),),
                    ),

                    SizedBox(height: 10),
                    // Replace all the GestureDetector onTap methods with this pattern:

                    GestureDetector(
                      onTap: () async {
                        final latitude = await _getLatitude();
                        final longitude = await _getLongitude();

                        await ref.read(searchProvider.notifier)
                            .searchArtists('Singer', latitude, longitude);

                        widget.controller.pause();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchedArtist(
                                filteredArtistData: ref.read(searchProvider).searchResults
                            ),
                          ),
                        ).then((_) => widget.controller.play());
                      },
                      child: Text(
                        'Singers for Mehandi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18 * ffem,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        final latitude = await _getLatitude();
                        final longitude = await _getLongitude();

                        await ref.read(searchProvider.notifier)
                            .searchArtists('Bands', latitude, longitude);

                        widget.controller.pause();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchedArtist(
                                filteredArtistData: ref.read(searchProvider).searchResults
                            ),
                          ),
                        ).then((_) => widget.controller.play());
                      },
                      child: Text('Bands for wedding', style: TextStyle(color: Colors.white, fontSize: 18 * ffem)),
                    ),

                    SizedBox(height: 8 * fem),
                    // For 'Anchor for Event'
                    GestureDetector(
                      onTap: () async {
                        final latitude = await _getLatitude();
                        final longitude = await _getLongitude();

                        await ref.read(searchProvider.notifier)
                            .searchArtists('Anchor', latitude, longitude);

                        widget.controller.pause();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchedArtist(
                                filteredArtistData: ref.read(searchProvider).searchResults
                            ),
                          ),
                        ).then((_) => widget.controller.play());
                      },
                      child: Text('Anchor for Event', style: TextStyle(color: Colors.white, fontSize: 18 * ffem)),
                    ),

                    SizedBox(height: 8 * fem),
                    // For 'Poojan Special'
                    GestureDetector(
                      onTap: () async {
                        final latitude = await _getLatitude();
                        final longitude = await _getLongitude();

                        await ref.read(searchProvider.notifier)
                            .searchArtists('Devotional Singer', latitude, longitude);

                        widget.controller.pause();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchedArtist(
                                filteredArtistData: ref.read(searchProvider).searchResults
                            ),
                          ),
                        ).then((_) => widget.controller.play());
                      },
                      child: Text('Poojan Special', style: TextStyle(color: Colors.white, fontSize: 18 * ffem)),
                    ),

                    SizedBox(height: 8 * fem),

                    GestureDetector(
                      onTap: () async {
                        final latitude = await _getLatitude();
                        final longitude = await _getLongitude();

                        await ref.read(searchProvider.notifier)
                            .searchArtists('Sketch Artist', latitude, longitude);

                        widget.controller.pause();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchedArtist(
                                filteredArtistData: ref.read(searchProvider).searchResults
                            ),
                          ),
                        ).then((_) => widget.controller.play());
                      },
                      child: Text('Sketch Artist', style: TextStyle(color: Colors.white, fontSize: 18 * ffem)),
                    ),

                    SizedBox(height: 8 * fem),
                    // For 'Choreographers'
                    GestureDetector(
                      onTap: () async {
                        final latitude = await _getLatitude();
                        final longitude = await _getLongitude();

                        await ref.read(searchProvider.notifier)
                            .searchArtists('Dancer', latitude, longitude);

                        widget.controller.pause();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchedArtist(
                                filteredArtistData: ref.read(searchProvider).searchResults
                            ),
                          ),
                        ).then((_) => widget.controller.play());
                      },
                      child: Text('Choreographers', style: TextStyle(color: Colors.white, fontSize: 18 * ffem)),
                    ),
                    SizedBox(height: 8 * fem),
                    // For 'Magician for Kids'
                    GestureDetector(
                      onTap: () async {
                        final latitude = await _getLatitude();
                        final longitude = await _getLongitude();

                        await ref.read(searchProvider.notifier)
                            .searchArtists('Magician', latitude, longitude);

                        widget.controller.pause();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchedArtist(
                                filteredArtistData: ref.read(searchProvider).searchResults
                            ),
                          ),
                        ).then((_) => widget.controller.play());
                      },
                      child: Text('Magician for Kids', style: TextStyle(color: Colors.white, fontSize: 18 * ffem)),
                    ),
                    SizedBox(height: 8 * fem),
                    // For 'Kids Entertainment'
                    GestureDetector(
                      onTap: () async {
                        final latitude = await _getLatitude();
                        final longitude = await _getLongitude();

                        await ref.read(searchProvider.notifier)
                            .searchArtists('Kids Entertainment Specialist', latitude, longitude);

                        widget.controller.pause();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchedArtist(
                                filteredArtistData: ref.read(searchProvider).searchResults
                            ),
                          ),
                        ).then((_) => widget.controller.play());
                      },
                      child: Text('Kids Entertainment', style: TextStyle(color: Colors.white, fontSize: 18 * ffem)),
                    ),








                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}