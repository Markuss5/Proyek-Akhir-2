import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:giliranku/core/services/notificationService.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message: ${message.messageId}');
  await _showFcmNotification(message);
}

Future<void> _showFcmNotification(RemoteMessage message) async {
  try {
    final notifId = message.hashCode.abs() % 100000;
    final title = message.notification?.title ?? message.data['title'] ?? 'GiliranKu';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    await NotificationService().showNow(
      id: notifId,
      title: title,
      body: body,
      payload: message.data['payload'],
    );
  } catch (e) {
    debugPrint('FCM show notification error: $e');
  }
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM foreground message: ${message.messageId}');
        _showFcmNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM opened from background: ${message.messageId}');
      });

      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint('FcmService.initialize error: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('FCM getToken error: $e');
      return null;
    }
  }
}