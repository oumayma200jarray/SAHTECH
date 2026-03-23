import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sahtek/core/utils/url_helper.dart';

class TimeLapsePlayer extends StatefulWidget {
  final List<String> images;
  final Duration interval;
  final double height;

  const TimeLapsePlayer({
    Key? key,
    required this.images,
    this.interval = const Duration(milliseconds: 350),
    this.height = 200,
  }) : super(key: key);

  @override
  State<TimeLapsePlayer> createState() => _TimeLapsePlayerState();
}

class _TimeLapsePlayerState extends State<TimeLapsePlayer> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.images.isNotEmpty) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(widget.interval, (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: widget.height,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.videocam_off)),
      );
    }

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb
            ? Image.network(
                UrlHelper.fixImageUrl(widget.images[_currentIndex]),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.error_outline, color: Colors.white),
                ),
              )
            : Image.file(
                File(widget.images[_currentIndex]),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.error_outline, color: Colors.white),
                ),
              ),
      ),
    );
  }
}
