// lib/widgets/artist_reviews.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../widgets/artist_videos.dart';

// Provider for reviews state
final reviewsStateProvider = StateNotifierProvider<ReviewsStateNotifier, ReviewsState>((ref) {
  return ReviewsStateNotifier();
});

class ReviewsState {
  final bool isLoading;
  final String? error;
  final double averageRating;
  final int totalReviews;
  final Map<int, double> ratingDistribution;
  final List<Map<String, dynamic>> reviews;

  ReviewsState({
    this.isLoading = true,
    this.error,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.ratingDistribution = const {},
    this.reviews = const [],
  });

  ReviewsState copyWith({
    bool? isLoading,
    String? error,
    double? averageRating,
    int? totalReviews,
    Map<int, double>? ratingDistribution,
    List<Map<String, dynamic>>? reviews,
  }) {
    return ReviewsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
      reviews: reviews ?? this.reviews,
    );
  }
}

class ReviewsStateNotifier extends StateNotifier<ReviewsState> {
  ReviewsStateNotifier() : super(ReviewsState());

  Future<void> fetchReviews(String artistId, String isTeam) async {
    try {
      state = state.copyWith(isLoading: true);

      String apiUrl = isTeam == "true"
          ? '${Config().apiDomain}/review/team/$artistId'
          : '${Config().apiDomain}/review/$artistId';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> rawReviews = json.decode(response.body);
        await _processReviews(rawReviews);
      } else {
        state = state.copyWith(
          error: 'Failed to fetch reviews',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error fetching reviews: $e',
        isLoading: false,
      );
    }
  }

  Future<void> _processReviews(List<dynamic> rawReviews) async {
    try {
      List<Map<String, dynamic>> reviews = List<Map<String, dynamic>>.from(rawReviews);

      // Calculate average rating and distribution
      double totalRating = 0;
      Map<int, int> ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var review in reviews) {
        int rating = review['rating'] ?? 0;
        totalRating += rating;
        ratingCounts[rating] = (ratingCounts[rating] ?? 0) + 1;
      }

      double averageRating = reviews.isEmpty ? 0 : totalRating / reviews.length;
      Map<int, double> ratingDistribution = {};

      ratingCounts.forEach((rating, count) {
        ratingDistribution[rating] = reviews.isEmpty ? 0 : count / reviews.length;
      });

      // Fetch usernames for reviews
      await _fetchUsernames(reviews);

      state = state.copyWith(
        isLoading: false,
        averageRating: averageRating,
        totalReviews: reviews.length,
        ratingDistribution: ratingDistribution,
        reviews: reviews,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Error processing reviews: $e',
        isLoading: false,
      );
    }
  }

  Future<void> _fetchUsernames(List<Map<String, dynamic>> reviews) async {
    try {
      List<int?> userIds = reviews
          .map((review) => review['user_id'] as int?)
          .where((id) => id != null)
          .toList();

      final response = await http.post(
        Uri.parse('${Config().apiDomain}/review/usernames'),
        headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
        body: jsonEncode({'user_ids': userIds}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        List<dynamic> userNames = responseData['names'] ?? [];

        for (int i = 0; i < reviews.length; i++) {
          reviews[i]['user_name'] = (i < userNames.length && userNames[i] != null)
              ? userNames[i].toString()
              : 'Unknown User';
        }
      }
    } catch (e) {
      print('Error fetching usernames: $e');
    }
  }
}

class ReviewsSection extends StatelessWidget {
  final String artistId;
  final String isTeam;
  final double averageRating;
  final int totalReviews;

  final Map<int, double> ratingDistribution;

