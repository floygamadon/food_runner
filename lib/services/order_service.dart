import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> placeOrder({
    required String customerId,
    required String restaurantId,
    required List<CartItem> cartItems,
  }) async {
    final total = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    final docRef = await _db.collection('orders').add({
      'customerId': customerId,
      'restaurantId': restaurantId,
      'driverId': '',
      'status': 'placed',
      'total': total,
      'items': cartItems.map((item) => item.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Stream<OrderModel> streamOrderById(String orderId) {
    return _db.collection('orders').doc(orderId).snapshots().map((doc) {
      return OrderModel.fromMap(doc.id, doc.data() ?? {});
    });
  }

  Stream<List<OrderModel>> streamCustomerOrders(String customerId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<List<OrderModel>> streamRestaurantOrders(String restaurantId) {
    return _db
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}