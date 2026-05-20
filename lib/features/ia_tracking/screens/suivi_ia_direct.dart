import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:sahtek/models/pose_model.dart';
import 'package:sahtek/models/ia_tracking_model.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/features/ia_tracking/services/pose_detection_service.dart';
import 'package:sahtek/features/ia_tracking/widgets/pose_painter.dart';
import 'package:sahtek/features/ia_tracking/services/voice_coaching_service.dart';
import 'package:sahtek/features/ia_tracking/presentation/state/tracking_notifier.dart';
import 'package:sahtek/features/ia_tracking/domain/entities/movement_result.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as mlkit;
import 'package:flutter/services.dart';

class SuiviIADirectPage extends StatefulWidget {
  const SuiviIADirectPage({Key? key}) : super(key: key);

  @override
  State<SuiviIADirectPage> createState() => _SuiviIADirectPageState();
}

class _SuiviIADirectPageState extends State<SuiviIADirectPage>
    with WidgetsBindingObserver {
  final VoiceCoachingService _voiceService = VoiceCoachingService();
  final PoseDetectionService _poseDetectionService = PoseDetectionService();

  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _isFrontCamera = true;
  List<Pose> _poses = [];
  Timer? _analysisTimer;

  DateTime _lastAICallTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const int _kAIFeedbackCooldownSec = 10;
  bool _isLeftSide = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();

      final provider = Provider.of<GlobalDataProvider>(context, listen: false);
      final trackingNotifier = Provider.of<TrackingNotifier>(context, listen: false);

      if (provider.selectedExercise != null) {
        final exercise = provider.selectedExercise!;
        CameraView req = CameraView.front;
        if (exercise.requiredView == 'profil') req = CameraView.profile;
        if (exercise.requiredView == 'back') req = CameraView.back;

        trackingNotifier.initialize(
          exercise.id,
          exercise.id.contains('rotation') ? 90.0 : 180.0,
          requiredView: req,
        );
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final selectedCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _isFrontCamera = selectedCamera.lensDirection == CameraLensDirection.front;
      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraReady = true);
        _startAnalysisTimer();
      }
    } catch (e) {
      debugPrint('Camera Error: $e');
    }
  }

  void _startAnalysisTimer() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _captureAndAnalyze(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _analysisTimer?.cancel();
    _cameraController?.dispose();
    _voiceService.stop();
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isCameraReady || _isProcessing || _cameraController == null) return;
    _isProcessing = true;

    try {
      final XFile file = await _cameraController!.takePicture();
      final mlkit.InputImage inputImage = mlkit.InputImage.fromFilePath(file.path);
      final List<Pose> poses = await _poseDetectionService.processImage(inputImage);

      if (mounted && poses.isNotEmpty) {
        final trackingNotifier = Provider.of<TrackingNotifier>(context, listen: false);
        trackingNotifier.processPose(poses.first, _isFrontCamera);
        setState(() => _poses = poses);
        _checkAndTriggerFeedback(trackingNotifier);
      }
      await File(file.path).delete();
    } catch (e) {
      debugPrint('Capture Error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _checkAndTriggerFeedback(TrackingNotifier notifier) {
    final provider = Provider.of<GlobalDataProvider>(context, listen: false);
    final exerciseId = provider.selectedExercise?.id ?? "";

    if (notifier.state == TrackingState.completed) {
      if (notifier.hasSpokenIntro) {
        _voiceService.speakCompletion(notifier.pathologicalSide);
        notifier.hasSpokenIntro = false;
      }
      return;
    }

    if (!notifier.hasSpokenIntro) {
      _voiceService.speak(_voiceService.getIntroMessage(exerciseId));
      notifier.hasSpokenIntro = true;
    }

    final now = DateTime.now();
    if (now.difference(_lastAICallTime).inSeconds < _kAIFeedbackCooldownSec) return;

    if (!notifier.isViewCorrect && notifier.detectedView != CameraView.front) { 
      final String requiredStr = notifier.requiredView == CameraView.profile ? "profil" : "face";
      _voiceService.speak("Attention, veuillez vous placer de $requiredStr.");
      _lastAICallTime = now;
      return;
    }

    if (notifier.hasOneArmEvaluated && !notifier.hasSpokenSwitchArm) {
      _voiceService.speak("Très bien, vous avez terminé avec ce bras. Veuillez maintenant appliquer le même mouvement sur l'autre bras.", force: true);
      notifier.hasSpokenSwitchArm = true;
      _lastAICallTime = now;
      return;
    }

    // Ne pas déclencher de remarques vocales si le patient n'a pas encore commencé ou vient juste de démarrer
    if (notifier.state == TrackingState.waiting || notifier.totalFrames < 30) return;

    final result = notifier.lastResult;
    if (result != null && result.remarks.isNotEmpty) {
      final firstWarning = result.remarks.firstWhere(
        (r) => r.severity == RemarkSeverity.warning,
        orElse: () => result.remarks.first,
      );
      _voiceService.speakFeedback(exerciseId: exerciseId, angle: result.angle, message: firstWarning.message);
      _lastAICallTime = now;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingNotifier>(
      builder: (context, notifier, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned.fill(child: _buildCameraAndOverlay(notifier)),
              _buildTopBar(notifier),
              _buildGuidanceSection(notifier),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(TrackingNotifier notifier) {
    final result = notifier.lastResult;
    final int currentValue = result?.angle.toInt() ?? 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLeftSide = true),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _isLeftSide ? const Color(0xFF0D54F2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text("GAUCHE", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLeftSide = false),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !_isLeftSide ? const Color(0xFF0D54F2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text("DROITE", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF0D54F2), borderRadius: BorderRadius.circular(16)),
                  child: Text("$currentValue°", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (!notifier.isViewCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                  child: Text("Veuillez vous mettre de ${notifier.requiredView.name.toUpperCase()}", style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceSection(TrackingNotifier notifier) {
    final remark = notifier.lastResult?.remarks.firstOrNull;
    return Positioned(
      bottom: 40,
      left: 24,
      right: 24,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF0F172A).withAlpha(230), borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                const Icon(Icons.psychology, color: Color(0xFF0D54F2), size: 32),
                const SizedBox(width: 16),
                Expanded(child: Text(remark?.message ?? "Commencez le mouvement doucement", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _finishSession(notifier),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D54F2), minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text("TERMINER LE TEST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraAndOverlay(TrackingNotifier notifier) {
    if (!_isCameraReady || _cameraController == null) {
      return Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: Color(0xFF0D54F2))));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;
        final Size imageSize = _cameraController!.value.previewSize!;
        final double previewWidth = imageSize.height;
        final double previewHeight = imageSize.width;

        return SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CameraPreview(_cameraController!),
                  if (notifier.lastSmoothedPose != null || _poses.isNotEmpty)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: PosePainter(
                          notifier.lastSmoothedPose != null ? [notifier.lastSmoothedPose!] : _poses,
                          imageSize,
                          InputImageRotation.rotation90deg,
                          isFrontCamera: _isFrontCamera,
                          isLeftArmActive: notifier.lastResult?.isLeftArmActive,
                          currentAngle: notifier.lastResult?.angle ?? 0.0,
                          selectedView: notifier.detectedView,
                          isLeftSideVisible: notifier.isLeftSideVisible,
                          exerciseId: notifier.exerciseId,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _finishSession(TrackingNotifier notifier) async {
    if (notifier.maxLeftAngle < 15.0 || notifier.maxRightAngle < 15.0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez évaluer les deux bras avant de terminer le test."), backgroundColor: Colors.redAccent));
      return;
    }

    final result = notifier.lastResult;
    if (result != null) {
      final provider = Provider.of<GlobalDataProvider>(context, listen: false);
      final finalData = IATrackingData(
        exerciseId: notifier.exerciseId,
        title: provider.selectedExercise?.title ?? "Test IA",
        currentValue: notifier.maxAngle,
        leftValue: notifier.maxLeftAngle,
        rightValue: notifier.maxRightAngle,
        unit: "°",
        objective: 180,
        precision: notifier.precision,
        guidanceText: "Test terminé",
        date: DateTime.now(),
        trunkLeanAngle: result.trunkLean,
        elbowFlexion: result.elbowFlexion,
        isPostureCorrect: result.isPostureCorrect,
        selectedView: notifier.detectedView,
        isHealthy: _isLeftSide,
        side: _isLeftSide ? "Gauche" : "Droite",
        avgTrunkLean: notifier.avgTrunkLean,
        maxTrunkLean: notifier.maxTrunkLean,
        minElbowFlexion: notifier.minElbowFlexion,
        avgShoulderImbalance: notifier.avgShoulderImbalance,
      );

      provider.saveIATrackingResult(finalData);
      await _voiceService.stop();
      Navigator.pop(context);
    }
  }
}
