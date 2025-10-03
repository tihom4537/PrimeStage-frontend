import 'package:flutter/material.dart';

class ReviewsSection extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, double> ratingDistribution; // Star rating and its percentage

  ReviewsSection({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average Rating Row
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 30),
            SizedBox(width: 8),
            Text(
              averageRating.toStringAsFixed(1),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Text("($totalReviews reviews)",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
        SizedBox(height: 16),

        // Rating Distribution (5-star, 4-star, etc.)
        Column(
          children: List.generate(5, (index) {
            int starCount = 5 - index;
            return _buildRatingLine(starCount, ratingDistribution[starCount] ?? 0.0);
          }),
        ),

        SizedBox(height: 16),

        // Button to see all reviews
        Center(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to a page that shows all reviews
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => AllReviewsPage(),
              ));
            },
            child: Text("See All Reviews"),
          ),
        ),
      ],
    );
  }

  // Helper function to build rating lines
  Widget _buildRatingLine(int starCount, double percentage) {
    return Row(
      children: [
        Text("$starCount star", style: TextStyle(color: Colors.grey)),
        SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage, // Percentage of reviews for this star
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ),
        SizedBox(width: 8),
        Text("${(percentage * 100).toInt()}%"),
      ],
    );
  }
}

class AllReviewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Reviews')),
      body: Center(child: Text('List of all reviews here')),
    );
  }
}