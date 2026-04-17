import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _chatChannel =
      AndroidNotificationChannel(
        'chat_messages',
        'Chat Messages',
        description: 'Notifications for incoming chat messages',
        importance: Importance.max,
        playSound: true,
      );

  static bool _initialized = false;
  static bool _isSupported = true;
  static int _notificationId = 0;

  static Future<void> initialize() async {
    if (_initialized || !_isSupported) return;

    // Local notifications are not available on web.
    if (kIsWeb) {
      _isSupported = false;
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _plugin.initialize(initSettings);

      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidImpl?.requestNotificationsPermission();
      await androidImpl?.createNotificationChannel(_chatChannel);

      _initialized = true;
    } on MissingPluginException {
      // Usually happens before a full restart after adding the plugin.
      _isSupported = false;
      debugPrint(
        'flutter_local_notifications plugin is not registered yet. '
        'Do a full restart/rebuild of the app.',
      );
    } catch (e) {
      _isSupported = false;
      debugPrint('Failed to initialize local notifications: $e');
    }
  }

  static Future<void> showChatNotification({
    required String title,
    required String body,
  }) async {
    if (!_isSupported) return;

    if (!_initialized) {
      await initialize();
    }

    if (!_initialized) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _chatChannel.id,
        _chatChannel.name,
        channelDescription: _chatChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    );

    _notificationId++;
    await _plugin.show(_notificationId, title, body, details);
  }
}
