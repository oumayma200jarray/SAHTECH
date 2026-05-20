import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:sahtek/models/pose_model.dart';
import 'package:sahtek/models/ia_tracking_model.dart';
import 'package:sahtek/features/ia_tracking/services/pose_smoother.dart';

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
  double _calibratedTrunkLength = 0.0;
  bool _isCalibrated = false;

  bool _isCountdownActive = false;
  DateTime? _countdownStartTime;
  int countdownValue = 3;

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

  // Accumulateurs pour statistiques de session (Senior AI Analytics)
  final List<double> _sessionShoulderImbalanceHistory = [];
  double _maxTrunkLeanSession = 0.0;
  double _minElbowFlexionSession = 180.0;
  
  double _sessionTrunkSum = 0.0;
  int _sessionTrunkCount = 0;
  double _sessionShoulderSum = 0.0;
  int _sessionShoulderCount = 0;

  // Verrouillage du côté actif (Senior AI Logic)
  bool? _isLeftArmActive;
  bool? get isLeftArmActive => _isLeftArmActive;

  // Filtres de lissage pour les landmarks clés (Senior AI Improvement)
  // On augmente alpha (0.35 -> 0.75) pour réduire le ralentissement et rendre le suivi très réactif
  final Map<PoseLandmarkType, SmoothedPoint> _filters = {
    PoseLandmarkType.leftShoulder: SmoothedPoint(alpha: 0.75),
    PoseLandmarkType.rightShoulder: SmoothedPoint(alpha: 0.75),
    PoseLandmarkType.leftElbow: SmoothedPoint(alpha: 0.75),
    PoseLandmarkType.rightElbow: SmoothedPoint(alpha: 0.75),
    PoseLandmarkType.leftWrist: SmoothedPoint(alpha: 0.75),
    PoseLandmarkType.rightWrist: SmoothedPoint(alpha: 0.75),
    PoseLandmarkType.leftHip: SmoothedPoint(alpha: 0.75),
    PoseLandmarkType.rightHip: SmoothedPoint(alpha: 0.75),
  };

  static const double minConfidence = 0.45;

  double get bestValidAngle => _bestValidAngle;
  double get movementQualityScore => _computeMovementQuality();

  void initialize(IATrackingData data) {
    _trackingData = data;
    _trackingData!.repetitionCount = 0; // Reset repetition count
    _state = TrackingState.waiting;
    _feedbackMessage = "Placez-vous...";
    _isCalibrated = false;
    _calibratedTrunkLength = 0.0;
    _isCountdownActive = true;
    _countdownStartTime = DateTime.now();
    countdownValue = 3;
    _smoothedAngle = 0.0;
    _hasSmoothedAngle = false;
    _sessionAngleHistory.clear();
    _sessionTrunkHistory.clear();
    _sessionElbowHistory.clear();
    _sessionShoulderImbalanceHistory.clear();
    _bestValidAngle = 0.0;
    _badPostureFrames = 0;
    _totalFrames = 0;
    _maxTrunkLeanSession = 0.0;
    _minElbowFlexionSession = 180.0;
    _sessionTrunkSum = 0.0;
    _sessionTrunkCount = 0;
    _sessionShoulderSum = 0.0;
    _sessionShoulderCount = 0;
    _isLeftArmActive = null; // Reset du côté actif
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

    if (lShoulder == null || rShoulder == null || lHip == null || rHip == null) {
      return;
    }
    
    // Filtrage strict par score de confiance (Precision AI)
    if (lShoulder.likelihood < minConfidence || 
        rShoulder.likelihood < minConfidence ||
        lHip.likelihood < minConfidence ||
        rHip.likelihood < minConfidence) {
      return;
    }


    // ─── Application du lissage sur les points clés (Senior AI Smoothing) ───
    math.Point<double> _smooth(PoseLandmark? p) {
      if (p == null) return const math.Point(0, 0);
      return _filters[p.type]!.filter(p.x, p.y);
    }

    final lS = _smooth(lShoulder);
    final rS = _smooth(rShoulder);
    final lE = _smooth(lElbow);
    final rE = _smooth(rElbow);
    final lW = _smooth(lWrist);
    final rW = _smooth(rWrist);
    final lH = _smooth(lHip);
    final rH = _smooth(rHip);

    // --- REGROUPEMENT BIOMÉCANIQUE (Senior Architecture) ---
    // On calcule tout par rapport à la verticale absolue pour éviter les biais de posture
    final double midShoulderX = (lS.x + rS.x) / 2;
    final double midShoulderY = (lS.y + rS.y) / 2;
    final double midHipX = (lH.x + rH.x) / 2;
    final double midHipY = (lH.y + rH.y) / 2;

    // Filtre de proximité (Zoom Tracker) - Taille du torse
    final double trunkLength = _pointDistance(math.Point(midShoulderX, midShoulderY), math.Point(midHipX, midHipY));

    // Le sas de préparation (3 secondes)
    if (_isCountdownActive) {
      if (_countdownStartTime != null) {
        final int elapsed = DateTime.now().difference(_countdownStartTime!).inSeconds;
        if (elapsed < 3) {
          countdownValue = 3 - elapsed;
          _feedbackMessage = "Placez-vous... $countdownValue";
          notifyListeners();
          return; // Ignore les frames pendant que le patient recule
        } else {
          _isCountdownActive = false;
        }
      }
    }

    // Bloquer les données polluées si le patient s'approche de l'écran pour appuyer sur Terminer
    if (_isCalibrated && trunkLength > _calibratedTrunkLength * 1.25) {
      _feedbackMessage = "Vous êtes trop près. Reculez.";
      notifyListeners();
      return; // Ignorer cette frame, évite les faux angles maximum
    }

    // AXE DU TRONC (Le vrai "Dos Droit")
    // Angle entre l'axe vertical parfait et la ligne Milieu-Épaules -> Milieu-Hanches
    // positive = inclinaison à droite, negative = inclinaison à gauche
    final double trunkAngle =
        (math.atan2(midShoulderX - midHipX, midHipY - midShoulderY)) *
        180 /
        math.pi;
    _trackingData!.trunkLeanAngle = trunkAngle.abs();
    _trackingData!.signedTrunkLean = trunkAngle; // Preserving the sign
    
    if (_state == TrackingState.inProgress) {
      if (trunkAngle.abs() > _maxTrunkLeanSession) {
        _maxTrunkLeanSession = trunkAngle.abs();
      }
      _sessionTrunkHistory.add(trunkAngle.abs());
      if (_sessionTrunkHistory.length > 240) {
        _sessionTrunkHistory.removeAt(0);
      }
    }

    // --- CALCUL BIOMÉCANIQUE ANATOMIQUE (Senior AI Architecture) ---
    // On mesure l'angle entre l'axe du buste (Épaule-Hanche) et l'axe du bras
    // Cette méthode est insensible à l'inclinaison de la caméra et compense naturellement le tronc.
    double _calculateAnatomicalAngle(
      math.Point shoulder,
      math.Point hip,
      math.Point distal,
    ) {
      // Vecteur référence : vers le bas (tronc)
      // On stabilise le vecteur référence pour éviter les sauts quand l'épaule bouge
      final num v1x = hip.x - shoulder.x;
      final num v1y = hip.y - shoulder.y;
      
      // Vecteur bras
      final num v2x = distal.x - shoulder.x;
      final num v2y = distal.y - shoulder.y;

      final num dot = v1x * v2x + v1y * v2y;
      final num mag1 = math.sqrt(v1x * v1x + v1y * v1y);
      final num mag2 = math.sqrt(v2x * v2x + v2y * v2y);

      if (mag1 < 1 || mag2 < 1) return 0.0;
      final double cosTheta = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
      return math.acos(cosTheta) * 180.0 / math.pi;
    }

    // On prend le maximum entre l'élévation du coude et du poignet pour une précision optimale
    // même si le bras est légèrement fléchi ou si un point est partiellement masqué.
    final double lAngle = math.max(
      _calculateAnatomicalAngle(lS, lH, lE),
      _calculateAnatomicalAngle(lS, lH, lW),
    );
    final double rAngle = math.max(
      _calculateAnatomicalAngle(rS, rH, rE),
      _calculateAnatomicalAngle(rS, rH, rW),
    );

    // ─── Détermination intelligente du bras actif (Senior Logic) ───
    // Seuil de détection pour éviter les faux positifs dus au bruit ML Kit
    const double movementActivationThreshold = 12.0;

    if (_state == TrackingState.waiting) {
      // En attente : on détecte quel bras commence un mouvement significatif
      if (lAngle > movementActivationThreshold && lAngle > rAngle + 5.0) {
        _isLeftArmActive = true;
      } else if (rAngle > movementActivationThreshold &&
          rAngle > lAngle + 5.0) {
        _isLeftArmActive = false;
      } else {
        // Par défaut, on regarde lequel est le plus haut sans verrouiller
        _isLeftArmActive = lAngle >= rAngle;
      }
    } else {
      // En plein exercice : on verrouille le côté mais on autorise un switch
      // si l'autre bras devient massivement plus actif (erreur de détection initiale)
      if (_isLeftArmActive == true && rAngle > lAngle + 40.0) {
        _isLeftArmActive = false;
      } else if (_isLeftArmActive == false && lAngle > rAngle + 40.0) {
        _isLeftArmActive = true;
      }
    }

    // ─── Logique Mathématique Clinique (100% Précision) ───
    double rawCurrentAngle = 0.0;
    final String exerciseId = _trackingData!.exerciseId ?? "";

    if (exerciseId.contains('rotation_externe')) {
      rawCurrentAngle = _isLeftArmActive! 
          ? _calculateRotationAngle(lE, lW, false)
          : _calculateRotationAngle(rE, rW, false);
    } else if (exerciseId.contains('rotation_interne')) {
      rawCurrentAngle = _isLeftArmActive! 
          ? _calculateRotationAngle(lE, lW, true)
          : _calculateRotationAngle(rE, rW, true);
    } else if (exerciseId.contains('abduction') || exerciseId.contains('adduction')) {
      rawCurrentAngle = _isLeftArmActive! ? lAngle : rAngle;
    } else {
      // Formule par défaut pour la Flexion (Plan Sagittal - Élévation frontale)
      rawCurrentAngle = _isLeftArmActive! ? lAngle : rAngle;
    }

    final double currentAngle = _smoothAngle(rawCurrentAngle);
    _trackingData!.currentValue = currentAngle;

    _sessionAngleHistory.add(currentAngle);
    if (_sessionAngleHistory.length > 240) {
      _sessionAngleHistory.removeAt(0);
    }

    // ─── Calcul du déséquilibre des épaules (Nouveau) ───
    // On ne calcule pas le déséquilibre en vue de profil car non pertinent (occlusion)
    double shoulderImbalance = 0.0;
    if (_trackingData!.selectedView != CameraView.profile) {
      final double shoulderWidth = _pointDistance(lS, rS);
      final double shoulderDiffY = (lS.y - rS.y).abs();
      shoulderImbalance = (shoulderWidth > 10)
          ? (shoulderDiffY / shoulderWidth) * 100
          : 0.0;
    }
    _trackingData!.shoulderImbalance = shoulderImbalance;
    if (_state == TrackingState.inProgress) {
      _sessionShoulderImbalanceHistory.add(shoulderImbalance);
      if (_sessionShoulderImbalanceHistory.length > 240) {
        _sessionShoulderImbalanceHistory.removeAt(0);
      }
    }

    double elbowFlex = 180.0;
    if (_isLeftArmActive! && lElbow != null && lWrist != null) {
      elbowFlex = _angle(lS, lE, lW);
    } else {
      elbowFlex = _angle(rS, rE, rW);
    }
    _trackingData!.elbowFlexion = elbowFlex;
    if (_state == TrackingState.inProgress) {
      if (elbowFlex < _minElbowFlexionSession) {
        _minElbowFlexionSession = elbowFlex;
      }
      _sessionElbowHistory.add(elbowFlex);
      if (_sessionElbowHistory.length > 240) {
        _sessionElbowHistory.removeAt(0);
      }
    }

    final TrackingState previousState = _state;
    final bool postureWasCorrect = _isComparisonCorrect;

    _isComparisonCorrect = true;

    final bool isRotation = exerciseId.contains('rotation');

    // Échelonnage des priorités de feedback (Senior Level Architecture)
    if (trunkAngle.abs() > 15.0) {
      // Tolérance augmentée à 15° pour éviter de boucler sur le dos
      _isComparisonCorrect = false;
      _feedbackMessage = trunkAngle > 0 
          ? "Stabilisez votre buste vers la droite" 
          : "Stabilisez votre buste vers la gauche";
    } else if (_trackingData!.selectedView != CameraView.profile && currentAngle < 120.0 && shoulderImbalance > 35.0) {
      // Tolérance d'asymétrie augmentée pour éviter les faux positifs (25 -> 35)
      _isComparisonCorrect = false;
      _feedbackMessage = "Relâchez vos épaules";
    } else if (!isRotation && elbowFlex < 145.0) {
      _isComparisonCorrect = false;
      _feedbackMessage = "Maintenez le bras bien tendu";
    } else if (isRotation && (elbowFlex < 70.0 || elbowFlex > 110.0)) {
      _isComparisonCorrect = false;
      _feedbackMessage = "Pliez le coude à 90 degrés";
    }

    _trackingData!.isPostureCorrect = _isComparisonCorrect;

    _totalFrames += 1;
    if (!_isComparisonCorrect) {
      _badPostureFrames += 1;
    }
    if (_isComparisonCorrect && currentAngle > _bestValidAngle) {
      _bestValidAngle = currentAngle;
    }

    double targetAngle = _trackingData!.objective - 8.0; // Fallback par défaut
    if (exerciseId.contains('flexion')) targetAngle = 175.0; // 180 toléré
    else if (exerciseId.contains('extension')) targetAngle = 45.0; // 45-50
    else if (exerciseId.contains('abduction')) targetAngle = 175.0; // 180 toléré
    else if (exerciseId.contains('adduction')) targetAngle = 30.0; // 30-45
    else if (exerciseId.contains('rotation_externe')) targetAngle = 65.0; // 60-70
    else if (exerciseId.contains('rotation_interne')) targetAngle = 25.0; // 20-30

    switch (_state) {
      case TrackingState.waiting:
        if (!_isCalibrated) {
          _calibratedRestAngle = currentAngle;
          _calibratedTrunkLength = trunkLength; // Calibrage de la taille
          _isCalibrated = true;
        }
        if (currentAngle > _calibratedRestAngle + 12.0 || currentAngle > 20.0) {
          _state = TrackingState.inProgress;
        } else {
          _feedbackMessage = _isComparisonCorrect
              ? "Amorcez le mouvement d'élévation"
              : _feedbackMessage;
        }
        break;

      case TrackingState.inProgress:
        if (currentAngle >= targetAngle) {
          _state = TrackingState.completed;
          _feedbackMessage = "Objectif atteint, redescendez doucement";
        } else {
          _feedbackMessage = _isComparisonCorrect
              ? "Continuez le mouvement"
              : _feedbackMessage;
        }
        break;

      case TrackingState.completed:
        if (currentAngle < _calibratedRestAngle + 10.0 || currentAngle < 18.0) {
          _state = TrackingState.waiting;
          _trackingData!.repetitionCount +=
              1; // Incrémenter la répétition validée
          _feedbackMessage = "Bien, prêt pour la suivante";
        } else {
          _feedbackMessage = "Redescendez doucement";
        }
        break;
    }

    _trackingData!.guidanceText = _feedbackMessage;
 
    // Mise à jour des statistiques finales (Senior Analytics)
    _trackingData!.maxTrunkLean = _maxTrunkLeanSession;
    _trackingData!.minElbowFlexion = _minElbowFlexionSession;
    
    if (_state == TrackingState.inProgress) {
      _sessionTrunkSum += trunkAngle.abs();
      _sessionTrunkCount++;
      _trackingData!.avgTrunkLean = _sessionTrunkSum / _sessionTrunkCount;

      _sessionShoulderSum += shoulderImbalance;
      _sessionShoulderCount++;
      _trackingData!.avgShoulderImbalance = _sessionShoulderSum / _sessionShoulderCount;
    }
    
    if (_totalFrames > 0) {
       _trackingData!.precision = 1.0 - (_badPostureFrames / _totalFrames);
    }

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

    final double trunkPenalty = (avgTrunk > 8.0)
        ? ((avgTrunk - 8.0) * 2.0).clamp(0.0, 30.0)
        : 0.0;
    final double shoulderPenalty = (_trackingData!.shoulderImbalance > 10.0)
        ? ((_trackingData!.shoulderImbalance - 10.0) * 1.5).clamp(0.0, 20.0)
        : 0.0;
    final double elbowPenalty = (avgElbow < 150.0)
        ? ((150.0 - avgElbow) * 1.2).clamp(0.0, 20.0)
        : 0.0;

    final double rawScore =
        (mobilityScore * 0.50) +
        (postureScore * 0.50) -
        trunkPenalty -
        shoulderPenalty -
        elbowPenalty;
    return rawScore.clamp(0.0, 100.0);
  }

  double _smoothAngle(double rawAngle) {
    const double alpha = 0.85; // 0.85 au lieu de 0.60 pour accélérer la réactivité de l'angle
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

  double _calculateRotationAngle(
    math.Point<double>? elbow,
    math.Point<double>? wrist,
    bool isInternal,
  ) {
    if (elbow == null || wrist == null) return 0.0;

    final double dx = (wrist.x - elbow.x).abs();
    final double dy = elbow.y - wrist.y; // Positive = wrist is HIGHER than elbow

    if (dx == 0 && dy == 0) return 0.0;

    final double angle = math.atan2(dy, dx) * 180.0 / math.pi;

    if (isInternal) {
      // Pour la rotation interne (mouvement vers le bas), dy est négatif, angle est négatif.
      // On retourne la valeur absolue pour avoir une mesure positive (0 -> 70°)
      return angle < 0 ? -angle : 0.0;
    } else {
      // Pour la rotation externe (mouvement vers le haut), dy est positif, angle est positif.
      return angle > 0 ? angle : 0.0;
    }
  }

  double _distance(PoseLandmark p1, PoseLandmark p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double _pointDistance(math.Point p1, math.Point p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double _angle(
    math.Point<double> p1,
    math.Point<double> p2,
    math.Point<double> p3,
  ) {
    final double angle =
        (math.atan2(p3.y - p2.y, p3.x - p2.x) -
                math.atan2(p1.y - p2.y, p1.x - p2.x))
            .abs();
    double degrees = angle * 180.0 / math.pi;
    if (degrees > 180.0) degrees = 360.0 - degrees;
    return degrees;
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
