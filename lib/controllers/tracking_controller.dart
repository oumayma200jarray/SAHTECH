import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:sahtek/models/ia_tracking_model.dart';

enum TrackingState { waiting, inProgress, completed }

class TrackingController extends ChangeNotifier {
  TrackingState _state = TrackingState.waiting;
  TrackingState get state => _state;

  IATrackingData? _trackingData;
  IATrackingData? get trackingData => _trackingData;

  String _feedbackMessage = "Prêt à commencer ?";
  String get feedbackMessage => _feedbackMessage;

  bool _isComparisonCorrect = true;
  bool get isComparisonCorrect => _isComparisonCorrect;

  double _calibratedRestAngle = 0.0;
  bool _isCalibrated = false;

  void initialize(IATrackingData data) {
    _trackingData = data;
    _state = TrackingState.waiting;
    _feedbackMessage = "Mettez-vous en position de départ";
    _isCalibrated = false;
    notifyListeners();
  }

  void processPose(Pose pose) {
    if (_trackingData == null) return;

    // Seuil de confiance (ML Kit likelihood)
    const double minConfidence = 0.3;

    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];

    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (lShoulder == null || lHip == null || rShoulder == null || rHip == null) return;
    if (lShoulder.likelihood < minConfidence || lHip.likelihood < minConfidence) return;

    // Calcul des angles pour les deux côtés
    final double lAngle = _calculateAngle(lHip, lShoulder, lWrist ?? lElbow ?? lShoulder);
    final double rAngle = _calculateAngle(rHip, rShoulder, rWrist ?? rElbow ?? rShoulder);
    
    // On prend le maximum (le bras qui bouge)
    final double angle = math.max(lAngle, rAngle);
    _trackingData!.currentValue = angle;

    // 1. Vérification Posture (Optionnel mais recommandé pour les exercices d'épaule)
    final double shoulderSlope = (lShoulder.y - rShoulder.y).abs();
    if (shoulderSlope > 100.0) { // Tolérance élargie
      _isComparisonCorrect = false;
      _feedbackMessage = "Gardez les épaules bien droites";
      notifyListeners();
      return;
    }

    _isComparisonCorrect = true;

    // 3. Machine à états
    switch (_state) {
      case TrackingState.waiting:
        if (!_isCalibrated) {
          _calibratedRestAngle = angle;
          _isCalibrated = true;
        }

        if (angle > _calibratedRestAngle + 25.0 || angle > 45.0) {
          _state = TrackingState.inProgress;
          _feedbackMessage = "Montez le bras doucement";
        } else {
          _feedbackMessage = "Levez le bras pour commencer";
        }
        break;

      case TrackingState.inProgress:
        if (angle >= _trackingData!.objective - 15.0) {
          _state = TrackingState.completed;
          _feedbackMessage = "Objectif atteint ! Redescendez";
        } else {
          _feedbackMessage = "Continuez à monter";
        }
        break;

      case TrackingState.completed:
        if (angle < _calibratedRestAngle + 20.0 || angle < 35.0) {
          _state = TrackingState.waiting;
          _feedbackMessage = "Mouvement terminé. Recommencez";
        } else {
          _feedbackMessage = "Redescendez votre bras";
        }
        break;
    }

    notifyListeners();
  }

  double _calculateAngle(PoseLandmark p1, PoseLandmark p2, PoseLandmark p3) {
    final double angle = (math.atan2(p3.y - p2.y, p3.x - p2.x) -
            math.atan2(p1.y - p2.y, p1.x - p2.x))
        .abs();
    double degrees = angle * 180.0 / 3.14159265;
    if (degrees > 180.0) degrees = 360.0 - degrees;
    return degrees;
  }
}
