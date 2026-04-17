import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/core/config/app_config.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/models/dashboard_models.dart';

typedef MessageCallback = Function(ChatMessage message);
typedef NotificationCallback = Function(Map<String, dynamic> notification);
typedef MessagesReadCallback = Function(String conversationId, String readBy);

class SocketMessageEvent {
  final String conversationId;
  final ChatMessage message;
  final String senderName;

  SocketMessageEvent({
    required this.conversationId,
    required this.message,
    required this.senderName,
  });
}

class SocketMessagesReadEvent {
  final String conversationId;
  final String readBy;

  SocketMessagesReadEvent({required this.conversationId, required this.readBy});
}

class ChatServiceSocket {
  static final ChatServiceSocket _instance = ChatServiceSocket._internal();

  late IO.Socket _socket;
  String? _authToken;
  bool _isConnected = false;
  String? _currentUserId;
  Completer<void>? _connectCompleter;
  bool _listenersAttached = false;

  final StreamController<SocketMessageEvent> _newMessageController =
      StreamController<SocketMessageEvent>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<SocketMessagesReadEvent> _messagesReadController =
      StreamController<SocketMessagesReadEvent>.broadcast();
  final StreamController<Map<String, dynamic>> _conversationUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<int> _unreadCountUpdatedController =
      StreamController<int>.broadcast();
  final StreamController<Map<String, dynamic>> _joinedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<dynamic> _errorController =
      StreamController<dynamic>.broadcast();

  // Callbacks
  MessageCallback? _onNewMessage;
  NotificationCallback? _onNotification;
  MessagesReadCallback? _onMessagesRead;

  ChatServiceSocket._internal();

  factory ChatServiceSocket() {
    return _instance;
  }

  bool get isConnected => _isConnected;

  String? get currentUserId => _currentUserId;

  Stream<SocketMessageEvent> get newMessageStream =>
      _newMessageController.stream;
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;
  Stream<SocketMessagesReadEvent> get messagesReadStream =>
      _messagesReadController.stream;
  Stream<Map<String, dynamic>> get conversationUpdatedStream =>
      _conversationUpdatedController.stream;
  Stream<int> get unreadCountUpdatedStream =>
      _unreadCountUpdatedController.stream;
  Stream<Map<String, dynamic>> get joinedStream => _joinedController.stream;
  Stream<dynamic> get errorStream => _errorController.stream;

