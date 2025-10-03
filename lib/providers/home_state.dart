import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class HomeState {
  final Map<String, List<dynamic>>? cachedData;
  final int bookingCount;
  final int artistCount;
  final bool hasAnimatedCounters;
  final bool hasCalledApi;
  final List<Map<String, dynamic>> bestArtists;
  final List<Map<String, dynamic>> newsection;
  final List<Map<String, dynamic>> random;

  HomeState({
    this.cachedData,
    this.bookingCount = 0,
    this.artistCount = 0,
    this.hasAnimatedCounters = false,
    this.hasCalledApi = false,
    this.bestArtists = const [],
    this.newsection = const [],
    this.random = const [],
  });

  HomeState copyWith({
    Map<String, List<dynamic>>? cachedData,
    int? bookingCount,
    int? artistCount,
    bool? hasAnimatedCounters,
    bool? hasCalledApi,
    List<Map<String, dynamic>>? bestArtists,
    List<Map<String, dynamic>>? newsection,
    List<Map<String, dynamic>>? random,
  }) {
    return HomeState(
      cachedData: cachedData ?? this.cachedData,
      bookingCount: bookingCount ?? this.bookingCount,
      artistCount: artistCount ?? this.artistCount,
      hasAnimatedCounters: hasAnimatedCounters ?? this.hasAnimatedCounters,
      hasCalledApi: hasCalledApi ?? this.hasCalledApi,
      bestArtists: bestArtists ?? this.bestArtists,
      newsection: newsection ?? this.newsection,
      random: random ?? this.random,
    );
  }
}

class HomeStateNotifier extends StateNotifier<HomeState> {
  HomeStateNotifier() : super(HomeState()) {
    initializeStaticData();
  }

  final storage = FlutterSecureStorage();

  void initializeStaticData() {
    state = state.copyWith(
      bestArtists: [
        {
          'name': 'Live Music That Captures the Heart of Your Celebration',
          'type': 'video',
          'url': 'assets/page-1/images/homemarrage.mov',
          'nav': 'Singer'
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
          'nav': 'Dancer'
        },
      ],
      newsection: [
        {
          'name': 'Anchor who brings warmth and poise to your gathering.',
          'subheading': 'Seamless Hosting',
          'type': 'image',
          'url': 'assets/page-1/images/anchor.jpg',
          'nav': 'Anchor'
        },
        {
          'name': 'Immerse your guests in finely-tuned instrumental sounds',
          'subheading': 'Refined Musical Craftsmanship',
          'type': 'image',
          'url': 'assets/page-1/images/pexels-yankrukov-9002001 2.jpg',
          'nav': 'Instrumentalist'
        },
        {
          'name': 'Turn your moments into lasting art with a Sketch Artist',
          'subheading': 'Art That Transcends Time',
          'type': 'image',
          'url': 'assets/page-1/images/514f5c2e851363191bb1b020237eec7b.jpg',
          'nav': 'Sketch Artist'
        },
      ],
      random: [
        {
          'name': 'Elevate your event with unmatched vocal talent',
          'type': 'video',
          'url': 'assets/page-1/images/6273824-uhd_2160_3840_30fps.mov',
          'nav': 'Singer'
        },
        {
          'name': 'Tailored Audio Solutions for Elite Events',
          'type': 'image',
          'url': 'assets/page-1/images/0091cab0989eb9eb56ae106b3d5e4181 2.jpg',
          'nav': 'SoundSystem'
        },
        {
          'name': 'Soulful Melodies for a Blessed Occasion',
          'type': 'image',
          'url': 'assets/page-1/images/7266cfb4de074ef895d07206c66e16b3.jpg',
          'nav': 'Devotional'
        },
        // {
        //   'name': 'Treat your elite guests to culinary perfection',
        //   'type': 'video',
        //   'url': 'assets/page-1/images/b6d72c6ab8ae0d23b322e019cab0b565.mp4',
        //   'nav': 'Chef'
        // },
      ],
    );
  }

  void updateBookingCount(int count) {
    state = state.copyWith(bookingCount: count);
  }

  void updateArtistCount(int count) {
    state = state.copyWith(artistCount: count);
  }

  void setAnimatedCounters(bool value) {
    state = state.copyWith(hasAnimatedCounters: value);
  }

  Future<void> fetchData() async {
    try {
      String? latitude = await storage.read(key: 'latitude');
      String? longitude = await storage.read(key: 'longitude');

      final responses = await Future.wait([
        http.get(Uri.parse('${Config().apiDomain}/home/featured?lat=$latitude&lng=$longitude')),
        http.get(Uri.parse('${Config().apiDomain}/home/featured/team?lat=$latitude&lng=$longitude')),
        http.get(Uri.parse('${Config().apiDomain}/sections')),
      ]);

      List<dynamic> featuredArtists = [];
      List<dynamic> categories = [];
      List<dynamic> recommended = [];
      List<dynamic> seasonal = [];
      List<dynamic> combined = [];

      // Process responses and update state
      if (responses[0].statusCode == 200) {
        List<dynamic> artistData = jsonDecode(responses[0].body);
        featuredArtists.addAll(artistData.map((item) => {
          'id': item['id'],
          'name': item['name'],
          'image': item['profile_photo'],
          'skill': item['skill_category'],
          'average_rating': item['average_rating'],
        }));
      }

      if (responses[1].statusCode == 200) {
        List<dynamic> teamData = jsonDecode(responses[1].body);
        featuredArtists.addAll(teamData.map((item) => {
          'id': item['id'],
          'name': item['team_name'],
          'image': item['profile_photo'],
          'skill': item['skill_category'],
          'team': 'true',
          'average_rating': item['average_rating'],
        }));
      }

      if (responses[2].statusCode == 200) {
        List<dynamic> sectionData = jsonDecode(responses[2].body);
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
      }

      state = state.copyWith(
        cachedData: {
          'featuredArtists': featuredArtists,
          'categories': categories,
          'recommended': recommended,
          'seasonal': seasonal,
          'combined': combined,
        },
        hasCalledApi: true,
      );
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
}


final homeStateProvider = StateNotifierProvider<HomeStateNotifier, HomeState>((ref) {
  return HomeStateNotifier();
});