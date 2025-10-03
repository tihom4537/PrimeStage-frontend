// lib/providers/artist_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:convert';
import '../config.dart';

// Define the ArtistState class first
class ArtistState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> artistData;
  final List<String> demoSkills;
  final List<String> imagePathsFromBackend;
  final List<String> videoPathsFromBackend;
  final List<String> thumbnailPathsFromBackend;
  final Map<String, dynamic> ratings;
  final List<dynamic> teamMembers;
  final String availabilityStatus;
  final String? artistName;
  final String? teamName;
  final String? artistRole;
  final String? teamRole;
  final String? artistPrice;
  final String? profilePhoto;
  final String? artistAddress;
  final double? averageRating;
  final String? artistAboutText;
  final String? teamAbout;
  final String? artistSpecialMessage;
  final bool? hasSoundSystem;
  final String? artist_previous;
  final String? team_previous;
  final String? trimmedArtistAbout;
  final String? trimmedTeamAbout;

  ArtistState({
    this.isLoading = true,
    this.error,
    this.artistData = const {},
    this.demoSkills = const [],
    this.imagePathsFromBackend = const [],
    this.videoPathsFromBackend = const [],
    this.thumbnailPathsFromBackend = const [],
    this.ratings = const {},
    this.teamMembers = const [],
    this.availabilityStatus = '',
    this.artistName,
    this.teamName,
    this.artistRole,
    this.teamRole,
    this.artistPrice,
    this.profilePhoto,
    this.artistAddress,
    this.averageRating,
    this.artistAboutText,
    this.teamAbout,
    this.artistSpecialMessage,
    this.hasSoundSystem,
    this.artist_previous,
    this.team_previous,
    this.trimmedArtistAbout,
    this.trimmedTeamAbout,
  });

  ArtistState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? artistData,
    List<String>? demoSkills,
    List<String>? imagePathsFromBackend,
    List<String>? videoPathsFromBackend,
    List<String>? thumbnailPathsFromBackend,
    Map<String, dynamic>? ratings,
    List<dynamic>? teamMembers,
    String? availabilityStatus,
    String? artistName,
    String? teamName,
    String? artistRole,
    String? teamRole,
    String? artistPrice,
    String? profilePhoto,
    String? artistAddress,
    double? averageRating,
    String? artistAboutText,
    String? teamAbout,
    String? artistSpecialMessage,
    bool? hasSoundSystem,
    String? artist_previous,
    String? team_previous,
    String? trimmedArtistAbout,
    String? trimmedTeamAbout,
  }) {
    return ArtistState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      artistData: artistData ?? this.artistData,
      demoSkills: demoSkills ?? this.demoSkills,
      imagePathsFromBackend: imagePathsFromBackend ?? this.imagePathsFromBackend,
      videoPathsFromBackend: videoPathsFromBackend ?? this.videoPathsFromBackend,
      thumbnailPathsFromBackend: thumbnailPathsFromBackend ?? this.thumbnailPathsFromBackend,
      ratings: ratings ?? this.ratings,
      teamMembers: teamMembers ?? this.teamMembers,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      artistName: artistName ?? this.artistName,
      teamName: teamName ?? this.teamName,
      artistRole: artistRole ?? this.artistRole,
      teamRole: teamRole ?? this.teamRole,
      artistPrice: artistPrice ?? this.artistPrice,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      artistAddress: artistAddress ?? this.artistAddress,
      averageRating: averageRating ?? this.averageRating,
      artistAboutText: artistAboutText ?? this.artistAboutText,
      teamAbout: teamAbout ?? this.teamAbout,
      artistSpecialMessage: artistSpecialMessage ?? this.artistSpecialMessage,
      hasSoundSystem: hasSoundSystem ?? this.hasSoundSystem,
      artist_previous: artist_previous ?? this.artist_previous,
      team_previous: team_previous ?? this.team_previous,
      trimmedArtistAbout: trimmedArtistAbout ?? this.trimmedArtistAbout,
      trimmedTeamAbout: trimmedTeamAbout ?? this.trimmedTeamAbout,
    );
  }
}

class ArtistStateNotifier extends StateNotifier<ArtistState> {
  ArtistStateNotifier() : super(ArtistState());
  final storage = FlutterSecureStorage();

