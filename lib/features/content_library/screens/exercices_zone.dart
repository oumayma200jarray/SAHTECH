import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/features/content_library/services/exercise_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------------------------
// Shared label maps (used by main page, cards, and video sheet)
// ---------------------------------------------------------------------------

const Map<String, String> _keyToLabel = {
  'NECK': 'neck',
  'LEFT_SHOULDER': 'left_shoulder',
  'RIGHT_SHOULDER': 'right_shoulder',
  'BACK': 'back',
  'LEFT_ELBOW': 'left_elbow',
  'RIGHT_ELBOW': 'right_elbow',
  'RIGHT_KNEE': 'right_knee',
  'LEFT_KNEE': 'left_knee',
  'RIGHT_FOOT': 'right_foot',
  'LEFT_FOOT': 'left_foot',
  'RIGHT_CHEST': 'right_chest',
  'LEFT_CHEST': 'left_chest',
  'RIGHT_WRIST': 'right_wrist',
  'LEFT_WRIST': 'left_wrist',
  'LEFT_HIP': 'left_hip',
  'RIGHT_HIP': 'right_hip',
};

const Map<String, String> _sideToLabel = {'BACK': 'back', 'FRONT': 'front'};

// ---------------------------------------------------------------------------
// Main page
// ---------------------------------------------------------------------------

class ExercicesZonePage extends StatelessWidget {
  const ExercicesZonePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedZoneKey = Provider.of<GlobalDataProvider>(
      context,
    ).membreSelectionne;

