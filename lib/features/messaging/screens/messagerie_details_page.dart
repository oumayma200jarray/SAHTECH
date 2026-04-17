import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/models/dashboard_models.dart';
import 'package:sahtek/services/chat_service.dart';
import 'package:easy_localization/easy_localization.dart';

class MessagerieDetailsPage extends StatefulWidget {
  final String conversationId;
  final String doctorName;

  const MessagerieDetailsPage({
    Key? key,
    required this.conversationId,
    required this.doctorName,
  }) : super(key: key);

  @override
  State<MessagerieDetailsPage> createState() => _MessagerieDetailsPageState();
}

class _MessagerieDetailsPageState extends State<MessagerieDetailsPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatServiceSocket _chatSocket = ChatServiceSocket();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isSocketReady = false;

  StreamSubscription<SocketMessageEvent>? _newMessageSub;
  StreamSubscription<SocketMessagesReadEvent>? _messagesReadSub;
  StreamSubscription<Map<String, dynamic>>? _notificationSub;
  StreamSubscription<Map<String, dynamic>>? _conversationUpdatedSub;
  StreamSubscription<dynamic>? _errorSub;
  bool _isSyncingFromEvent = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initializeRealtime();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final fetched = await ChatRestService.getMessages(widget.conversationId);
    if (!mounted) return;

    setState(() {
      _messages
        ..clear()
        ..addAll(fetched);
      _isLoading = false;
    });
  }

  Future<void> _initializeRealtime() async {
    try {
      await _chatSocket.initialize();

      _newMessageSub = _chatSocket.newMessageStream.listen((event) {
        if (!mounted) return;

        // Some backends may omit conversationId in new_message payload.
        if (event.conversationId.isNotEmpty &&
            event.conversationId != widget.conversationId) {
          return;
        }

        if (event.conversationId.isEmpty) {
          _syncMessagesFromEvent();
          return;
        }

        final exists = _messages.any((m) => m.id == event.message.id);
        if (exists) return;

        setState(() {
          _messages.add(event.message);
        });
      });

      _notificationSub = _chatSocket.notificationStream.listen((payload) {
        if (!mounted) return;
        final conversationId = payload['conversationId']?.toString() ?? '';
        if (conversationId == widget.conversationId) {
          _syncMessagesFromEvent();
        }
      });

      _conversationUpdatedSub = _chatSocket.conversationUpdatedStream.listen((
        payload,
      ) {
        if (!mounted) return;
        final conversationId = payload['conversationId']?.toString() ?? '';
        if (conversationId == widget.conversationId) {
          _syncMessagesFromEvent();
        }
      });

      _messagesReadSub = _chatSocket.messagesReadStream.listen((event) {
        // Ready for UI read-receipt badges if needed.
      });

      _errorSub = _chatSocket.errorStream.listen((error) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Chat error: $error')));
      });

      await _chatSocket.joinConversation(widget.conversationId);
      await _chatSocket.markAsRead(widget.conversationId);

      if (mounted) {
        setState(() {
          _isSocketReady = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Realtime unavailable, using REST only: $e')),
      );
    }
  }

  Future<void> _syncMessagesFromEvent() async {
    if (_isSyncingFromEvent) return;
    _isSyncingFromEvent = true;
    try {
      await _loadMessages(silent: true);
    } finally {
      _isSyncingFromEvent = false;
    }
  }

  void _showNotification(Map<String, dynamic> notification) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${notification['senderName']}: ${notification['preview']}',
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0D54F2),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    _messageController.clear();

    if (_isSocketReady) {
      try {
        await _chatSocket.sendMessage(widget.conversationId, message);
      } catch (_) {
        final sent = await ChatRestService.sendMessage(
          conversationId: widget.conversationId,
          content: message,
        );
        if (sent != null) {
          await _loadMessages(silent: true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('failed_to_send_message'.tr())),
          );
        }
      }
    } else {
      final sent = await ChatRestService.sendMessage(
        conversationId: widget.conversationId,
        content: message,
      );
      if (sent != null) {
        await _loadMessages(silent: true);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('failed_to_send_message'.tr())));
      }
    }

    if (mounted) {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE3EAFF),
              child: Text(
                widget.doctorName.isNotEmpty
                    ? widget.doctorName[0].toUpperCase()
                    : 'M',
                style: const TextStyle(
                  color: Color(0xFF0D54F2),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isSocketReady ? 'Realtime connected' : 'REST fallback',
                  style: TextStyle(
                    color: _isSocketReady ? Colors.green : Colors.grey[600],
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.blue),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'end_to_end_encryption'.tr(),
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? Center(
                    child: Text(
                      'no_messages_yet'.tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: msg.isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: msg.isMe ? Colors.blue[700] : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(msg.isMe ? 20 : 0),
                bottomRight: Radius.circular(msg.isMe ? 0 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.type == MessageType.image)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      UrlHelper.fixImageUrl(msg.attachmentUrl!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (msg.type == MessageType.pdf)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          msg.text,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (msg.type != MessageType.pdf)
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.grey, fontSize: 9),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          _buildCircleButton(Icons.add, Colors.blue, onPressed: () {}),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) async => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'write_message_hint'.tr(),
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildCircleButton(
            Icons.send,
            Colors.blue,
            onPressed: _isSending ? () {} : () => _sendMessage(),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    Color bg, {
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  void dispose() {
    _newMessageSub?.cancel();
    _messagesReadSub?.cancel();
    _notificationSub?.cancel();
    _conversationUpdatedSub?.cancel();
    _errorSub?.cancel();
    _messageController.dispose();
    super.dispose();
  }
}
