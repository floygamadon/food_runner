import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> initializeAndSaveToken(String uid) async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();

    if (token != null) {
      await _db.collection('users').doc(uid).update({
        'fcmToken': token,
      });
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Foreground notification skeleton
      print('Foreground FCM: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // User tapped notification
      print('Opened FCM: ${message.data}');
    });
  }
}