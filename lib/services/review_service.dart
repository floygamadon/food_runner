import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addReview({
    required String orderId,
    required String customerId,
    required String restaurantId,
    required int rating,
    required String comment,
  }) async {
    await _db.collection('reviews').add({
      'orderId': orderId,
      'customerId': customerId,
      'restaurantId': restaurantId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('orders').doc(orderId).update({
      'reviewed': true,
    });
  }

  Stream<List<ReviewModel>> streamRestaurantReviews(String restaurantId) {
    return _db
        .collection('reviews')
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReviewModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}