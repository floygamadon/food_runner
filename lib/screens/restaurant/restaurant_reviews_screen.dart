import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../services/auth_service.dart';
import '../../services/review_service.dart';

class RestaurantReviewsScreen extends StatelessWidget {
  const RestaurantReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final reviewService = ReviewService();

    final restaurantId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Reviews'),
      ),
      body: StreamBuilder<List<ReviewModel>>(
        stream: reviewService.streamRestaurantReviews(restaurantId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading reviews'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data!;

          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews yet'));
          }

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text('${review.rating} / 5 Stars'),
                  subtitle: Text(review.comment),
                ),
              );
            },
          );
        },
      ),
    );
  }
}