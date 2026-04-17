import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sahtek/core/services/local_notification_service.dart';
import 'package:sahtek/services/chat_service.dart';

class ChatRealtimeService with WidgetsBindingObserver {
  ChatRealtimeService._();

  static final ChatRealtimeService instance = ChatRealtimeService._();

  final ChatServiceSocket _chatSocket = ChatServiceSocket();

  StreamSubscription<SocketMessageEvent>? _newMessageSub;
  StreamSubscription<Map<String, dynamic>>? _notificationSub;
  StreamSubscription<dynamic>? _errorSub;

  bool _started = false;
  final Map<String, DateTime> _recentNotificationKeys = {};

  Future<void> start() async {
    if (_started) return;
    _started = true;

    WidgetsBinding.instance.addObserver(this);

    await LocalNotificationService.initialize();
    await _connectIfPossible();
    _bindStreams();
  }

  Future<void> _connectIfPossible() async {
    try {
      await _chatSocket.initialize();
    } catch (e) {
      // No token or no network at launch: keep app running and retry on resume.
      debugPrint('Chat realtime not connected at startup: $e');
    }
  }

  void _bindStreams() {
    _newMessageSub ??= _chatSocket.newMessageStream.listen((event) async {
      if (event.message.isMe) return;

      final sender = event.senderName.isNotEmpty
          ? event.senderName
          : (event.message.senderId.isNotEmpty
                ? event.message.senderId
                : 'New message');
      final preview = event.message.text.isNotEmpty
          ? event.message.text
          : 'You received a new message';

      if (!_shouldNotify('$sender|$preview')) return;

      await LocalNotificationService.showChatNotification(
        title: sender,
        body: preview,
      );
    });

    _notificationSub ??= _chatSocket.notificationStream.listen((payload) async {
      final title = payload['senderName']?.toString() ?? 'New message';
      final body =
          payload['preview']?.toString() ?? 'You received a new message';

      if (!_shouldNotify('$title|$body')) return;

      await LocalNotificationService.showChatNotification(
        title: title,
        body: body,
      );
    });

    _errorSub ??= _chatSocket.errorStream.listen((error) {
      debugPrint('Chat realtime socket error: $error');
    });
  }

  bool _shouldNotify(String key) {
    final now = DateTime.now();

    _recentNotificationKeys.removeWhere(
      (_, timestamp) => now.difference(timestamp) > const Duration(seconds: 3),
    );

    if (_recentNotificationKeys.containsKey(key)) {
      return false;
    }

    _recentNotificationKeys[key] = now;
    return true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _connectIfPossible();
    }
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _newMessageSub?.cancel();
    await _notificationSub?.cancel();
    await _errorSub?.cancel();
    _newMessageSub = null;
    _notificationSub = null;
    _errorSub = null;
    _started = false;
  }
}
