// lib/pages/artist_profile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_player/video_player.dart';
import '../providers/artist_provider.dart';
import '../providers/video_provider.dart';
import '../widgets/artist_gallery.dart';
import '../widgets/artist_videos.dart';
import '../widgets/artist_reviews.dart';
import 'package:test1/page-1/artist_booking.dart';
import 'package:test1/page-1/phone_varification.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class ArtistProfile extends ConsumerStatefulWidget {
  final String artist_id;
  final String? isteam;

  const ArtistProfile({
    Key? key,
    required this.artist_id,
    this.isteam,
  }) : super(key: key);

  @override
  ConsumerState<ArtistProfile> createState() => _ArtistProfileState();
}

class _ArtistProfileState extends ConsumerState<ArtistProfile> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to schedule the state update after the build
    Future.microtask(() {
      ref.read(artistStateProvider.notifier).fetchArtistData(
        widget.artist_id,
        widget.isteam ?? 'false',
      );

      ref.read(reviewsStateProvider.notifier).fetchReviews(
        widget.artist_id,
        widget.isteam ?? 'false',
      );
    });

  }

  Future<void> _initializeData() async {
    await ref.read(artistStateProvider.notifier).fetchArtistData(
      widget.artist_id,
      widget.isteam ?? 'false',
    );
  }

  Future<void> _handleBooking() async {
    final storage = ref.read(secureStorageProvider);
    String? isSignedUp = await storage.read(key: 'user_signup');

    if (isSignedUp == 'true') {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => booking_artist(
            artist_id: widget.artist_id,
            isteam: widget.isteam,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneNumberInputScreen(
            artist_id: widget.artist_id,
            isteam: widget.isteam,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final artistState = ref.watch(artistStateProvider);
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    if (artistState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(fem),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildArtistHeader(fem, ffem),
                _buildAvailabilityStatus(fem, ffem),
                _buildBookingButton(fem, ffem),
                if (widget.isteam == 'true') _buildTeamMembers(fem, ffem),
                _buildAboutSection(fem, ffem),
                ArtistGallery(fem: fem, ffem: ffem),
                ArtistVideos(fem: fem, ffem: ffem),
                _buildMessageSection(fem, ffem),
                Consumer(
                  builder: (context, ref, child) {
                    final reviewsState = ref.watch(reviewsStateProvider);

                    return Padding(
                      padding: EdgeInsets.fromLTRB(18 * fem, 3, 16 * fem, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 22 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.25 * ffem / fem,
                              letterSpacing: -0.33 * fem,
                              color: Color(0xff1c0c11),
                            ),
                          ),
                          SizedBox(height: 10 * fem),

                          if (reviewsState.isLoading)
                            Center(child: CircularProgressIndicator())
                          else if (reviewsState.error != null)
                            Center(
                              child: Text(
                                "No reviews Yet",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 22 * ffem
                                ),
                              ),
                            )
                          else
                            ReviewsSection(
                              artistId: widget.artist_id,
                              isTeam: widget.isteam ?? 'false',
                              averageRating: reviewsState.averageRating,
                              totalReviews: reviewsState.totalReviews,
                              ratingDistribution: reviewsState.ratingDistribution,
                            ),
                        ],
                      ),
                    );
                  },
                ),
                // ReviewsSection(
                //   artistId: widget.artist_id,
                //   isTeam: widget.isteam ?? 'false',
                // ),
                _buildBottomBookingButton(fem, ffem),
                SizedBox(height: 40 * fem),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double fem) {
    return AppBar(
      title: Text(
        'Artist Profile',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 22 * fem,
        ),
      ),
      leading: IconButton(
        color: Colors.black,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildArtistHeader(double fem, double ffem) {
    final artistState = ref.watch(artistStateProvider);

    return Container(
      margin: EdgeInsets.fromLTRB(16 * fem, 16 * fem, 5 * fem, 11.5 * fem),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9.0),
            child: Container(
              width: 115 * fem,
              height: 150 * fem,
              color: Colors.grey[200],
              child: Image.network(
                artistState.profilePhoto ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  size: 50 * fem,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(17 * fem, 0, 0, 10 * fem),
            padding: EdgeInsets.fromLTRB(0, 5 * fem, 0, 0),
            width: 220 * fem,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artistState.artistName ?? artistState.teamName ?? '',
                  style: TextStyle(
                    fontSize: 20 * ffem,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  artistState.teamRole ?? '',
                  style: TextStyle(
                    fontSize: 17 * ffem,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff964f66),
                  ),
                ),
                SizedBox(height: 4 * fem),
                Row(
                  children: [
                    Text(
                      'Rating: ${artistState.averageRating?.toStringAsFixed(1)}/5',
                      style: TextStyle(
                        fontSize: 17 * ffem,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4 * fem),
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
                      artistState.artistPrice ?? '',
                      style: TextStyle(
                        fontSize: 17 * ffem,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Text(
                  '(Includes taxes & travel charges)',
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
    );
  }

  Widget _buildAvailabilityStatus(double fem, double ffem) {
    final artistState = ref.watch(artistStateProvider);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10 * fem),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12 * fem,
            height: 12 * fem,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: artistState.availabilityStatus == 'Available for Bookings'
                  ? Colors.green
                  : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: artistState.availabilityStatus == 'Available for Bookings'
                      ? Colors.green.withOpacity(0.5)
                      : Colors.red.withOpacity(0.5),
                  spreadRadius: 3 * fem,
                  blurRadius: 7 * fem,
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * fem),
          Text(
            artistState.availabilityStatus,
            style: TextStyle(
              fontSize: 16 * fem,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(double fem, double ffem) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * fem, vertical: 10 * fem),
      child: ElevatedButton(
        onPressed: _handleBooking,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9 * fem),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xffe5195e), Color(0xffd11b4f)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
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
                style: TextStyle(
                  fontSize: 17 * ffem,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMembers(double fem, double ffem) {
    final artistState = ref.watch(artistStateProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Members:',
            style: TextStyle(
              fontSize: 22 * ffem,
              fontWeight: FontWeight.w600,
              color: const Color(0xff1c0c11),
            ),
          ),
          SizedBox(height: 12 * fem),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: artistState.teamMembers.length,
            itemBuilder: (context, index) {
              final member = artistState.teamMembers[index];
              return Container(
                padding: EdgeInsets.symmetric(vertical: 8 * fem),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10 * fem),
                      child: Container(
                        width: 70 * fem,
                        height: 85 * fem,
                        color: Colors.grey[200],
                        child: member['profile_photo'] != null
                            ? Image.network(
                          member['profile_photo'],
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.person),
                      ),
                    ),
                    SizedBox(width: 12 * fem),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['member_name'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 17 * ffem,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff1c0c11),
                          ),
                        ),
                        SizedBox(height: 4 * fem),
                        Text(
                          member['role'] ?? 'Unknown role',
                          style: TextStyle(
                            fontSize: 15 * ffem,
                            fontWeight: FontWeight.normal,
                            color: const Color(0xff1c0c11),
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
  }

  Widget _buildAboutSection(double fem, double ffem) {
    final artistState = ref.watch(artistStateProvider);

    // Calculate trimmed values
    final trimmedArtistAbout = artistState.artistAboutText?.split(',')[0].trim();
    final trimmedTeamAbout = artistState.teamAbout?.split(',')[0].trim();

    // Parse skills
    final List<String> demoSkills = artistState.artistRole?.split(',')
        .map((skill) => skill.trim())
        .toList() ?? [];

    return Container(
      padding: EdgeInsets.all(16 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: 22 * ffem,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12 * fem),

          // Skills Row
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
                        color: const Color(0xfff5e1e5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.0 * fem),

          // Event Duration Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.access_alarms,
                size: 24.0,
                color: Colors.grey,
              ),
              SizedBox(width: 8.0),
              Text(
                'Event Duration: ',
                style: TextStyle(
                  fontSize: 19.0 * fem,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
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

          SizedBox(height: 10.0 * fem),

          // Experience Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.work,
                size: 24.0,
                color: Colors.grey,
              ),
              SizedBox(width: 8.0),
              Text(
                'Experience : ',
                style: TextStyle(
                  fontSize: 19.0 * fem,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  trimmedArtistAbout ?? trimmedTeamAbout ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.0 * fem),

          // Previous Bookings Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.event,
                size: 24.0,
                color: Colors.grey,
              ),
              SizedBox(width: 8.0),
              Text(
                'Previous Bookings : ',
                style: TextStyle(
                  fontSize: 19.0 * fem,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  artistState.artist_previous ?? artistState.team_previous ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.0 * fem),

          // Base Location Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 24.0,
                color: Colors.grey,
              ),
              SizedBox(width: 8.0),
              Text(
                'Base Location: ',
                style: TextStyle(
                  fontSize: 19.0 * fem,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  artistState.artistAddress ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.0 * fem),

          // Sound System Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.speaker,
                size: 24.0,
                color: Colors.grey,
              ),
              SizedBox(width: 8.0 * fem),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sound System:',
                      style: TextStyle(
                        fontSize: 18.0 * fem,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 5 * fem),
                    Text(
                      artistState.hasSoundSystem ?? false
                          ? 'Yes'
                          : 'Managed by PrimeStage',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17.0 * fem,
                        color: artistState.hasSoundSystem ?? false
                            ? Colors.green
                            : Colors.pink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection(double fem, double ffem) {
    final artistState = ref.watch(artistStateProvider);

    return Container(
      padding: EdgeInsets.all(16 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message for the Host',
            style: TextStyle(
              fontSize: 22 * ffem,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12 * fem),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * fem),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffe8d1d6)),
              borderRadius: BorderRadius.circular(12 * fem),
            ),
            child: Text(
              artistState.artistSpecialMessage ?? 'No special message available',
              style: TextStyle(
                fontSize: 16 * ffem,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBookingButton(double fem, double ffem) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * fem, vertical: 20 * fem),
    child: ElevatedButton(
    onPressed: _handleBooking,
    style: ElevatedButton.styleFrom(
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12 * fem),
    ),
    ),
    child: Ink(
    decoration: BoxDecoration(
    gradient: const LinearGradient(
    colors: [Color(0xffe5195e), Color(0xffd11b4f)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,            ),
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
            style: TextStyle(
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w700,
              height: 1.5 * ffem / fem,
              letterSpacing: 0.2399999946 * fem,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
    ),
    );
  }
}

// Helper widget for video thumbnails
class VideoThumbnail extends ConsumerWidget {
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

  String? getYoutubeId(String url) {
    final regExp = RegExp(
        r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*/');
    final match = regExp.firstMatch(url);
    return match?[7];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                )
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
                )
              else
                Container(
                  color: Colors.black87,
                  height: double.infinity,
                  width: double.infinity,
                ),
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

// Helper widget for full screen media view
class FullScreenMediaView extends StatelessWidget {
  final String mediaUrl;
  final bool isPhoto;

  const FullScreenMediaView({
    Key? key,
    required this.mediaUrl,
    required this.isPhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: isPhoto
            ? Image.network(
          mediaUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text(
            'Image not available',
            style: TextStyle(color: Colors.white),
          ),
        )
            : AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoThumbnail(
            videoUrl: mediaUrl,
            thumbnailUrl: '',
            fem: MediaQuery.of(context).size.width / 390,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenVideoView(
                    videoUrl: mediaUrl,
                    allVideos: [mediaUrl],
                    allThumbnails: [''],
                    initialIndex: 0,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}