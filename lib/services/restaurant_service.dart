import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';

class RestaurantService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Restaurant>> streamRestaurants() {
    return _db.collection('restaurants').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Restaurant.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<List<MenuItemModel>> streamMenuItems(String restaurantId) {
    return _db
        .collection('menuItems')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MenuItemModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<String> uploadFoodImage({
    required File imageFile,
    required String fileName,
  }) async {
    final ref = _storage.ref().child('food_photos/$fileName');

    await ref.putFile(imageFile);

    return ref.getDownloadURL();
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    await _db.collection('menuItems').add(item.toMap());
  }
}