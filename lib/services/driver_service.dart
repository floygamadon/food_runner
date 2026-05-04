import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class DriverService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<OrderModel>> streamAvailableOrders() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'ready_for_pickup')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<List<OrderModel>> streamDriverOrders(String driverId) {
    return _db
        .collection('orders')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> acceptOrder({
    required String orderId,
    required String driverId,
  }) async {
    await _db.collection('orders').doc(orderId).update({
      'driverId': driverId,
      'status': 'assigned',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDeliveryStatus({
    required String orderId,
    required String status,
  }) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDriverAvailability({
    required String driverId,
    required bool isAvailable,
  }) async {
    await _db.collection('drivers').doc(driverId).set({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}