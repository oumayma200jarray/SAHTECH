import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/features/dashboard/services/dashboard_services.dart';
import 'package:sahtek/models/post_model.dart';
import 'package:video_player/video_player.dart';

class NouvellePublicationPage extends StatefulWidget {
  const NouvellePublicationPage({super.key});

  @override
  State<NouvellePublicationPage> createState() =>
      _NouvellePublicationPageState();
}

class _NouvellePublicationPageState extends State<NouvellePublicationPage> {
  List<PostModel> _posts = [];
  bool _loading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() => _loading = true);
    final posts = await SpecialistDashboardService.getMyPosts();
    if (mounted)
      setState(() {
        _posts = posts;
        _loading = false;
      });
  }

  void _openCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePostSheet(
        onCreated: () {
          _hasChanges = true;
          _fetchPosts();
        },
      ),
    );
  }

  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'exercises_delete_title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('delete_post_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'exercises_cancel'.tr(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'exercises_delete_btn'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await SpecialistDashboardService.deletePost(postId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'post_deleted_success'.tr() : 'post_delete_error'.tr(),
            ),
            backgroundColor: success
                ? const Color(0xFF0D54F2)
                : Colors.redAccent,
          ),
        );
        if (success) {
          _hasChanges = true;
          _fetchPosts();
        }
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D54F2)),
            )
          : _posts.isEmpty
          ? _buildEmptyState()
          : _buildPostsList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: CircleAvatar(
          backgroundColor: const Color(0xFF0D54F2).withOpacity(0.08),
          radius: 20,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF0D54F2),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'my_publications'.tr(),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (!_loading)
            Text(
              'publications_count'.tr(
                namedArgs: {'count': _posts.length.toString()},
              ),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton.icon(
            onPressed: _openCreateSheet,
            icon: const Icon(
              Icons.add_circle_outline,
              size: 16,
              color: Color(0xFF0D54F2),
            ),
            label: Text(
              'new_publication'.tr(),
              style: const TextStyle(
                color: Color(0xFF0D54F2),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF0D54F2).withOpacity(0.07),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey[100]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D54F2), Color(0xFF4B8FF5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D54F2).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.article_outlined,
                size: 52,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'no_publications'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'no_publications_desc'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _openCreateSheet,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'create_first_publication'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D54F2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return RefreshIndicator(
      onRefresh: _fetchPosts,
      color: const Color(0xFF0D54F2),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _posts.length,
        itemBuilder: (_, i) => _PostCard(
          post: _posts[i],
          formatDate: _formatDate,
          onDelete: () => _deletePost(_posts[i].postId),
        ),
      ),
    );
  }
}