  // ─── Initialize Socket Connection ─────────────────────────────────────
  Future<void> initialize() async {
    try {
      if (_isConnected) return;

      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('accessToken');
      _currentUserId = prefs.getString('userId');

      if (_authToken == null) {
        throw Exception('No auth token found');
      }

      // Connect to the gateway namespace used by NestJS (@WebSocketGateway namespace: '/chat').
      final wsUrl =
          '${AppConfig.apiBaseUrl.replaceFirst('http', 'ws')}${EndPoint.chatWebSocketNamespace}';

      _connectCompleter = Completer<void>();

      _socket = IO.io(
        wsUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': _authToken})
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      // ─── Connection Events ────────────────────────────────
      _socket.onConnect((_) {
        _isConnected = true;
        print('✅ Chat connected');
        if (!(_connectCompleter?.isCompleted ?? true)) {
          _connectCompleter?.complete();
        }
      });

      _socket.onDisconnect((_) {
        _isConnected = false;
        print('❌ Chat disconnected');
      });

      _socket.onConnectError((error) {
        print('❌ Chat connect error: $error');
        _errorController.add(error);
        if (!(_connectCompleter?.isCompleted ?? true)) {
          _connectCompleter?.completeError(error ?? 'Connection error');
        }
      });

      _socket.onError((error) {
        print('❌ Chat error: $error');
        _errorController.add(error);
      });

      if (!_listenersAttached) {
        _attachSocketEventListeners();
        _listenersAttached = true;
      }

      _socket.connect();
      await _connectCompleter!.future.timeout(const Duration(seconds: 8));
    } catch (e) {
      print('❌ Failed to initialize chat: $e');
      rethrow;
    }
  }

  void _attachSocketEventListeners() {
    // ─── Listen for new messages ──────────────────────────
    _socket.on('new_message', (data) {
      print('📨 New message received: $data');
      final map = (data as Map?)?.cast<String, dynamic>() ?? const {};
      final conversationId = map['conversationId']?.toString() ?? '';
      final message = ChatMessage(
        id: map['messageId']?.toString() ?? '',
        senderId: map['senderId']?.toString() ?? '',
        text: map['content']?.toString() ?? '',
        isMe: map['senderId']?.toString() == _currentUserId,
        timestamp: DateTime.parse(
          map['createdAt']?.toString() ?? DateTime.now().toString(),
        ),
        type: MessageType.text,
        attachmentUrl: null,
      );

      if (_onNewMessage != null) {
        _onNewMessage!(message);
      }

      _newMessageController.add(
        SocketMessageEvent(
          conversationId: conversationId,
          message: message,
          senderName: map['senderName']?.toString() ?? '',
        ),
      );
    });

    // ─── Listen for notifications ──────────────────────────
    _socket.on('notification', (data) {
      print('🔔 Notification received: $data');
      final map = (data as Map?)?.cast<String, dynamic>() ?? const {};
      if (_onNotification != null) {
        _onNotification!(map);
      }
      _notificationController.add(map);
    });

    // ─── Listen for messages read ──────────────────────────
    _socket.on('messages_read', (data) {
      print('✓✓ Messages marked as read: $data');
      final map = (data as Map?)?.cast<String, dynamic>() ?? const {};
      final event = SocketMessagesReadEvent(
        conversationId: map['conversationId']?.toString() ?? '',
        readBy: map['readBy']?.toString() ?? '',
      );
      if (_onMessagesRead != null) {
        _onMessagesRead!(event.conversationId, event.readBy);
      }
      _messagesReadController.add(event);
    });

    _socket.on('conversation_updated', (data) {
      final map = (data as Map?)?.cast<String, dynamic>() ?? const {};
      _conversationUpdatedController.add(map);
    });

    _socket.on('unread_count_updated', (data) {
      final map = (data as Map?)?.cast<String, dynamic>() ?? const {};
      final count = (map['count'] as num?)?.toInt() ?? 0;
      _unreadCountUpdatedController.add(count);
    });

    _socket.on('joined', (data) {
      final map = (data as Map?)?.cast<String, dynamic>() ?? const {};
      _joinedController.add(map);
    });

    _socket.on('error', (data) {
      _errorController.add(data);
    });
  }

  void setOnNewMessage(MessageCallback callback) {
    _onNewMessage = callback;
  }

  void setOnNotification(NotificationCallback callback) {
    _onNotification = callback;
  }

  void setOnMessagesRead(MessagesReadCallback callback) {
    _onMessagesRead = callback;
  }

  // ─── Join Conversation ────────────────────────────────────────────────
  Future<void> joinConversation(String conversationId) async {
    if (!_isConnected) {
      await initialize();
    }
    if (!_isConnected) {
      print('⚠️ Socket not connected');
      return;
    }
    _socket.emit('join_conversation', {'conversationId': conversationId});
    print('📍 Joined conversation: $conversationId');
  }

  // ─── Send Message ─────────────────────────────────────────────────────
  Future<void> sendMessage(String conversationId, String content) async {
    if (!_isConnected) {
      await initialize();
    }
    if (!_isConnected) {
      print('⚠️ Socket not connected');
      return;
    }
    _socket.emit('send_message', {
      'conversationId': conversationId,
      'content': content,
    });
    print('📤 Message sent to: $conversationId');
  }

  // ─── Mark as Read ─────────────────────────────────────────────────────
  Future<void> markAsRead(String conversationId) async {
    if (!_isConnected) {
      await initialize();
    }
    if (!_isConnected) {
      print('⚠️ Socket not connected');
      return;
    }
    _socket.emit('mark_read', {'conversationId': conversationId});
    print('✓ Marked as read: $conversationId');
  }

  void disconnect() {
    _socket.disconnect();
    _isConnected = false;
  }
}

// ─── REST API Calls ──────────────────────────────────────────────────────
class ChatRestService {
  static Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  /// Get all conversations for the current user
  static Future<List<ConversationPreview>> getConversations() async {
    try {
      final List<dynamic> data = await EndPoint.client.get(
        EndPoint.chatConversations,
      );
      return data.map((item) => ConversationPreview.fromJson(item)).toList();
    } catch (e) {
      print('❌ Error fetching conversations: $e');
      return [];
    }
  }

