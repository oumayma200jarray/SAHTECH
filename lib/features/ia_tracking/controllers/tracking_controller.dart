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

    // ÉTAPE B : Filtrage des données (Data Cleaning)
    const double minConfidence = 0.3;

    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];

    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (lShoulder == null || lHip == null || rShoulder == null || rHip == null)
      return;
    if (lShoulder.likelihood < minConfidence || lHip.likelihood < minConfidence)
      return;

    // ÉTAPE C : Transformation Mathématique et Géométrique
    final double lAngle = _calculateAngle(
      lHip,
      lShoulder,
      lWrist ?? lElbow ?? lShoulder,
    );
    final double rAngle = _calculateAngle(
      rHip,
      rShoulder,
      rWrist ?? rElbow ?? rShoulder,
    );

    // On identifie le côté actif
    final bool isLeftActive = lAngle > rAngle;
    final double currentAngle = math.max(lAngle, rAngle);
    _trackingData!.currentValue = currentAngle;

    // --- CALCUL DES MÉTRIQUES DE QUALITÉ (Anti-Triche) ---

    // 1. Inclinaison du tronc (Leaning Detection)
    // On calcule le milieu des épaules et le milieu des hanches pour définir l'axe du corps
    final double midShoulderX = (lShoulder.x + rShoulder.x) / 2;
    final double midShoulderY = (lShoulder.y + rShoulder.y) / 2;
    final double midHipX = (lHip.x + rHip.x) / 2;
    final double midHipY = (lHip.y + rHip.y) / 2;
    
    // On calcule l'angle de cet axe par rapport à une verticale parfaite (0°)
    // Si l'angle dépasse 15°, cela signifie que le patient triche en penchant son corps
    final double trunkAngle = (math.atan2(midShoulderX - midHipX, midHipY - midShoulderY)).abs() * 180 / math.pi;
    _trackingData!.trunkLeanAngle = trunkAngle;

    // 2. Flexion du coude (Elbow Flexion Detection)
    // Pour un exercice d'épaule, le coude doit être verrouillé (angle proche de 180°)
    double elbowFlex = 180.0;
    if (isLeftActive && lElbow != null && lWrist != null) {
      elbowFlex = _calculateAngle(lShoulder, lElbow, lWrist);
    } else if (!isLeftActive && rElbow != null && rWrist != null) {
      elbowFlex = _calculateAngle(rShoulder, rElbow, rWrist);
    }
    _trackingData!.elbowFlexion = elbowFlex;

    // 3. Vérification Globale de Posture
    bool postureWasCorrect = _isComparisonCorrect;
    _isComparisonCorrect = true;

    // Si le patient dépasse les seuils de tolérance, on change le message de feedback
    // et on empêche l'IA de donner un commentaire positif.
    if (trunkAngle > 15.0) {
      _isComparisonCorrect = false;
      _feedbackMessage = "Redressez votre dos, vous penchez trop !";
    } else if (elbowFlex < 150.0) { // Tolérance de 30° pour le coude
      _isComparisonCorrect = false;
      _feedbackMessage = "Gardez votre bras bien tendu.";
    }

    _trackingData!.isPostureCorrect = _isComparisonCorrect;

    // ÉTAPE D : Gouvernance de l'Exercice (Machine à États Finis)
    switch (_state) {
      case TrackingState.waiting:
        if (!_isCalibrated) {
          _calibratedRestAngle = currentAngle;
          _isCalibrated = true;
        }

        if (currentAngle > _calibratedRestAngle + 25.0 || currentAngle > 45.0) {
          _state = TrackingState.inProgress;
        } else {
          _feedbackMessage = _isComparisonCorrect ? "Levez le bras pour commencer" : _feedbackMessage;
        }
        break;

      case TrackingState.inProgress:
        if (currentAngle >= _trackingData!.objective - 15.0) {
          _state = TrackingState.completed;
          _feedbackMessage = _isComparisonCorrect ? "Objectif atteint ! Redescendez" : _feedbackMessage;
        } else {
          _feedbackMessage = _isComparisonCorrect ? "Montez encore un peu" : _feedbackMessage;
        }
        break;

      case TrackingState.completed:
        if (currentAngle < _calibratedRestAngle + 20.0 || currentAngle < 35.0) {
          _state = TrackingState.waiting;
          _feedbackMessage = "Bien ! Prêt pour la suivante ?";
        } else {
          _feedbackMessage = "Redescendez doucement";
        }
        break;
    }

    if (postureWasCorrect != _isComparisonCorrect || _state != _state) {
       notifyListeners();
    }
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
