import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:sahtek/models/ia_tracking_model.dart';

enum TrackingState { waiting, inProgress, completed }

class TrackingController extends ChangeNotifier {
  TrackingState _state = TrackingState.waiting;
  TrackingState get state => _state;

  IATrackingData? _trackingData;
  IATrackingData? get trackingData => _trackingData;

  String _feedbackMessage = "Pret a commencer ?";
  String get feedbackMessage => _feedbackMessage;

  bool _isComparisonCorrect = true;
  bool get isComparisonCorrect => _isComparisonCorrect;

  double _calibratedRestAngle = 0.0;
  bool _isCalibrated = false;

  double _smoothedAngle = 0.0;
  bool _hasSmoothedAngle = false;

  final List<double> _sessionAngleHistory = [];
  List<double> get sessionAngleHistory =>
      List.unmodifiable(_sessionAngleHistory);

  final List<double> _sessionTrunkHistory = [];
  final List<double> _sessionElbowHistory = [];

  double _bestValidAngle = 0.0;
  int _badPostureFrames = 0;
  int _totalFrames = 0;

  double get bestValidAngle => _bestValidAngle;
  double get movementQualityScore => _computeMovementQuality();

  void initialize(IATrackingData data) {
    _trackingData = data;
    _state = TrackingState.waiting;
    _feedbackMessage = "Mettez-vous en position de depart";
    _isCalibrated = false;
    _smoothedAngle = 0.0;
    _hasSmoothedAngle = false;
    _sessionAngleHistory.clear();
    _sessionTrunkHistory.clear();
    _sessionElbowHistory.clear();
    _bestValidAngle = 0.0;
    _badPostureFrames = 0;
    _totalFrames = 0;
    notifyListeners();
  }

  void processPose(Pose pose) {
    if (_trackingData == null) return;

    const double minConfidence = 0.45;

    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];

    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (lShoulder == null ||
        lHip == null ||
        rShoulder == null ||
        rHip == null ||
        lShoulder.likelihood < minConfidence ||
        lHip.likelihood < minConfidence ||
        rShoulder.likelihood < minConfidence ||
        rHip.likelihood < minConfidence) {
      return;
    }

    final bool isExternalRotation =
        (_trackingData!.exerciseId?.contains('rotation') ?? false) ||
        _trackingData!.title.toLowerCase().contains('rotation');

    final double lAngle = isExternalRotation
        ? _calculateExternalRotationAngle(lShoulder, lElbow, lWrist)
        : _calculateShoulderElevationAngle(lHip, lShoulder, lElbow, lWrist);

    final double rAngle = isExternalRotation
        ? _calculateExternalRotationAngle(rShoulder, rElbow, rWrist)
        : _calculateShoulderElevationAngle(rHip, rShoulder, rElbow, rWrist);

    final bool isLeftActive = lAngle >= rAngle;
    final double rawCurrentAngle = isLeftActive ? lAngle : rAngle;
    final double currentAngle = _smoothAngle(rawCurrentAngle);
    _trackingData!.currentValue = currentAngle;

    _sessionAngleHistory.add(currentAngle);
    if (_sessionAngleHistory.length > 240) {
      _sessionAngleHistory.removeAt(0);
    }

    final double midShoulderX = (lShoulder.x + rShoulder.x) / 2;
    final double midShoulderY = (lShoulder.y + rShoulder.y) / 2;
    final double midHipX = (lHip.x + rHip.x) / 2;
    final double midHipY = (lHip.y + rHip.y) / 2;

    final double trunkAngle =
        (math.atan2(midShoulderX - midHipX, midHipY - midShoulderY)).abs() *
        180 /
        math.pi;
    _trackingData!.trunkLeanAngle = trunkAngle;

    _sessionTrunkHistory.add(trunkAngle);
    if (_sessionTrunkHistory.length > 240) {
      _sessionTrunkHistory.removeAt(0);
    }

    double elbowFlex = 180.0;
    if (isLeftActive && lElbow != null && lWrist != null) {
      elbowFlex = _calculateAngle(lShoulder, lElbow, lWrist);
    } else if (!isLeftActive && rElbow != null && rWrist != null) {
      elbowFlex = _calculateAngle(rShoulder, rElbow, rWrist);
    }
    _trackingData!.elbowFlexion = elbowFlex;

    _sessionElbowHistory.add(elbowFlex);
    if (_sessionElbowHistory.length > 240) {
      _sessionElbowHistory.removeAt(0);
    }

    final TrackingState previousState = _state;
    final bool postureWasCorrect = _isComparisonCorrect;

    _isComparisonCorrect = true;
    if (trunkAngle > 15.0) {
      _isComparisonCorrect = false;
      _feedbackMessage = "Redressez votre dos";
    } else if (!isExternalRotation && elbowFlex < 150.0) {
      _isComparisonCorrect = false;
      _feedbackMessage = "Gardez votre bras tendu";
    }

    _trackingData!.isPostureCorrect = _isComparisonCorrect;

