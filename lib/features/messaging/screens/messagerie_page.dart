import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/core/utils/navigation_utils.dart';
import 'package:sahtek/features/profile/controller/profile_controller.dart';
import '../models/conversation_model.dart';
import 'messagerie_details_page.dart';

class MessageriePage extends StatefulWidget {
  const MessageriePage({Key? key}) : super(key: key);

  @override
  State<MessageriePage> createState() => _MessageriePageState();
}

class _MessageriePageState extends State<MessageriePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Conversation> _filteredConversations = Conversation.mockConversations;

  void _filterConversations(String query) {
    setState(() {
      _filteredConversations = Conversation.mockConversations
          .where(
            (conv) => conv.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () {
            final role = context.read<ProfileController>().role;
            NavigationUtils.navigateToDashboard(context, role);
          },
        ),
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
      body: Column(
        children: [
          _buildSearchBar(),
          _buildRecentHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredConversations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildConversationTile(_filteredConversations[index]),
            ),
          ),
        ],
      ),
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

  Widget _buildConversationTile(Conversation conv) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MessagerieDetailsPage(),
            settings: RouteSettings(arguments: conv.name),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
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
                  backgroundImage: NetworkImage(conv.avatarUrl),
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
                        conv.name,
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
    if (diff.inMinutes < 60) return "${diff.inMinutes} min";
    if (diff.inHours < 24)
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    if (diff.inDays == 1) return "hier".tr();
    return "${date.day}/${date.month}";
  }
}
