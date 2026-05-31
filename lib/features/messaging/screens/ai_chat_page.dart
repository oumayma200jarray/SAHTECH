import 'package:flutter/material.dart';
import 'package:sahtek/core/api/endpoint.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<_AiMessage> _messages = [];
  bool _loading = true;
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await EndPoint.client.get(EndPoint.aiHistory);
      final list = data is List ? data : [];
      setState(() {
        _messages = list
            .map((m) => _AiMessage(
                  id: m['id']?.toString() ?? UniqueKey().toString(),
                  text: m['text']?.toString() ?? '',
                  isOwn: m['isOwn'] == true,
                  isSensitive: m['isSensitive'] == true,
                  time: _parseTime(m['time']),
                ))
            .toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _typing) return;

    _messageController.clear();
    setState(() {
      _messages.add(_AiMessage(
        id: 'u-${DateTime.now().millisecondsSinceEpoch}',
        text: content,
        isOwn: true,
        time: DateTime.now(),
      ));
      _typing = true;
    });
    _scrollToBottom();

    try {
      final data = await EndPoint.client.post(
        EndPoint.aiAsk,
        body: {'message': content},
      );
      if (!mounted) return;
      setState(() {
        _messages.add(_AiMessage(
          id: 'a-${DateTime.now().millisecondsSinceEpoch}',
          text: data['answer']?.toString() ?? '…',
          isOwn: false,
          isSensitive: data['isSensitive'] == true,
          time: _parseTime(data['createdAt']),
        ));
        _typing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_AiMessage(
          id: 'err-${DateTime.now().millisecondsSinceEpoch}',
          text: 'Désolé, je n\'ai pas pu répondre. Réessayez plus tard.',
          isOwn: false,
          isError: true,
          time: DateTime.now(),
        ));
        _typing = false;
      });
    }
    _scrollToBottom();
  }

  Future<void> _clearHistory() async {
    final backup = List<_AiMessage>.from(_messages);
    setState(() => _messages = []);
    try {
      await EndPoint.client.delete(EndPoint.aiHistory);
    } catch (_) {
      setState(() => _messages = backup);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'effacer l\'historique')),
        );
      }
    }
  }

  DateTime _parseTime(dynamic raw) {
    try {
      return DateTime.parse(raw.toString()).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

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
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assistant IA',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _typing ? 'En train d\'écrire…' : 'Assistant médical',
                  style: TextStyle(
                    fontSize: 11,
                    color: _typing ? const Color(0xFF8B5CF6) : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            TextButton(
              onPressed: _clearHistory,
              child: const Text(
                'Effacer',
                style: TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'ASSISTANT MÉDICAL IA · USAGE NON MÉDICAL',
              style: TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
      );
    }

    if (_messages.isEmpty && !_typing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Posez une question médicale',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'L\'assistant répond à partir de sources médicales.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_typing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) return _buildTypingIndicator();
        return _buildBubble(_messages[index]);
      },
    );
  }

  Widget _buildBubble(_AiMessage msg) {
    final isOwn = msg.isOwn;

    Color bubbleColor;
    Color textColor;
    if (isOwn) {
      bubbleColor = Colors.blue[700]!;
      textColor = Colors.white;
    } else if (msg.isError) {
      bubbleColor = const Color(0xFFFEF2F2);
      textColor = const Color(0xFFEF4444);
    } else {
      bubbleColor = Colors.white;
      textColor = Colors.black87;
    }

    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isOwn)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ),
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 16),
              ),
            ),
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isOwn ? 20 : 0),
                bottomRight: Radius.circular(isOwn ? 0 : 20),
              ),
              border: msg.isError
                  ? Border.all(color: const Color(0xFFFECACA))
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: isOwn ? 0 : 4,
              right: isOwn ? 4 : 0,
              bottom: 14,
            ),
            child: Text(
              _formatTime(msg.time),
              style: const TextStyle(color: Colors.grey, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 16),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !_typing,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Posez une question à l\'assistant IA…',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _typing ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _typing
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      ),
                color: _typing ? Colors.grey[300] : null,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _AiMessage {
  final String id;
  final String text;
  final bool isOwn;
  final bool isSensitive;
  final bool isError;
  final DateTime time;

  const _AiMessage({
    required this.id,
    required this.text,
    required this.isOwn,
    this.isSensitive = false,
    this.isError = false,
    required this.time,
  });
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final bounce = value < 0.5 ? value * 2 : (1 - value) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Color.lerp(
                  const Color(0xFFCBD5E1),
                  const Color(0xFF8B5CF6),
                  bounce,
                ),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.translationValues(0, -4 * bounce, 0),
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