    _totalFrames += 1;
    if (!_isComparisonCorrect) {
      _badPostureFrames += 1;
    }
    if (_isComparisonCorrect && currentAngle > _bestValidAngle) {
      _bestValidAngle = currentAngle;
    }

    switch (_state) {
      case TrackingState.waiting:
        if (!_isCalibrated) {
          _calibratedRestAngle = currentAngle;
          _isCalibrated = true;
        }
        if (currentAngle > _calibratedRestAngle + 12.0 || currentAngle > 20.0) {
          _state = TrackingState.inProgress;
        } else {
          _feedbackMessage = _isComparisonCorrect
              ? "Levez le bras pour commencer"
              : _feedbackMessage;
        }
        break;

      case TrackingState.inProgress:
        if (currentAngle >= _trackingData!.objective - 8.0) {
          _state = TrackingState.completed;
          _feedbackMessage = _isComparisonCorrect
              ? "Objectif atteint, redescendez"
              : _feedbackMessage;
        } else {
          _feedbackMessage = _isComparisonCorrect
              ? "Montez encore un peu"
              : _feedbackMessage;
        }
        break;

      case TrackingState.completed:
        if (currentAngle < _calibratedRestAngle + 10.0 || currentAngle < 18.0) {
          _state = TrackingState.waiting;
          _feedbackMessage = "Bien, pret pour la suivante";
        } else {
          _feedbackMessage = "Redescendez doucement";
        }
        break;
    }

    _trackingData!.guidanceText = _feedbackMessage;

    if (postureWasCorrect != _isComparisonCorrect || previousState != _state) {
      notifyListeners();
      return;
    }
    notifyListeners();
  }

  double _computeMovementQuality() {
    if (_totalFrames == 0 || _trackingData == null) return 0.0;

    final double mobilityScore =
        (_bestValidAngle / _trackingData!.objective * 100).clamp(0.0, 100.0);
    final double postureRatio = 1.0 - (_badPostureFrames / _totalFrames);
    final double postureScore = (postureRatio * 100.0).clamp(0.0, 100.0);

    final double avgTrunk = _sessionTrunkHistory.isEmpty
        ? 0.0
        : _sessionTrunkHistory.reduce((a, b) => a + b) /
              _sessionTrunkHistory.length;
    final double avgElbow = _sessionElbowHistory.isEmpty
        ? 180.0
        : _sessionElbowHistory.reduce((a, b) => a + b) /
              _sessionElbowHistory.length;

    final double trunkPenalty = (avgTrunk > 12.0)
        ? ((avgTrunk - 12.0) * 1.8).clamp(0.0, 25.0)
        : 0.0;
    final double elbowPenalty = (avgElbow < 150.0)
        ? ((150.0 - avgElbow) * 1.2).clamp(0.0, 20.0)
        : 0.0;

    final double rawScore =
        (mobilityScore * 0.55) +
        (postureScore * 0.45) -
        trunkPenalty -
        elbowPenalty;
    return rawScore.clamp(0.0, 100.0);
  }

  double _smoothAngle(double rawAngle) {
    const double alpha = 0.45;
    if (!_hasSmoothedAngle) {
      _smoothedAngle = rawAngle;
      _hasSmoothedAngle = true;
      return rawAngle;
    }
    _smoothedAngle = (alpha * rawAngle) + ((1 - alpha) * _smoothedAngle);
    return _smoothedAngle;
  }

  double _calculateShoulderElevationAngle(
    PoseLandmark hip,
    PoseLandmark shoulder,
    PoseLandmark? elbow,
    PoseLandmark? wrist,
  ) {
    final PoseLandmark distal = elbow ?? wrist ?? shoulder;
    return _calculateAngle(hip, shoulder, distal);
  }

  double _calculateExternalRotationAngle(
    PoseLandmark shoulder,
    PoseLandmark? elbow,
    PoseLandmark? wrist,
  ) {
    if (elbow == null || wrist == null) return 0.0;

    final PoseLandmark verticalRef = PoseLandmark(
      type: PoseLandmarkType.leftKnee,
      x: elbow.x,
      y: elbow.y + 100,
      z: elbow.z,
      likelihood: 1,
    );

    final double upperArmLength = _distance(shoulder, elbow);
    final double forearmLength = _distance(elbow, wrist);
    if (upperArmLength < 5 || forearmLength < 5) return 0.0;

    final double angle = _calculateAngle(verticalRef, elbow, wrist);
    return angle.clamp(0.0, 90.0);
  }

  double _distance(PoseLandmark p1, PoseLandmark p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double _calculateAngle(PoseLandmark p1, PoseLandmark p2, PoseLandmark p3) {
    final double angle =
        (math.atan2(p3.y - p2.y, p3.x - p2.x) -
                math.atan2(p1.y - p2.y, p1.x - p2.x))
            .abs();
    double degrees = angle * 180.0 / math.pi;
    if (degrees > 180.0) degrees = 360.0 - degrees;
    return degrees;
  }
}