  /// Get messages for a specific conversation
  static Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final currentUserId = await _getCurrentUserId();
      final List<dynamic> data = await EndPoint.client.get(
        EndPoint.chatMessages(conversationId),
      );
      return data
          .map((item) => _parseMessageFromApi(item, currentUserId))
          .toList();
    } catch (e) {
      print('❌ Error fetching messages: $e');
      return [];
    }
  }

  /// Send a message using REST API (POST /chat/conversations/:id/messages)
  static Future<ChatMessage?> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final currentUserId = await _getCurrentUserId();
      final data = await EndPoint.client.post(
        EndPoint.chatSendMessage(conversationId),
        body: {'content': content},
      );

      if (data is Map<String, dynamic>) {
        return _parseMessageFromApi(data, currentUserId);
      }
      return null;
    } catch (e) {
      print('❌ Error sending message: $e');
      return null;
    }
  }

  /// Get unread message count
  static Future<int> getUnreadCount() async {
    try {
      final data = await EndPoint.client.get(EndPoint.chatUnreadCount);
      return data['count'] ?? 0;
    } catch (e) {
      print('❌ Error fetching unread count: $e');
      return 0;
    }
  }

  static ChatMessage _parseMessageFromApi(
    Map<String, dynamic> json,
    String? currentUserId,
  ) {
    final senderId = json['senderId'] ?? '';
    return ChatMessage(
      id: json['messageId'] ?? json['id'] ?? '',
      senderId: senderId,
      text: json['content'] ?? json['text'] ?? '',
      isMe: currentUserId != null && senderId == currentUserId,
      timestamp: DateTime.parse(
        json['createdAt'] ?? json['timestamp'] ?? DateTime.now().toString(),
      ),
      type: MessageType.text,
      attachmentUrl: null,
    );
  }
}

// ─── Models Extended ──────────────────────────────────────────────────────
class ConversationPreview {
  final String conversationId;
  final String doctorName;
  final String avatarUrl;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isRead;
  final bool isOnline;

  ConversationPreview({
    required this.conversationId,
    required this.doctorName,
    required this.avatarUrl,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isRead,
    required this.isOnline,
  });

  factory ConversationPreview.fromJson(Map<String, dynamic> json) {
    final specialist =
        (json['specialist'] as Map<String, dynamic>?) ?? const {};
    final specialistUser =
        (specialist['user'] as Map<String, dynamic>?) ?? const {};
    final patient = (json['patient'] as Map<String, dynamic>?) ?? const {};
    final patientUser = (patient['user'] as Map<String, dynamic>?) ?? const {};

    final messages = (json['messages'] as List<dynamic>?) ?? const [];
    final lastMessage = messages.isNotEmpty
        ? (messages.first as Map<String, dynamic>?) ?? const {}
        : const <String, dynamic>{};

    return ConversationPreview(
      conversationId: json['conversationId'] ?? '',
      doctorName:
          specialistUser['fullName'] ?? patientUser['fullName'] ?? 'Unknown',
      avatarUrl: UrlHelper.fixImageUrl(
        specialistUser['imageUrl'] ??
            patientUser['imageUrl'] ??
            'https://i.pravatar.cc/150?u=unknown',
      ),
      lastMessage: lastMessage['content'] ?? 'No messages',
      timestamp: DateTime.parse(
        lastMessage['createdAt'] ?? DateTime.now().toString(),
      ),
      unreadCount: messages
          .whereType<Map<String, dynamic>>()
          .where((m) => m['isRead'] == false)
          .length,
      isRead: true,
      isOnline: false,
    );
  }
}
