import 'package:flutter/material.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/models/dashboard_models.dart';
import 'package:sahtek/features/dashboard/services/dashboard_services.dart';
import 'package:easy_localization/easy_localization.dart';

class MessageriePage extends StatefulWidget {
  const MessageriePage({Key? key}) : super(key: key);

  @override
  State<MessageriePage> createState() => _MessageriePageState();
}

class _MessageriePageState extends State<MessageriePage> {
  final TextEditingController _messageController = TextEditingController();
  late Future<ChatConversation> _conversationFuture;

  @override
  void initState() {
    super.initState();
    _conversationFuture = ChatService.getConversation();
  }

  void _refreshMessages() {
    setState(() {
      _conversationFuture = ChatService.getConversation();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Récupération du nom passé en argument (si présent)
    final String? argName =
        ModalRoute.of(context)?.settings.arguments as String?;
    final String initialName = argName ?? 'doctor_placeholder'.tr();

    return FutureBuilder<ChatConversation>(
      future: _conversationFuture,
      initialData: ChatConversation.placeholder(initialName),
      builder: (context, snapshot) {
        final conversation =
            snapshot.data ?? ChatConversation.placeholder(initialName);
        final messages = conversation.messages;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.blue,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE3EAFF),
                  child: Text(
                    conversation.doctorName.isNotEmpty
                        ? conversation.doctorName[0].toUpperCase()
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
                      conversation.doctorName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (conversation.specialty.isNotEmpty)
                      Text(
                        conversation.specialty.toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey[600],
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
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : messages.isEmpty
                    ? Center(
                        child: Text(
                          "no_messages_yet".tr(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: messages.length,
                        itemBuilder: (context, index) =>
                            _buildMessageBubble(messages[index]),
                      ),
              ),
              _buildInputArea(),
            ],
          ),
        );
      },
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
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                // Simulation d'envoi
                print("Message envoyé: ${_messageController.text}");
                _messageController.clear();
                _refreshMessages();
              }
            },
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
}