  Future<void> fetchArtistData(String artistId, String isTeam) async {
    try {
      state = state.copyWith(isLoading: true);

      List<Future<void>> futures = [
        fetchArtistWorkInformation(artistId, isTeam),
        fetchRatings(artistId, isTeam),
        fetchAvailabilityStatus(artistId, isTeam),
      ];

      if (isTeam == 'true') {
        futures.add(fetchTeamMembers(artistId));
      }

      await Future.wait(futures);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Error fetching artist data: $e',
        isLoading: false,
      );
    }
  }

  Future<void> fetchArtistWorkInformation(String artistId, String isTeam) async {
    String apiUrl = isTeam == 'true'
        ? '${Config().apiDomain}/featured/team/$artistId'
        : '${Config().apiDomain}/featured/artist_info/$artistId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> artistDataList = json.decode(response.body);
        if (artistDataList.isNotEmpty) {
          var artistData = artistDataList[0];

          List<String> imagePathsFromBackend = [];
          List<String> videoPathsFromBackend = [];
          List<String> thumbnailPathsFromBackend = [];

          String? trimmedArtistAbout = artistData['about_yourself']?.split(',')[0].trim();
          String? trimmedTeamAbout = artistData['about_team']?.split(',')[0].trim();
          String? artist_previous = artistData['about_yourself']?.split(',')[1].trim();
          String? team_previous = artistData['about_team']?.split(',')[1].trim();

          // Process image paths
          if (artistData['image1'] != null) imagePathsFromBackend.add(artistData['image1']);
          if (artistData['image2'] != null) imagePathsFromBackend.add(artistData['image2']);
          if (artistData['image3'] != null) imagePathsFromBackend.add(artistData['image3']);
          if (artistData['profile_photo'] != null) imagePathsFromBackend.add(artistData['profile_photo']);

          // Process video paths and thumbnails
          for (var videoField in [artistData['video1'], artistData['video2'], artistData['video3']]) {
            if (videoField != null) {
              List<String> parts = videoField.split(',');
              if (parts.isNotEmpty) {
                videoPathsFromBackend.add(parts[0].trim());
                thumbnailPathsFromBackend.add(parts.length > 1 ? parts[1].trim() : '');
              }
            }
          }


          state = state.copyWith(
            artistName: artistData['name'],
            teamName: artistData['team_name'],
            artistRole: artistData['skills'],
            teamRole: artistData['skill_category'],
            artistPrice: (artistData['price_per_hour'] ?? 0.0).toStringAsFixed(2),
            profilePhoto: artistData['profile_photo'],
            artistAddress: artistData['address'],
            artistAboutText: artistData['about_yourself'],
            teamAbout: artistData['about_team'],
            artistSpecialMessage: artistData['special_message'],
            hasSoundSystem: artistData['sound_system'] == 1,
            imagePathsFromBackend: imagePathsFromBackend,
            videoPathsFromBackend: videoPathsFromBackend,
            thumbnailPathsFromBackend: thumbnailPathsFromBackend,
            artist_previous: artist_previous,
            team_previous: team_previous,
            trimmedArtistAbout: trimmedArtistAbout,
            trimmedTeamAbout: trimmedTeamAbout,
          );
        }
      }
    } catch (e) {
      print('Error fetching artist information: $e');
    }
  }

  // Future<void> fetchReviews(String artistId, String isTeam) async {
  //   try {
  //     state = state.copyWith(isLoading: true);
  //
  //     String apiUrl = isTeam == "true"
  //         ? '${Config().apiDomain}/team/$artistId/average-rating'
  //         : '${Config().apiDomain}/artist/$artistId/average-rating';
  //
  //     final response = await http.get(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Content-Type': 'application/vnd.api+json',
  //         'Accept': 'application/vnd.api+json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> responseData = json.decode(response.body);
  //
  //       double safeDivide(int numerator, int denominator) {
  //         return denominator != 0 ? (numerator / denominator).toDouble() : 0.0;
  //       }
  //
  //       int totalReviews = responseData['total_ratings'];
  //       Map<int, double> ratingDistribution = {
  //         5: safeDivide(responseData['five_star_ratings'], totalReviews),
  //         4: safeDivide(responseData['four_star_ratings'], totalReviews),
  //         3: safeDivide(responseData['three_star_ratings'], totalReviews),
  //         2: safeDivide(responseData['two_star_ratings'], totalReviews),
  //         1: safeDivide(responseData['one_star_ratings'], totalReviews),
  //       };
  //
  //       state = state.copyWith(
  //         isLoading: false,
  //         averageRating: responseData['average_rating'].toDouble(),
  //         totalReviews: totalReviews,
  //         ratingDistribution: ratingDistribution,
  //       );
  //     } else {
  //       Map<String, dynamic> errorResponse = json.decode(response.body);
  //       if (errorResponse['error'] == 'No reviews found for this artist') {
  //         state = state.copyWith(
  //           isLoading: false,
  //           error: errorResponse['error'],
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: 'Error fetching reviews: $e',
  //     );
  //   }
  //}

  Future<void> fetchRatings(String artistId, String isTeam) async {
    try {
      String apiUrl = isTeam == "true"
          ? '${Config().apiDomain}/team/$artistId/average-rating'
          : '${Config().apiDomain}/artist/$artistId/average-rating';
print(isTeam);
      print(apiUrl );
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        print('mohit');
        print(responseData);
        print('not here');

        double safeDivide(int numerator, int denominator) {
          return denominator != 0 ? (numerator / denominator).toDouble() : 0.0;
        }

        int totalRatings = responseData['total_ratings'];
        double averageRating = responseData['average_rating'].toDouble();

        state = state.copyWith(
          averageRating: averageRating,
          ratings: {
            'total_ratings': totalRatings,
            'average_rating': averageRating,
            'four_star': safeDivide(responseData['four_star_ratings'], totalRatings),
            'five_star': safeDivide(responseData['five_star_ratings'], totalRatings),
            'three_star': safeDivide(responseData['three_star_ratings'], totalRatings),
            'two_star': safeDivide(responseData['two_star_ratings'], totalRatings),
            'one_star': safeDivide(responseData['one_star_ratings'], totalRatings),
          },
        );
      }
      else{
        Map<String, dynamic> errorResponse = json.decode(response.body);
        if (errorResponse['error'] == 'No reviews found for this artist') {
          state = state.copyWith(
            isLoading: false,
            error: errorResponse['error'],
          );
        }
      }
    } catch (e) {
      print('Error fetching ratings: $e');
    }
  }

  Future<void> fetchTeamMembers(String artistId) async {
    try {
      final response = await http.get(
        Uri.parse('${Config().apiDomain}/artist/team_member/$artistId'),
        headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> teamData = json.decode(response.body);
        state = state.copyWith(teamMembers: teamData);
      }
    } catch (e) {
      print('Error fetching team members: $e');
    }
  }

  Future<void> fetchAvailabilityStatus(String artistId, String isTeam) async {
    try {
      String apiUrl = isTeam == "true"
          ? '${Config().apiDomain}/artist/team_info/$artistId'
          : '${Config().apiDomain}/artist/info/$artistId';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        int status = responseData['data']['attributes']['booked_status'];

        String availabilityStatus = await _checkSecondaryAvailability(artistId, status, isTeam);
        state = state.copyWith(availabilityStatus: availabilityStatus);
      }
    } catch (e) {
      print('Error fetching availability status: $e');
      state = state.copyWith(availabilityStatus: 'Unable to fetch availability');
    }
  }

  Future<String> _checkSecondaryAvailability(String artistId, int status, String isTeam) async {
    if (status == 0) {
      String apiUrl = isTeam == "true"
          ? '${Config().apiDomain}/team/booking-date/$artistId'
          : '${Config().apiDomain}/artist/booking-date/$artistId';

      try {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          String status = responseData['status'];

          switch (status) {
            case 'unavailable':
              return 'Not Available';
            case 'available':
              return 'Available for Bookings';
            case 'has_bookings':
              List<dynamic> bookingDates = responseData['data'];
              return bookingDates.isEmpty
                  ? 'Available for Bookings'
                  : 'Booked On: ${bookingDates.join(', ')}';
            default:
              return 'Unable to fetch availability';
          }
        }
      } catch (e) {
        print('Error checking secondary availability: $e');
      }
    }
    return 'Not Available';
  }
}

final artistStateProvider = StateNotifierProvider<ArtistStateNotifier, ArtistState>((ref) {
  return ArtistStateNotifier();
});

final videoControllerProvider = Provider.family<VideoPlayerController, String>((ref, videoUrl) {
  return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
});

final isLoadingProvider = StateProvider<bool>((ref) => false);