import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/review_service.dart';

class ReviewScreen extends StatefulWidget {
  final OrderModel order;

  const ReviewScreen({
    super.key,
    required this.order,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ReviewService _reviewService = ReviewService();
  final AuthService _authService = AuthService();

  final TextEditingController _commentController = TextEditingController();

  int _rating = 5;
  bool _isLoading = false;

  Future<void> _submitReview() async {
    final user = _authService.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    await _reviewService.addReview(
      orderId: widget.order.id,
      customerId: user.uid,
      restaurantId: widget.order.restaurantId,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context);
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Rating'),
            DropdownButton<int>(
              value: _rating,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 Star')),
                DropdownMenuItem(value: 2, child: Text('2 Stars')),
                DropdownMenuItem(value: 3, child: Text('3 Stars')),
                DropdownMenuItem(value: 4, child: Text('4 Stars')),
                DropdownMenuItem(value: 5, child: Text('5 Stars')),
              ],
              onChanged: (value) {
                setState(() {
                  _rating = value!;
                });
              },
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comment',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitReview,
              child: Text(_isLoading ? 'Submitting...' : 'Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}