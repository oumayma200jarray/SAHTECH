import 'package:flutter/material.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/core/widgets/custom_bottom_nav_bar.dart';
import 'package:sahtek/services/chat_service.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'messagerie_details_page.dart';

class MessageriePage extends StatefulWidget {
  const MessageriePage({Key? key}) : super(key: key);

  @override
  State<MessageriePage> createState() => _MessageriePageState();
}

class _MessageriePageState extends State<MessageriePage> {
  final TextEditingController _searchController = TextEditingController();
  final ChatServiceSocket _chatSocket = ChatServiceSocket();
  late Future<List<ConversationPreview>> _conversationsFuture;
  List<ConversationPreview> _allConversations = [];
  StreamSubscription<Map<String, dynamic>>? _conversationUpdatedSub;
  StreamSubscription<int>? _unreadUpdatedSub;
  StreamSubscription<SocketMessageEvent>? _newMessageSub;
  StreamSubscription<dynamic>? _errorSub;

  @override
  void initState() {
    super.initState();
    _conversationsFuture = ChatRestService.getConversations();
    _initRealtime();
  }

  Future<void> _initRealtime() async {
    try {
      await _chatSocket.initialize();

      _conversationUpdatedSub = _chatSocket.conversationUpdatedStream.listen((
        _,
      ) {
        if (!mounted) return;
        setState(() {
          _conversationsFuture = ChatRestService.getConversations();
        });
      });

      _unreadUpdatedSub = _chatSocket.unreadCountUpdatedStream.listen((_) {
        if (!mounted) return;
        setState(() {
          _conversationsFuture = ChatRestService.getConversations();
        });
      });

      _newMessageSub = _chatSocket.newMessageStream.listen((_) {
        if (!mounted) return;
        setState(() {
          _conversationsFuture = ChatRestService.getConversations();
        });
      });

      _errorSub = _chatSocket.errorStream.listen((error) {
        debugPrint('Chat socket error in conversations page: $error');
      });
    } catch (e) {
      debugPrint('Realtime initialization failed on conversations page: $e');
    }
  }

  Future<void> _refreshConversations() async {
    final future = ChatRestService.getConversations();
    if (!mounted) return;
    setState(() {
      _conversationsFuture = future;
    });
    await future;
  }

  void _filterConversations(String query) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'messages_title'.tr(),
          style: const TextStyle(
            color: Color(0xFF0D54F2),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const NetworkImage(
                "https://i.pravatar.cc/150?u=me",
              ),
              backgroundColor: Colors.grey[200],
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<ConversationPreview>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('error_loading_conversations'.tr()));
          }

          _allConversations = snapshot.data ?? [];
          final query = _searchController.text.trim().toLowerCase();
          final visibleConversations = query.isEmpty
              ? _allConversations
              : _allConversations
                    .where(
                      (conv) => conv.doctorName.toLowerCase().contains(query),
                    )
                    .toList();

          return Column(
            children: [
              _buildSearchBar(),
              _buildRecentHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshConversations,
                  child: visibleConversations.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 120),
                          children: [
                            Center(child: Text('no_conversations'.tr())),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: visibleConversations.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _buildConversationTile(
                                visibleConversations[index],
                              ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterConversations,
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Color(0xFF64748B)),
          hintText: 'search_conversation_hint'.tr(),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRecentHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'recent_conversations'.tr().toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'mark_all_read'.tr(),
              style: const TextStyle(
                color: Color(0xFF0D54F2),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(ConversationPreview conv) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagerieDetailsPage(
              conversationId: conv.conversationId,
              doctorName: conv.doctorName,
            ),
            settings: RouteSettings(arguments: conv.conversationId),
          ),
        ).then((_) {
          // Refresh conversations when returning from details
          setState(() {
            _conversationsFuture = ChatRestService.getConversations();
          });
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage:
                      NetworkImage(UrlHelper.fixImageUrl(conv.avatarUrl)),
                  backgroundColor: Colors.grey[200],
                ),
                if (conv.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  )
                else
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conv.doctorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        _formatTimestamp(conv.timestamp),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: conv.unreadCount > 0
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: conv.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (conv.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D54F2),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            conv.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (conv.isRead)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.done_all,
                            color: Color(0xFF94A3B8),
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min";
    }
    if (diff.inHours < 24) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    if (diff.inDays == 1) {
      return "hier".tr();
    }
    return "${date.day}/${date.month}";
  }

  @override
  void dispose() {
    _conversationUpdatedSub?.cancel();
    _unreadUpdatedSub?.cancel();
    _newMessageSub?.cancel();
    _errorSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
