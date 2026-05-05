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
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sahtek/features/ia_tracking/controllers/tracking_controller.dart';
import 'package:sahtek/features/ia_tracking/services/base_ai_service.dart';
import 'package:sahtek/features/ia_tracking/services/gemini_ai_service.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart' as mlkit;
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
  
  // Utilisation de l'interface BaseAIService pour permettre le switch Gemini/Claude
  final BaseAIService _aiService = GeminiAIService(); 
  final PoseDetectionService _poseDetectionService = PoseDetectionService();
  
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  List<Pose> _poses = [];
  Timer? _analysisTimer;

  // Stats session
  double _sessionMaxAngle = 0.0;
  final List<String> _sessionFrames = [];
  int _totalFramesAnalyzed = 0;

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
        _startAnalysisTimer();
      }
    } catch (e) {
      debugPrint('Error camera init: $e');
    }
  }

  void _startAnalysisTimer() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(
      const Duration(milliseconds: 250), // 4 FPS - Stable
      (_) => _captureAndAnalyze(),
    );
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isCameraReady || _isProcessing || _cameraController == null) return;
    _isProcessing = true;

    try {
      final XFile file = await _cameraController!.takePicture();
      final mlkit.InputImage inputImage = mlkit.InputImage.fromFilePath(file.path);
      
      final List<Pose> poses = await _poseDetectionService.processImage(inputImage);

      bool shouldKeepFrame = false;
      if (mounted) {
        setState(() {
          _poses = poses;
          if (poses.isNotEmpty) {
            _trackingController.processPose(poses.first);
            
            // Capture pour le Time-Lapse (Video d'exécution)
            if (_totalFramesAnalyzed % 8 == 0 && _sessionFrames.length < 15) {
              _sessionFrames.add(file.path);
              shouldKeepFrame = true;
            }
          }
          _totalFramesAnalyzed++;
        });
      }
      
      if (!shouldKeepFrame) {
        await File(file.path).delete();
      }
      
    } catch (e) {
      debugPrint('Capture Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _onTrackingUpdate() {
    if (!mounted) return;
    final data = _trackingController.trackingData;
    if (data == null) return;

    setState(() {
      if (data.currentValue > _sessionMaxAngle) {
        _sessionMaxAngle = data.currentValue;
      }
    });

    _checkAndTriggerAI(data);
  }

  int _stagnationCount = 0;
  double _lastAngleForStagnation = 0.0;

  // ÉTAPE E : Gérer les conditions d'exécution du NLP (Analyse Textuelle & Voix)
  // Cette fonction détermine SI on doit appeler le modèle de langage (Claude)
  void _checkAndTriggerAI(IATrackingData data) {
    if (_isAILoading || _trackingController.state == TrackingState.completed)
      return;

    // Détection de stagnation (L'utilisateur ne bouge plus)
    // On vérifie si l'angle courant a varié de moins de 2 degrés depuis la dernière capture
    // On ne compte la stagnation que si le mouvement a déjà commencé (angle > 10.0)
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

    // Senior AI: On supprime la capture d'image pour les remarques "Live"
    // Cela divise le temps de réponse par 3 et rend le coaching instantané.
    // L'image n'est envoyée que pour le compte-rendu final de session.
    final feedback = await _aiService.getFeedback(data, imageBytes: null);

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
          // 1. Fond caméra + overlay pose dans le même repère d'aspect ratio.
          Positioned.fill(child: _buildCameraAndOverlay()),

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("POSES: ${_poses.length}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                            Text("STREAM: ${_cameraController?.value.isStreamingImages ?? false}", style: const TextStyle(color: Colors.white, fontSize: 8)),
                            Text("PROC: $_isProcessing", style: const TextStyle(color: Colors.white, fontSize: 8)),
                          ],
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
                        "${data?.title.toUpperCase() ?? "FLEXION D'ÉPAULE"} ${_trackingController.isLeftArmActive == true ? "(BRAS GAUCHE)" : _trackingController.isLeftArmActive == false ? "(BRAS DROIT)" : ""}",
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
                                "GUIDAGE SAHTECH",
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
                    "CAPTEUR IA : ACTIF  •  QUALITÉ DU MOUVEMENT",
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

  InputImageRotation _mapRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  mlkit.InputImageRotation _mapMLKitRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 90:
        return mlkit.InputImageRotation.rotation90deg;
      case 180:
        return mlkit.InputImageRotation.rotation180deg;
      case 270:
        return mlkit.InputImageRotation.rotation270deg;
      case 0:
      default:
        return mlkit.InputImageRotation.rotation0deg;
    }
  }

  Widget _buildCameraAndOverlay() {
    if (!_isCameraReady || _cameraController == null) {
      return Container(color: Colors.black);
    }

    final previewSize = _cameraController!.value.previewSize;
    final double aspectRatio = previewSize != null
        ? (previewSize.height / previewSize.width)
        : (1 / _cameraController!.value.aspectRatio);

    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(_cameraController!),
            if (_poses.isNotEmpty)
              CustomPaint(
                painter: PosePainter(
                  _poses,
                  previewSize != null
                      ? Size(previewSize.width, previewSize.height)
                      : const Size(1280, 720),
                  _mapRotation(
                    _cameraController!.description.sensorOrientation,
                  ),
                  isFrontCamera: _cameraController?.description.lensDirection ==
                      CameraLensDirection.front,
                  isLeftArmActive: _trackingController.isLeftArmActive,
                  currentAngle: _trackingController.trackingData?.currentValue ?? 0.0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishSession() async {
    final data = _trackingController.trackingData;
    if (data != null) {
      final List<double> trackedHistory =
          _trackingController.sessionAngleHistory;
      final double bestValidAngle = _trackingController.bestValidAngle;
      
      final tempFinalData = IATrackingData(
        title: data.title,
        currentValue: bestValidAngle > 0 ? bestValidAngle : _sessionMaxAngle,
        unit: data.unit,
        objective: data.objective,
        precision: _trackingController.movementQualityScore,
        guidanceText: _trackingController.feedbackMessage,
        angleHistory: trackedHistory,
        date: DateTime.now(),
        sessionFrames: _sessionFrames,
        trunkLeanAngle: data.trunkLeanAngle,
        signedTrunkLean: data.signedTrunkLean,
        elbowFlexion: data.elbowFlexion,
        isPostureCorrect: data.isPostureCorrect,
        repetitionCount: data.repetitionCount,
        totalRepsPlanned: data.totalRepsPlanned,
        avgTrunkLean: data.avgTrunkLean,
        maxTrunkLean: data.maxTrunkLean,
        minElbowFlexion: data.minElbowFlexion,
        avgShoulderImbalance: data.avgShoulderImbalance,
      );

      // Génération de la synthèse AI finale
      final aiSummary = await _aiService.generateSessionSummary(tempFinalData);
      
      final finalData = IATrackingData(
        title: tempFinalData.title,
        currentValue: tempFinalData.currentValue,
        unit: tempFinalData.unit,
        objective: tempFinalData.objective,
        precision: tempFinalData.precision,
        guidanceText: tempFinalData.guidanceText,
        angleHistory: tempFinalData.angleHistory,
        date: tempFinalData.date,
        sessionFrames: tempFinalData.sessionFrames,
        trunkLeanAngle: tempFinalData.trunkLeanAngle,
        signedTrunkLean: tempFinalData.signedTrunkLean,
        elbowFlexion: tempFinalData.elbowFlexion,
        isPostureCorrect: tempFinalData.isPostureCorrect,
        repetitionCount: tempFinalData.repetitionCount,
        totalRepsPlanned: tempFinalData.totalRepsPlanned,
        avgTrunkLean: tempFinalData.avgTrunkLean,
        maxTrunkLean: tempFinalData.maxTrunkLean,
        minElbowFlexion: tempFinalData.minElbowFlexion,
        avgShoulderImbalance: tempFinalData.avgShoulderImbalance,
        aiSummary: aiSummary,
      );

      final provider = Provider.of<GlobalDataProvider>(context, listen: false);
      provider.saveIATrackingResult(finalData);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/resultat_test_ia');
      }
    }
  }
}
