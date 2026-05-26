import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/core/config/app_config.dart';

class ExerciseSocketService {
  ExerciseSocketService._();

  static final ExerciseSocketService instance = ExerciseSocketService._();

  IO.Socket? _socket;
  bool _isConnected = false;
  bool _listenersAttached = false;

  final StreamController<Map<String, dynamic>> _exerciseAssignedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get exerciseAssignedStream =>
      _exerciseAssignedController.stream;

  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    try {
      if (_isConnected) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) return;

      final wsUrl =
          '${AppConfig.apiBaseUrl.replaceFirst('http', 'ws')}${EndPoint.exercisesWebSocketNamespace}';

      _socket = IO.io(
        wsUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
        debugPrint('✅ Exercise socket connected');
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        debugPrint('❌ Exercise socket disconnected');
      });

      _socket!.onConnectError((error) {
        debugPrint('❌ Exercise socket connect error: $error');
      });

      _socket!.onError((error) {
        debugPrint('❌ Exercise socket error: $error');
      });

      if (!_listenersAttached) {
        _socket!.on('exercise_assigned', (data) {
          debugPrint('🏃 exercise_assigned: $data');
          final map = (data as Map?)?.cast<String, dynamic>() ?? const {};
          _exerciseAssignedController.add(map);
        });
        _listenersAttached = true;
      }

      _socket!.connect();
    } catch (e) {
      debugPrint('❌ ExerciseSocketService.initialize failed: $e');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
    _listenersAttached = false;
  }
}
