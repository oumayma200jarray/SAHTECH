import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;
  final bool showControls;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.autoPlay = true,
    this.looping = true,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _hasError = false;
  bool _isInitialized = false;
  bool _isYouTube = false;

  final String _fallbackUrl = 'lib/assets/videos/1qxfuAOmBoQ.mp4';

  @override
  void initState() {
    super.initState();
    _initializeController(widget.videoUrl);
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializeController(widget.videoUrl);
    }
  }

  bool _checkIsYouTube(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be') || url.contains('/shorts/');
  }

  Future<void> _initializeController(String url) async {
    _isInitialized = false;
    _hasError = false;
    _isYouTube = _checkIsYouTube(url);
    setState(() {});

    if (_isYouTube) {
      // Pour YouTube, on n'initialise pas le contrôleur natif
      // On va charger la vidéo de secours en fond pour avoir un visuel
      // mais on affichera le bouton YouTube
      await _initializeNative(_fallbackUrl);
      return;
    }

    await _initializeNative(url);
  }

  Future<void> _initializeNative(String url) async {
    await _controller?.dispose();
    _controller = null;

    try {
      if (kIsWeb && !url.startsWith('http')) {
        _controller = VideoPlayerController.asset(url);
      } else if (url.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      } else {
        _controller = VideoPlayerController.asset(url);
      }

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.autoPlay && !_isYouTube) {
          _controller?.play();
        }
        _controller?.setLooping(widget.looping);
      }
    } catch (e) {
      print('Erreur VideoPlayerWidget ($url): $e');
      if (url != _fallbackUrl) {
        _initializeNative(_fallbackUrl);
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      }
    }
  }

  Future<void> _launchYouTube() async {
    final Uri url = Uri.parse(widget.videoUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Impossible de lancer YouTube pour: ${widget.videoUrl}');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.white, size: 48),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller!),
          if (_isYouTube) _buildYouTubeOverlay(),
          if (!_isYouTube && widget.showControls) _buildControls(),
        ],
      ),
    );
  }

  Widget _buildYouTubeOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_filled, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _launchYouTube,
              icon: const Icon(Icons.open_in_new),
              label: const Text("Regarder sur YouTube"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller!.value.isPlaying
              ? _controller!.pause()
              : _controller!.play();
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !_controller!.value.isPlaying
                ? const Icon(Icons.play_arrow, color: Colors.white, size: 64)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