// ─── Post Card ────────────────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final PostModel post;
  final String Function(DateTime?) formatDate;
  final VoidCallback onDelete;

  const _PostCard({
    required this.post,
    required this.formatDate,
    required this.onDelete,
  });

  static const _typeColors = {
    'ARTICLE': Color(0xFF0D54F2),
    'IMAGE': Color(0xFF00B4A2),
    'VIDEO': Color(0xFFFF6B35),
  };
  static const _typeEmojis = {'ARTICLE': '📄', 'IMAGE': '🖼️', 'VIDEO': '🎥'};
  static const _typeLabelKeys = {
    'ARTICLE': 'post_type_article',
    'IMAGE': 'post_type_photo',
    'VIDEO': 'post_type_video',
  };

  @override
  Widget build(BuildContext context) {
    final type = post.type.toUpperCase();
    final color = _typeColors[type] ?? const Color(0xFF0D54F2);
    final emoji = _typeEmojis[type] ?? '📄';
    final labelKey = _typeLabelKeys[type] ?? 'post_type_article';

    // Compute once — same pattern as exercices_zone.dart
    final fixedUrl = UrlHelper.fixImageUrl(post.url ?? '');
    final hasMedia = fixedUrl.isNotEmpty && (type == 'IMAGE' || type == 'VIDEO');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Media area ──
            if (hasMedia)
              Stack(
                children: [
                  if (type == 'IMAGE')
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.network(
                        fixedUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : _buildLoadingPlaceholder(color),
                        errorBuilder: (_, __, ___) =>
                            _buildMediaPlaceholder(type, color),
                      ),
                    )
                  else
                    _buildVideoPlaceholder(context, fixedUrl, color),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildOverlayBadge(emoji, labelKey.tr()),
                  ),
                ],
              ),

            // ── Content ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasMedia) ...[
                    _buildInlineBadge(emoji, labelKey.tr(), color),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      post.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 12),
                  // ── Footer ──
                  Row(
                    children: [
                      if (post.createdAt != null) ...[
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatDate(post.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      const Spacer(),
                      _buildStatusBadge(post.isPublished),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red[400],
                          ),
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

  Widget _buildOverlayBadge(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineBadge(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isPublished) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPublished
            ? Colors.green.withOpacity(0.1)
            : Colors.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublished ? Icons.check_circle_outline : Icons.access_time,
            size: 12,
            color: isPublished ? Colors.green : Colors.amber[800],
          ),
          const SizedBox(width: 4),
          Text(
            isPublished ? 'published_status'.tr() : 'pending_validation'.tr(),
            style: TextStyle(
              fontSize: 11,
              color: isPublished ? Colors.green : Colors.amber[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder(
      BuildContext context, String videoUrl, Color color) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) =>
            _PostVideoSheet(videoUrl: videoUrl, title: post.title),
      ),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.play_circle_fill, size: 56, color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildMediaPlaceholder(String type, Color color) {
    return Container(
      height: 180,
      width: double.infinity,
      color: color.withOpacity(0.08),
      child: Center(
        child: Icon(
          type == 'IMAGE' ? Icons.image_outlined : Icons.videocam_outlined,
          size: 56,
          color: color.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(Color color) {
    return Container(
      height: 180,
      width: double.infinity,
      color: color.withValues(alpha: 0.06),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0D54F2),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// ─── Post Video Player Sheet ──────────────────────────────────────────────────

class _PostVideoSheet extends StatefulWidget {
  final String videoUrl;
  final String title;

  const _PostVideoSheet({required this.videoUrl, required this.title});

  @override
  State<_PostVideoSheet> createState() => _PostVideoSheetState();
}

class _PostVideoSheetState extends State<_PostVideoSheet> {
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.videoUrl.isEmpty) {
      setState(() { _hasError = true; _loading = false; });
      return;
    }
    try {
      _videoCtrl = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      _videoCtrl!.addListener(_onUpdate);
      await _videoCtrl!.initialize();
      _chewieCtrl = ChewieController(
        videoPlayerController: _videoCtrl!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF0D54F2),
          handleColor: const Color(0xFF0D54F2),
          bufferedColor: const Color(0xFF0D54F2).withOpacity(0.3),
          backgroundColor: Colors.white24,
        ),
        placeholder: Container(color: Colors.black),
      );
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint('[PostVideoSheet] init error: $e');
      if (mounted) setState(() { _hasError = true; _loading = false; });
    }
  }

  void _onUpdate() {
    final val = _videoCtrl?.value;
    if (val != null && val.hasError && !_hasError && mounted) {
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _videoCtrl?.removeListener(_onUpdate);
    _chewieCtrl?.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.grey[100], shape: BoxShape.circle),
                    child:
                        const Icon(Icons.close, size: 20, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[100]),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF0D54F2)))
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('error_loading'.tr(),
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : Chewie(controller: _chewieCtrl!),
          ),
        ],
      ),
    );
  }
}

// ─── Create Post Bottom Sheet ─────────────────────────────────────────────────

class _CreatePostSheet extends StatefulWidget {
  final VoidCallback onCreated;

  const _CreatePostSheet({required this.onCreated});

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'ARTICLE';
  File? _file;
  String? _fileName;
  bool _uploading = false;

