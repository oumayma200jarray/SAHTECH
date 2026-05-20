import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/core/utils/biomechanics_utils.dart';
import 'package:sahtek/models/pose_model.dart';
import 'package:sahtek/models/ia_tracking_model.dart';
import 'package:sahtek/features/ia_tracking/domain/entities/movement_result.dart';
import 'package:sahtek/features/ia_tracking/domain/use_cases/process_pose_use_case.dart';
import 'package:sahtek/features/ia_tracking/domain/use_cases/detect_view_use_case.dart';
import 'package:sahtek/features/ia_tracking/domain/use_cases/generate_remarks_use_case.dart';

enum TrackingState { waiting, inProgress, completed }

class TrackingNotifier extends ChangeNotifier {
  static Widget provide({required Widget child}) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => GenerateRemarksUseCase()),
        Provider(create: (_) => DetectViewUseCase()),
        ProxyProvider<GenerateRemarksUseCase, ProcessPoseUseCase>(
          update: (_, remarks, __) => ProcessPoseUseCase(remarks),
        ),
        ChangeNotifierProvider(
          create: (context) => TrackingNotifier(
            processPoseUseCase: Provider.of<ProcessPoseUseCase>(
              context,
              listen: false,
            ),
            detectViewUseCase: Provider.of<DetectViewUseCase>(
              context,
              listen: false,
            ),
          ),
        ),
      ],
      child: child,
    );
  }

  // Use Cases
  final ProcessPoseUseCase _processPoseUseCase;
  final DetectViewUseCase _detectViewUseCase;

  // Filters for signal smoothing
  final EMAFilter _angleFilter = EMAFilter(alpha: 0.4); 
  final EMAFilter _leftAngleFilter = EMAFilter(alpha: 0.4);
  final EMAFilter _rightAngleFilter = EMAFilter(alpha: 0.4);
  
  // Landmark smoothing filters
  final Map<PoseLandmarkType, EMAFilter> _xFilters = {};
  final Map<PoseLandmarkType, EMAFilter> _yFilters = {};
  final Map<PoseLandmarkType, EMAFilter> _zFilters = {};

  TrackingNotifier({
    required ProcessPoseUseCase processPoseUseCase,
    required DetectViewUseCase detectViewUseCase,
  }) : _processPoseUseCase = processPoseUseCase,
       _detectViewUseCase = detectViewUseCase;

  Pose _smoothPose(Pose pose) {
    final Map<PoseLandmarkType, PoseLandmark> smoothedLandmarks = {};
    
    pose.landmarks.forEach((type, landmark) {
      // Alpha plus élevé = plus réactif (suit le corps de plus près)
      // X/Y à 0.4 pour un traçage précis, Z à 0.15 car très bruité
      _xFilters.putIfAbsent(type, () => EMAFilter(alpha: 0.4));
      _yFilters.putIfAbsent(type, () => EMAFilter(alpha: 0.4));
      _zFilters.putIfAbsent(type, () => EMAFilter(alpha: 0.15));

      smoothedLandmarks[type] = PoseLandmark(
        type: type,
        x: _xFilters[type]!.filter(landmark.x),
        y: _yFilters[type]!.filter(landmark.y),
        z: _zFilters[type]!.filter(landmark.z),
        likelihood: landmark.likelihood,
      );
    });

    return Pose(landmarks: smoothedLandmarks);
  }

  // State
  TrackingState _state = TrackingState.waiting;
  TrackingState get state => _state;

  CameraView _detectedView = CameraView.front;
  CameraView get detectedView => _detectedView;

  // View & Side Stability Buffers (Crucial: Keep at class level)
  int _viewBuffer = 0;
  CameraView? _lastDetected;
  int _sideBuffer = 0;
  bool? _lastSideWasLeft;
  bool? _isLeftSideVisible;
  bool? get isLeftSideVisible => _isLeftSideVisible;

  // Evaluation sequence
  bool _leftArmEvaluated = false;
  bool _rightArmEvaluated = false;
  bool _wasAboveThreshold = false;
  bool? _currentlyActiveIsLeft;
  bool hasSpokenSwitchArm = false;
  
  bool get hasOneArmEvaluated => (_leftArmEvaluated || _rightArmEvaluated) && !(_leftArmEvaluated && _rightArmEvaluated);

  Pose? _lastSmoothedPose;
  Pose? get lastSmoothedPose => _lastSmoothedPose;

  MovementResult? _lastResult;
  MovementResult? get lastResult => _lastResult;

  double _maxAngle = 0.0;
  double _maxLeftAngle = 0.0;
  double _maxRightAngle = 0.0;

  double get maxAngle => _maxAngle;
  double get maxLeftAngle => _maxLeftAngle;
  double get maxRightAngle => _maxRightAngle;

  CameraView _requiredView = CameraView.front;
  CameraView get requiredView => _requiredView;

  // Session Statistics (Quality & Compensation)
  int _totalFrames = 0;
  int _badPostureFrames = 0;
  
  double _sessionTrunkSum = 0.0;
  int _sessionTrunkCount = 0;
  
  double _sessionShoulderSum = 0.0;
  int _sessionShoulderCount = 0;
  
  double _minElbowFlexionSession = 180.0;
  double _maxTrunkLeanSession = 0.0;

  int get totalFrames => _totalFrames;
  double get precision => _totalFrames > 0 ? (1.0 - (_badPostureFrames / _totalFrames)) * 100 : 0.0;
  double get avgTrunkLean => _sessionTrunkCount > 0 ? _sessionTrunkSum / _sessionTrunkCount : 0.0;
  double get avgShoulderImbalance => _sessionShoulderCount > 0 ? _sessionShoulderSum / _sessionShoulderCount : 0.0;
  double get minElbowFlexion => _minElbowFlexionSession;
  double get maxTrunkLean => _maxTrunkLeanSession;

  String _exerciseId = "";
  String get exerciseId => _exerciseId;
  double _objective = 180.0;
  double get objective => _objective;
  bool hasSpokenIntro = false;

  String get pathologicalSide {
    if (_maxLeftAngle == 0 && _maxRightAngle == 0) return "Non détecté";
    return _maxLeftAngle < _maxRightAngle ? "Gauche" : "Droite";
  }

  bool get isViewCorrect {
    if (_state == TrackingState.waiting) return true;
    return _detectedView == _requiredView;
  }

  void initialize(
    String exerciseId,
    double objective, {
    CameraView requiredView = CameraView.front,
  }) {
    _exerciseId = exerciseId;
    _objective = objective;
    _requiredView = requiredView;
    _state = TrackingState.waiting;
    _maxAngle = 0.0;
    _maxLeftAngle = 0.0;
    _maxRightAngle = 0.0;
    _lastResult = null;
    hasSpokenIntro = false;
    hasSpokenSwitchArm = false;
    _leftArmEvaluated = false;
    _rightArmEvaluated = false;
    _wasAboveThreshold = false;
    _currentlyActiveIsLeft = null;
    
    // Reset Session Stats
    _totalFrames = 0;
    _badPostureFrames = 0;
    _sessionTrunkSum = 0.0;
    _sessionTrunkCount = 0;
    _sessionShoulderSum = 0.0;
    _sessionShoulderCount = 0;
    _minElbowFlexionSession = 180.0;
    _maxTrunkLeanSession = 0.0;

    _processPoseUseCase.resetSide();
    _angleFilter.filter(0);
    notifyListeners();
  }

  void processPose(Pose rawPose, [bool? isFrontCamera]) {
    final pose = _smoothPose(rawPose);
    _lastSmoothedPose = pose;

    // 1. View detection stability
    final currentView = _detectViewUseCase.execute(pose);
    if (currentView == _lastDetected) {
      _viewBuffer++;
    } else {
      _lastDetected = currentView;
      _viewBuffer = 0;
    }
    if (_viewBuffer >= 5) _detectedView = currentView;

    // 2. Side visibility stability (Profile Only)
    if (_detectedView == CameraView.profile) {
      final lEar = pose.landmarks[PoseLandmarkType.leftEar]?.likelihood ?? 0;
      final rEar = pose.landmarks[PoseLandmarkType.rightEar]?.likelihood ?? 0;
      final lEye = pose.landmarks[PoseLandmarkType.leftEye]?.likelihood ?? 0;
      final rEye = pose.landmarks[PoseLandmarkType.rightEye]?.likelihood ?? 0;
      
      final lScore = lEar + lEye;
      final rScore = rEar + rEye;

      // Lock visibility if confidence is very low (e.g. arm occluding face)
      if (lScore < 0.3 && rScore < 0.3 && _isLeftSideVisible != null) {
        // Keep previous state
      } else {
        final bool currentlyLeft = lScore > rScore;

        if (currentlyLeft == _lastSideWasLeft) {
          _sideBuffer++;
        } else {
          _lastSideWasLeft = currentlyLeft;
          _sideBuffer = 0;
        }
        
        if (_sideBuffer >= 10) _isLeftSideVisible = currentlyLeft;
      }
    } else {
      _isLeftSideVisible = null;
    }

    final rawResult = _processPoseUseCase.execute(
      pose, 
      _exerciseId, 
      isFrontCamera: isFrontCamera ?? false,
    );
    
    final double smoothedAngle = _angleFilter.filter(rawResult.angle);
    final double smoothedLeft = _leftAngleFilter.filter(rawResult.leftAngle);
    final double smoothedRight = _rightAngleFilter.filter(rawResult.rightAngle);

    final result = rawResult.copyWith(
      angle: smoothedAngle,
      leftAngle: smoothedLeft,
      rightAngle: smoothedRight,
    );
    _lastResult = result;

    if (isViewCorrect) {
      if (result.leftAngle > _maxLeftAngle) _maxLeftAngle = result.leftAngle;
      if (result.rightAngle > _maxRightAngle) _maxRightAngle = result.rightAngle;
      _maxAngle = _maxLeftAngle > _maxRightAngle ? _maxLeftAngle : _maxRightAngle;
    }

    _updateState(result);
    notifyListeners();
  }

  void _updateState(MovementResult result) {
    final double currentAngle = result.angle;

    if (_state == TrackingState.waiting && currentAngle > 15.0 && isViewCorrect) {
      _state = TrackingState.inProgress;
    }

    if (_state == TrackingState.inProgress) {
      // Accumulate session stats
      _totalFrames++;
      if (!result.isPostureCorrect) {
        _badPostureFrames++;
      }
      
      final absTrunkLean = result.trunkLean.abs();
      _sessionTrunkSum += absTrunkLean;
      _sessionTrunkCount++;
      if (absTrunkLean > _maxTrunkLeanSession) _maxTrunkLeanSession = absTrunkLean;
      
      _sessionShoulderSum += result.shoulderImbalance;
      _sessionShoulderCount++;
      
      if (result.elbowFlexion < _minElbowFlexionSession) {
        _minElbowFlexionSession = result.elbowFlexion;
      }
      final isLeft = _lastResult?.isLeftArmActive;

      if (isLeft != null) {
        // Détecter si on a changé de bras en plein milieu sans finir le précédent
        if (_currentlyActiveIsLeft != null && _currentlyActiveIsLeft != isLeft && _wasAboveThreshold) {
          // On a switché de bras alors qu'on était en haut. 
          // On réinitialise pour le nouveau bras pour ne pas "valider" le précédent par erreur
          _wasAboveThreshold = false;
        }

        if (currentAngle > 35.0) {
          _wasAboveThreshold = true;
          _currentlyActiveIsLeft = isLeft;
        }

        if (_wasAboveThreshold && currentAngle < 20.0) {
          if (_currentlyActiveIsLeft == true) {
            _leftArmEvaluated = true;
          } else if (_currentlyActiveIsLeft == false) {
            _rightArmEvaluated = true;
          }
          _wasAboveThreshold = false;
          _processPoseUseCase.resetSide();
        }
      }

      if (_leftArmEvaluated && _rightArmEvaluated) {
        _state = TrackingState.completed;
      }
    }
  }
}
