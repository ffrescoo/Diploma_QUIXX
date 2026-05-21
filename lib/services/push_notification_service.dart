import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // 1. Запит дозволу (обов'язково для iOS, для Android 13+ теж бажано)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Дозвіл на push-повідомлення отримано.');

      // 2. Отримання токена пристрою
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token);
      }

      // 3. Відстеження оновлення токена
      _fcm.onTokenRefresh.listen(_saveTokenToDatabase);

      // 4. Обробка повідомлень у відкритому додатку (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Отримано повідомлення (Foreground): ${message.notification?.title}');
        // Тут можна додати логіку показу in-app сповіщення, наприклад, кастомний віджет
      });
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    // Зберігаємо токен у Firestore, щоб можна було надсилати повідомлення конкретному юзеру
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
        'fcmTokens': FieldValue.arrayUnion([token])
      }, SetOptions(merge: true));
    }
  }
}