    final Future<List<ContentModel>> exercicesFuture =
        ExerciseService.fetchExercicesByZone(
          selectedZoneKey.isEmpty ? null : selectedZoneKey,
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: FutureBuilder<List<ContentModel>>(
        future: exercicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D54F2)),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final exercices = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              // ── Sliver App Bar ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: const Color(0xFF0D54F2),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (selectedZoneKey.isNotEmpty)
                    GestureDetector(
                      onTap: () => Provider.of<GlobalDataProvider>(
                        context,
                        listen: false,
                      ).setMembre(''),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'show_all'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0D54F2), Color(0xFF4F8EF7)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -20,
                          bottom: 20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                selectedZoneKey.isEmpty
                                    ? 'all_exercises'.tr()
                                    : (_keyToLabel[selectedZoneKey]?.tr() ??
                                          selectedZoneKey),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.fitness_center,
                                    color: Colors.white70,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    exercices.isEmpty
                                        ? 'zone_rehab_desc'.tr()
                                        : 'exercises_count_time'.tr(
                                            namedArgs: {
                                              'count': exercices.length
                                                  .toString(),
                                            },
                                          ),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
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
                ),
              ),

              // ── Exercise list ────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (exercices.isEmpty) ...[
                      const SizedBox(height: 60),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey.withValues(alpha: 0.4),
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'no_content_available'.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      ...exercices.map(
                        (ex) => _ExerciseCard(
                          exercise: ex,
                          keyToLabel: _keyToLabel,
                          sideToLabel: _sideToLabel,
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise card  (matches web PublicExerciseCard layout)
// ---------------------------------------------------------------------------

class _ExerciseCard extends StatelessWidget {
  final ContentModel exercise;
  final Map<String, String> keyToLabel;
  final Map<String, String> sideToLabel;

  const _ExerciseCard({
    required this.exercise,
    required this.keyToLabel,
    required this.sideToLabel,
  });

  void _openVideo(BuildContext context) {
    final url = exercise.videoUrl ?? '';
    if (url.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VideoBottomSheet(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = UrlHelper.fixImageUrl(exercise.imageUrl ?? '');
    final hasVideo = (exercise.videoUrl ?? '').isNotEmpty;
    final specialistName = exercise.specialistName ?? '';
    final hasSpecialist = specialistName.isNotEmpty;

    return GestureDetector(
      onTap: () => _openVideo(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail / video preview ──────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 176,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _noImagePlaceholder(),
                        )
                      : _noImagePlaceholder(),
                ),
                // Bottom gradient
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.40),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Side badges (top-right, matches web)
                if (exercise.sides.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Wrap(
                      spacing: 4,
                      children: exercise.sides.map((s) {
                        final label = sideToLabel[s] ?? s.toLowerCase();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            label.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                // Play button (center)
                if (hasVideo)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFF0D54F2),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                // Duration badge (bottom-right)
                if ((exercise.duration ?? '').isNotEmpty)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.white,
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            exercise.duration!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ── Body ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Category chips
                  if (exercise.categories.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: exercise.categories.map((cat) {
                        final label = keyToLabel[cat] ?? cat.toLowerCase();
                        return _Chip(
                          label: label.tr(),
                          color: const Color(0xFF0D54F2),
                          background: const Color(0xFFEEF3FF),
                        );
                      }).toList(),
                    ),
                  ],

                  // Description (3 lines max, matches web line-clamp-3)
                  const SizedBox(height: 8),
                  if ((exercise.description ?? '').trim().isNotEmpty)
                    Text(
                      exercise.description!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'no_description'.tr(),
                      style: const TextStyle(
                        color: Color(0xFFBBBBBB),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  // ── Footer: specialist ─────────────────────────────────
                  if (hasSpecialist) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _SpecialistAvatar(exercise: exercise),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'created_by'.tr(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              specialistName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (!hasVideo) ...[
                          const Spacer(),
                          Text(
                            'video_not_available'.tr(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noImagePlaceholder() {
    return Container(
      color: const Color(0xFFEEF3FF),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: Color(0xFF0D54F2)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Specialist avatar
// ---------------------------------------------------------------------------

class _SpecialistAvatar extends StatelessWidget {
  final ContentModel exercise;
  const _SpecialistAvatar({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final hasImage = (exercise.specialistImageUrl ?? '').isNotEmpty;
    final name = exercise.specialistName ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFEEF3FF),
      backgroundImage: hasImage
          ? NetworkImage(UrlHelper.fixImageUrl(exercise.specialistImageUrl!))
          : null,
      child: !hasImage
          ? Text(
              initial,
              style: const TextStyle(
                color: Color(0xFF0D54F2),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Chip
// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  const _Chip({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Video bottom sheet with Chewie player
// ---------------------------------------------------------------------------

class _VideoBottomSheet extends StatefulWidget {
  final ContentModel exercise;
  const _VideoBottomSheet({required this.exercise});

  @override
  State<_VideoBottomSheet> createState() => _VideoBottomSheetState();
}

class _VideoBottomSheetState extends State<_VideoBottomSheet> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isYouTube = false;
  String _videoUrl = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  bool _checkIsYouTube(String url) =>
      url.contains('youtube.com') ||
      url.contains('youtu.be') ||
      url.contains('/shorts/');

  void _onVideoPlayerUpdate() {
    final val = _videoController?.value;
    if (val == null) return;
    if (val.hasError && !_hasError && mounted) {
      debugPrint('[VideoPlayer] Runtime error: ${val.errorDescription}');
      setState(() => _hasError = true);
    }
  }

  Future<void> _init() async {
    final rawUrl = widget.exercise.videoUrl ?? '';
    _videoUrl = UrlHelper.fixImageUrl(rawUrl);
    _isYouTube = _checkIsYouTube(_videoUrl);

    if (_isYouTube) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (_videoUrl.isEmpty) {
      if (mounted)
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      return;
    }

    try {
      debugPrint('[VideoPlayer] Loading: $_videoUrl');
      _videoController = _videoUrl.startsWith('http')
          ? VideoPlayerController.networkUrl(Uri.parse(_videoUrl))
          : VideoPlayerController.asset(_videoUrl);

      // Catch errors that fire after initialize() completes
      _videoController!.addListener(_onVideoPlayerUpdate);

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF0D54F2),
          handleColor: const Color(0xFF0D54F2),
          bufferedColor: const Color(0xFF0D54F2).withValues(alpha: 0.3),
          backgroundColor: Colors.white24,
        ),
        placeholder: Container(color: Colors.black),
        // Override Chewie's error UI with our own
        errorBuilder: (ctx, msg) =>
            _ErrorVideoState(url: _videoUrl, onOpen: _openExternally),
      );

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('[VideoPlayer] Init error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoPlayerUpdate);
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _openExternally() async {
    final raw = widget.exercise.videoUrl ?? '';
    if (raw.isEmpty) return;
    final uri = Uri.parse(raw);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open video')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final specialistName = widget.exercise.specialistName ?? '';

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Video area
          Container(height: 230, color: Colors.black, child: _buildVideoArea()),

          // Info
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title ─────────────────────────────────────────────
                  Text(
                    widget.exercise.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Category + Side chips ─────────────────────────────
                  if (widget.exercise.categories.isNotEmpty ||
                      widget.exercise.sides.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...widget.exercise.categories.map(
                          (cat) => _Chip(
                            label: (_keyToLabel[cat] ?? cat.toLowerCase()).tr(),
                            color: const Color(0xFF0D54F2),
                            background: const Color(0xFFEEF3FF),
                          ),
                        ),
                        ...widget.exercise.sides.map(
                          (s) => _Chip(
                            label: (_sideToLabel[s] ?? s.toLowerCase()).tr(),
                            color: Colors.black54,
                            background: const Color(0xFFF5F5F5),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // ── Specialist + Duration row ─────────────────────────
                  Row(
                    children: [
                      if (specialistName.isNotEmpty) ...[
                        _SpecialistAvatar(exercise: widget.exercise),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'created_by'.tr(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                specialistName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if ((widget.exercise.duration ?? '').isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF3FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 13,
                                color: Color(0xFF0D54F2),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.exercise.duration!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0D54F2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // ── Description ───────────────────────────────────────
                  if ((widget.exercise.description ?? '').trim().isNotEmpty)
                    Text(
                      widget.exercise.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    )
                  else
                    Text(
                      'no_description'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFBBBBBB),
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Close button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D54F2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text('close'.tr()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_isYouTube) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.smart_display_rounded,
              color: Colors.red,
              size: 56,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _openExternally,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Watch on YouTube'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError || _chewieController == null) {
      return _ErrorVideoState(url: _videoUrl, onOpen: _openExternally);
    }

    return Chewie(controller: _chewieController!);
  }
}

// ---------------------------------------------------------------------------
// Error state shown inside the video area
// ---------------------------------------------------------------------------

class _ErrorVideoState extends StatelessWidget {
  final String url;
  final VoidCallback onOpen;
  const _ErrorVideoState({required this.url, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off_rounded,
                color: Colors.white60,
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'video_not_available'.tr(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              url,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (url.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Open externally'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
