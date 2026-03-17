import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:sahtek/models/ia_tracking_model.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/features/ia_tracking/services/pose_detection_service.dart';
import 'package:sahtek/features/ia_tracking/widgets/pose_painter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sahtek/features/ia_tracking/controllers/tracking_controller.dart';
import 'package:sahtek/features/ia_tracking/services/claude_ai_service.dart';
import 'package:sahtek/core/widgets/video_player_widget.dart';

class SuiviIADirectPage extends StatefulWidget {
  const SuiviIADirectPage({Key? key}) : super(key: key);

  @override
  State<SuiviIADirectPage> createState() => _SuiviIADirectPageState();
}

class _SuiviIADirectPageState extends State<SuiviIADirectPage>
    with WidgetsBindingObserver {
  final TrackingController _trackingController = TrackingController();
  final FlutterTts _flutterTts = FlutterTts();
  final ClaudeAIService _claudeAIService = ClaudeAIService();
  final PoseDetectionService _poseDetectionService = PoseDetectionService();

  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  List<Pose> _poses = [];
  Timer? _analysisTimer;

  // Stats session
  double _sessionMaxAngle = 0.0;
  final List<String> _sessionFrames = [];

  bool _isAILoading = false;
  DateTime _lastAICallTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const int _kAIFeedbackCooldownSec = 12;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _trackingController.addListener(_onTrackingUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTts().then((_) {
        _initializeCamera().then((_) {
          _flutterTts.speak("Prêt à commencer");
        });
      });
      final provider = Provider.of<GlobalDataProvider>(context, listen: false);
      if (provider.selectedExercise != null) {
        _trackingController.initialize(
          IATrackingData.fromContent(provider.selectedExercise!),
        );
      }
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setSpeechRate(0.55);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      CameraDescription? frontCamera;
      try {
        frontCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
      } catch (e) {
        frontCamera = cameras.first;
      }

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: (!kIsWeb && Platform.isIOS)
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraReady = true);
        if (kIsWeb ||
            (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
          debugPrint('ML Kit Pose Detection only works on Android/iOS');
        }
        _startAnalysisTimer();
      }
    } catch (e) {
      debugPrint('Error camera init: $e');
    }
  }

  void _startAnalysisTimer() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (_) => _captureAndAnalyze(),
    );
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isCameraReady || _isProcessing || _cameraController == null) return;
    _isProcessing = true;

    try {
      final image = await _cameraController!.takePicture();
      _sessionFrames.add(image.path);

      final inputImage = InputImage.fromFilePath(image.path);
      final poses = await _poseDetectionService.processImage(inputImage);

      if (mounted && poses.isNotEmpty) {
        setState(() => _poses = poses);
        _trackingController.processPose(poses.first);
      }
    } catch (e) {
      debugPrint('Error capture: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _onTrackingUpdate() {
    if (!mounted) return;
    final data = _trackingController.trackingData;
    if (data == null) return;

    if (data.currentValue > _sessionMaxAngle) {
      setState(() => _sessionMaxAngle = data.currentValue);
    }

    _checkAndTriggerAI(data);
  }

  int _stagnationCount = 0;
  double _lastAngleForStagnation = 0.0;

  void _checkAndTriggerAI(IATrackingData data) {
    if (_isAILoading || _trackingController.state == TrackingState.completed)
      return;

    // Détection de stagnation
    if ((data.currentValue - _lastAngleForStagnation).abs() < 2.0 &&
        data.currentValue > 10.0) {
      _stagnationCount++;
    } else {
      _stagnationCount = 0;
    }
    _lastAngleForStagnation = data.currentValue;

    final now = DateTime.now();
    bool cooldownOk =
        now.difference(_lastAICallTime).inSeconds >= _kAIFeedbackCooldownSec;

    if (!cooldownOk) return;

    // Déclencheurs de feedback
    bool shouldTrigger = false;

    // 1. Erreur de posture détectée par le contrôleur
    if (!_trackingController.isComparisonCorrect) {
      shouldTrigger = true;
    }
    // 2. Stagnation prolongée (environ 5 secondes de capture)
    else if (_stagnationCount >= 5) {
      shouldTrigger = true;
      _stagnationCount = 0;
    }
    // 3. Proche de l'objectif (encouragement final)
    else if (data.currentValue > data.objective - 30.0 &&
        data.currentValue < data.objective - 10.0) {
      shouldTrigger = true;
      _lastAICallTime = now.add(
        const Duration(seconds: 10),
      ); // Éviter de répéter trop vite l'encouragement final
    }

    if (shouldTrigger) {
      _fetchAIFeedback(data);
    }
  }

  Future<void> _fetchAIFeedback(IATrackingData data) async {
    setState(() => _isAILoading = true);
    _lastAICallTime = DateTime.now();

    final feedback = await _claudeAIService.getFeedback(data);

    if (mounted) {
      setState(() {
        _isAILoading = false;
        if (_trackingController.state == TrackingState.completed) return;

        if (feedback != null) {
          _flutterTts.speak(feedback);
        } else {
          _flutterTts.speak(_trackingController.feedbackMessage);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _analysisTimer?.cancel();
    _cameraController?.dispose();
    _poseDetectionService.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _trackingController.trackingData;
    final int currentValue = data?.currentValue.toInt() ?? 0;
    final int objective = data?.objective.toInt() ?? 180;
    final double progress = (currentValue / objective).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Fond Caméra
          Positioned.fill(
            child: _isCameraReady && _cameraController != null
                ? CameraPreview(_cameraController!)
                : Container(color: Colors.black),
          ),

          // 2. Overlay Pose (Optionnel)
          if (_isCameraReady && _poses.isNotEmpty && _cameraController != null)
            Positioned.fill(
              child: CustomPaint(
                painter: PosePainter(
                  _poses,
                  _cameraController!.value.previewSize != null
                      ? Size(
                          _cameraController!.value.previewSize!.height,
                          _cameraController!.value.previewSize!.width,
                        )
                      : const Size(480, 640),
                  InputImageRotation.rotation90deg,
                ),
              ),
            ),

          // 3. Barre de statut supérieure
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "SUIVI EN DIRECT",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Carte de Score Centrale
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        data?.title.toUpperCase() ?? "FLEXION D'ÉPAULE",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "$currentValue°",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF0D54F2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "0°",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            "OBJECTIF: $objective°",
                            style: const TextStyle(
                              color: Color(0xFF0D54F2),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Pousse le reste vers le bas
              ],
            ),
          ),

          // 5. Guidage et Actions (Bas)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Carte de Guidage
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D54F2).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.accessibility_new,
                            color: Color(0xFF0D54F2),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "GUIDAGE IA",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _trackingController.feedbackMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pause, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Pause",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () => _finishSession(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D54F2),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stop, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Arrêter le suivi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Télémétrie bas de page
                  Text(
                    "CAPTEUR IA : ACTIF  •  PRÉCISION 98.4%",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          // 6. PIP Demo Video (Flottant à droite du score)
          Positioned(
            right: 15,
            top: 30,
            child: Consumer<GlobalDataProvider>(
              builder: (context, provider, _) {
                final videoUrl = provider.selectedExercise?.videoUrl;
                if (videoUrl == null || videoUrl.isEmpty)
                  return const SizedBox.shrink();
                return Container(
                  width: 100,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: VideoPlayerWidget(
                      videoUrl: videoUrl,
                      autoPlay: true,
                      looping: true,
                      showControls: false,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _finishSession() {
    final data = _trackingController.trackingData;
    if (data != null) {
      final finalData = IATrackingData(
        title: data.title,
        currentValue: _sessionMaxAngle,
        unit: data.unit,
        objective: data.objective,
        precision: data.precision,
        guidanceText: data.guidanceText,
        angleHistory: data.angleHistory,
        date: DateTime.now(),
        sessionFrames: _sessionFrames,
      );

      final provider = Provider.of<GlobalDataProvider>(context, listen: false);
      provider.saveIATrackingResult(finalData);

      Navigator.pushReplacementNamed(context, '/resultat_test_ia');
    }
  }
}
