import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sahtek/core/services/local_notification_service.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/features/profile/services/profile_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // If Firebase is already initialized by the native side, continue.
  }

  await LocalNotificationService.initialize();

  final title =
      message.notification?.title ?? message.data['title']?.toString();
  final body = message.notification?.body ?? message.data['body']?.toString();

  if (title != null || body != null) {
    await LocalNotificationService.showChatNotification(
      title: title ?? 'Notification',
      body: body ?? '',
    );
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    try {
      await LocalNotificationService.initialize();

      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await StorageService.setFcmToken(token);
        await _syncTokenToBackend(token);
      }

      _messaging.onTokenRefresh.listen((token) async {
        await StorageService.setFcmToken(token);
        await _syncTokenToBackend(token);
      });

      FirebaseMessaging.onMessage.listen((message) async {
        final title =
            message.notification?.title ??
            message.data['title']?.toString() ??
            'Notification';
        final body =
            message.notification?.body ??
            message.data['body']?.toString() ??
            message.data['preview']?.toString() ??
            '';

        await LocalNotificationService.showChatNotification(
          title: title,
          body: body,
        );
      });

      _initialized = true;
    } catch (e) {
      debugPrint('Push notification initialization skipped or failed: $e');
    }
  }

  static Future<void> syncStoredTokenToBackend() async {
    if (kIsWeb) return;

    final token = await StorageService.getFcmToken();
    if (token != null && token.isNotEmpty) {
      await _syncTokenToBackend(token);
    }
  }

  static Future<void> _syncTokenToBackend(String token) async {
    try {
      await ProfileService.updatePushToken(token);
    } catch (e) {
      debugPrint('Unable to sync FCM token to backend: $e');
    }
  }
}