  const ReviewsSection({
    Key? key,
    required this.artistId,
    required this.isTeam,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: TextStyle(
            fontSize: 22 * ffem,
            fontWeight: FontWeight.w600,
            color: Color(0xff1c0c11),
          ),
        ),
        SizedBox(height: 10 * fem),

        // Average Rating Row
        Row(
          children: [
            Icon(Icons.star, color: Color(0xFFFFB300), size: 30 * fem),
            SizedBox(width: 8 * fem),
            Text(
              averageRating.toStringAsFixed(1),
              style: TextStyle(fontSize: 24 * fem, fontWeight: FontWeight.bold),
            ),
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

        // Rating Distribution
        Column(
          children: List.generate(5, (index) {
            int starCount = 5 - index;
            return _buildRatingLine(
                starCount,
                ratingDistribution[starCount] ?? 0.0,
                fem
            );
          }),
        ),

        SizedBox(height: 16 * fem),

        // See All Reviews Button
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllReviewsPage(
                    artistId: artistId,
                    isTeam: isTeam,
                  ),
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

  Widget _buildRatingLine(int starCount, double percentage, double fem) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(5.0 * fem, 0, 0, 0),
          child: Text(
            "$starCount star",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18 * fem,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8 * fem),
        Padding(
          padding: EdgeInsets.fromLTRB(12.0 * fem, 0, 0, 0),
          child: Container(
            width: 270 * fem,
            height: 9 * fem,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5 * fem),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xffe5195e)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// AllReviewsPage implementation follows...
// Continuation of artist_reviews.dart - AllReviewsPage implementation

class AllReviewsPage extends ConsumerStatefulWidget {
  final String artistId;
  final String isTeam;

  const AllReviewsPage({
    Key? key,
    required this.artistId,
    required this.isTeam,
  }) : super(key: key);

  @override
  ConsumerState<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends ConsumerState<AllReviewsPage> {
  @override
  void initState() {
    super.initState();
    ref.read(reviewsStateProvider.notifier).fetchReviews(widget.artistId, widget.isTeam);
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(reviewsStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'All Reviews',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: reviewsState.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: reviewsState.reviews.length,
        itemBuilder: (context, index) => _buildReviewItem(
          reviewsState.reviews[index],
          MediaQuery.of(context).size.width / 390,
        ),
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review, double fem) {
    String reviewText = review['review_text'] ?? '';
    List<String> words = reviewText.split(' ');
    String heading = words.isNotEmpty ? words[0] : '';
    String description = words.length > 1 ? words.sublist(1).join(' ') : '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15 * fem, horizontal: 16 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfilePicture(review, fem),
              SizedBox(width: 12 * fem),
              Expanded(
                child: _buildReviewContent(
                  review,
                  heading,
                  description,
                  fem,
                ),
              ),
            ],
          ),
          if (review['photo'] != null && review['photo'].isNotEmpty)
            _buildMediaSection(review, fem),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(Map<String, dynamic> review, double fem) {
    return CircleAvatar(
      radius: 26 * fem,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: review['profile'] != null && review['profile'].isNotEmpty
            ? Image.network(
          review['profile'],
          width: 52 * fem,
          height: 52 * fem,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.account_circle,
            size: 52 * fem,
            color: Colors.grey[400],
          ),
        )
            : Icon(
          Icons.account_circle,
          size: 52 * fem,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildReviewContent(
      Map<String, dynamic> review,
      String heading,
      String description,
      double fem,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              review['user_name'] ?? 'Anonymous',
              style: TextStyle(
                fontSize: 17 * fem,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildStarRating(review['rating'] ?? 0),
          ],
        ),
        SizedBox(height: 4 * fem),
        Text(
          heading,
          style: TextStyle(
            fontSize: 15 * fem,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4 * fem),
        Text(
          description,
          style: TextStyle(
            fontSize: 15 * fem,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating(int rating) {
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

  Widget _buildMediaSection(Map<String, dynamic> review, double fem) {
    return Padding(
      padding: EdgeInsets.fromLTRB(70 * fem, 10 * fem, 0, 0),
      child: GestureDetector(
        onTap: () => _showMediaFullScreen(review['photo'], true),
        child: Image.network(
          review['photo'],
          width: 100 * fem,
          height: 100 * fem,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 100 * fem,
            width: 100 * fem,
            color: Colors.grey[200],
            child: Center(child: Text('Image not available')),
          ),
        ),
      ),
    );
  }

  void _showMediaFullScreen(String mediaUrl, bool isPhoto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaView(
          mediaUrl: mediaUrl,
          isPhoto: isPhoto,
        ),
      ),
    );
  }
}

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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: isPhoto
            ? Image.network(
          mediaUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Text(
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