  static const _typeColors = {
    'ARTICLE': Color(0xFF0D54F2),
    'IMAGE': Color(0xFF00B4A2),
    'VIDEO': Color(0xFFFF6B35),
  };
  static const _typeEmojis = {'ARTICLE': '📄', 'IMAGE': '🖼️', 'VIDEO': '🎥'};
  static const _typeLabelKeys = {
    'ARTICLE': 'post_type_article',
    'IMAGE': 'post_type_photo',
    'VIDEO': 'post_type_video',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final extensions = _type == 'VIDEO'
        ? ['mp4', 'mov', 'avi']
        : ['jpg', 'jpeg', 'png', 'webp'];
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      if (file.lengthSync() > 100 * 1024 * 1024) {
        _showSnack('file_too_large'.tr(), isError: true);
        return;
      }
      setState(() {
        _file = file;
        _fileName = result.files.single.name;
      });
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF0D54F2),
      ),
    );
  }

  Future<void> _publish() async {
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      _showSnack('please_fill_all_fields'.tr(), isError: true);
      return;
    }
    if (_type != 'ARTICLE' && _file == null) {
      _showSnack('please_select_file'.tr(), isError: true);
      return;
    }

    setState(() => _uploading = true);
    final success = await SpecialistDashboardService.publishDocument(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      type: _type,
      file: _file,
    );

    if (mounted) {
      setState(() => _uploading = false);
      if (success) {
        Navigator.pop(context);
        _showSnack('document_published_success'.tr());
        widget.onCreated();
      } else {
        _showSnack('error_publishing'.tr(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Handle ──
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'create_publication'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[100]),
            // ── Form ──
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomPadding),
                children: [
                  // Type selector
                  _sectionLabel('content_type'.tr()),
                  const SizedBox(height: 10),
                  Row(
                    children: _typeColors.keys.toList().asMap().entries.map((
                      e,
                    ) {
                      final key = e.value;
                      final isLast = e.key == _typeColors.length - 1;
                      final isSelected = _type == key;
                      final color = _typeColors[key]!;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _type = key;
                            _file = null;
                            _fileName = null;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(right: isLast ? 0 : 8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.1)
                                  : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? color : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _typeEmojis[key]!,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _typeLabelKeys[key]!.tr(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? color
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  _sectionLabel('title'.tr()),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _titleCtrl,
                    hintText: 'please_enter_title'.tr(),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  _sectionLabel('description'.tr()),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descCtrl,
                    hintText: 'description_hint'.tr(),
                    maxLines: 4,
                  ),
                  // File picker (IMAGE / VIDEO only)
                  if (_type != 'ARTICLE') ...[
                    const SizedBox(height: 16),
                    _sectionLabel(
                      _type == 'IMAGE'
                          ? 'select_image'.tr()
                          : 'select_video'.tr(),
                    ),
                    const SizedBox(height: 8),
                    _buildFilePicker(),
                  ],
                  const SizedBox(height: 28),
                  // Publish button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _uploading ? null : _publish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D54F2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        disabledBackgroundColor: const Color(
                          0xFF0D54F2,
                        ).withOpacity(0.5),
                      ),
                      child: _uploading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.send_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'publish_button'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D54F2), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    final hasFile = _file != null;
    final accentColor = const Color(0xFF0D54F2);
    return GestureDetector(
      onTap: _pickFile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: hasFile
              ? accentColor.withOpacity(0.05)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasFile ? accentColor : Colors.grey[300]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFile
                  ? Icons.check_circle_outline
                  : (_type == 'IMAGE'
                        ? Icons.image_outlined
                        : Icons.videocam_outlined),
              size: 40,
              color: hasFile ? accentColor : Colors.grey[400],
            ),
            const SizedBox(height: 10),
            Text(
              hasFile
                  ? (_fileName ?? 'file_selected'.tr())
                  : 'tap_to_select_file'.tr(),
              style: TextStyle(
                color: hasFile ? accentColor : Colors.grey[500],
                fontWeight: hasFile ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _type == 'IMAGE'
                  ? 'image_format_hint'.tr()
                  : 'video_format_hint'.tr(),
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
