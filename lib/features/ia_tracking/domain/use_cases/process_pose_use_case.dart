// ignore_for_file: unused_local_variable

import 'dart:math' as math;
import 'package:sahtek/models/pose_model.dart';
import 'package:sahtek/core/utils/biomechanics_utils.dart';
import 'package:sahtek/features/ia_tracking/domain/entities/movement_result.dart';
import 'package:sahtek/features/ia_tracking/domain/use_cases/generate_remarks_use_case.dart';

class ProcessPoseUseCase {
  final GenerateRemarksUseCase _generateRemarks;
  bool? _isLeftArmActive;

  ProcessPoseUseCase(this._generateRemarks);

  MovementResult execute(Pose pose, String exerciseId, {required bool isFrontCamera}) {
    // Inversement des points si caméra frontale
    // Les points de ML Kit sont anatomiques (Left = Gauche du patient)
    // L'inversion visuelle (miroir) est gérée uniquement dans le Painter.
    final lS = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rS = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lH = pose.landmarks[PoseLandmarkType.leftHip];
    final rH = pose.landmarks[PoseLandmarkType.rightHip];
    final lE = pose.landmarks[PoseLandmarkType.leftElbow];
    final rE = pose.landmarks[PoseLandmarkType.rightElbow];
    final lW = pose.landmarks[PoseLandmarkType.leftWrist];
    final rW = pose.landmarks[PoseLandmarkType.rightWrist];

    if (lS == null || rS == null || lH == null || rH == null) {
      return _emptyResult();
    }

    final lSP = math.Point(lS.x, lS.y);
    final rSP = math.Point(rS.x, rS.y);
    final lHP = math.Point(lH.x, lH.y);
    final rHP = math.Point(rH.x, rH.y);
    final lEP = lE != null ? math.Point(lE.x, lE.y) : lSP;
    final rEP = rE != null ? math.Point(rE.x, rE.y) : rSP;
    final lWP = lW != null ? math.Point(lW.x, lW.y) : lEP;
    final rWP = rW != null ? math.Point(rW.x, rW.y) : rEP;

    // Utilisation du poignet (WP) au lieu du coude (EP) pour l'angle anatomique global
    // Cela permet d'atteindre les 180° quand le bras est complètement levé (le coude est parfois mal détecté en hauteur maximale)
    final double lAngle = BiomechanicsUtils.calculateAnatomicalAngle(lSP, lHP, lWP);
    final double rAngle = BiomechanicsUtils.calculateAnatomicalAngle(rSP, rHP, rWP);

    // 1. Initial Locking (if null)
    if (_isLeftArmActive == null) {
      if (exerciseId.contains('rotation')) {
        // En rotation, on regarde l'activité de rotation 3D pour verrouiller le premier côté
        double lRot = 0, rRot = 0;
        
        if (lE != null && lW != null) {
          final dx = lW.x - lE.x, dy = lW.y - lE.y, dz = lW.z - lE.z;
          final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
          if (dist > 0) lRot = math.acos((-dz / dist).clamp(-1.0, 1.0)) * 180 / math.pi - 10;
        }
        if (rE != null && rW != null) {
          final dx = rW.x - rE.x, dy = rW.y - rE.y, dz = rW.z - rE.z;
          final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
          if (dist > 0) rRot = math.acos((-dz / dist).clamp(-1.0, 1.0)) * 180 / math.pi - 10;
        }
        
        if (lRot > 15) _isLeftArmActive = true;
        else if (rRot > 15) _isLeftArmActive = false;
      } else {
        // Pour les autres exercices, on regarde l'élévation (anatomical angle)
        if (lAngle > 10) _isLeftArmActive = true;
        else if (rAngle > 10) _isLeftArmActive = false;
      }
    } 
    // 2. Dynamic Switching (if already locked)
    else {
      if (exerciseId.contains('rotation')) {
        double lRot = 0, rRot = 0;
        if (lE != null && lW != null) {
          final dx = lW.x - lE.x, dy = lW.y - lE.y, dz = lW.z - lE.z;
          final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
          if (dist > 0) lRot = math.acos((-dz / dist).clamp(-1.0, 1.0)) * 180 / math.pi - 10;
        }
        if (rE != null && rW != null) {
          final dx = rW.x - rE.x, dy = rW.y - rE.y, dz = rW.z - rE.z;
          final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
          if (dist > 0) rRot = math.acos((-dz / dist).clamp(-1.0, 1.0)) * 180 / math.pi - 10;
        }

        final double lockedRot = _isLeftArmActive! ? lRot : rRot;
        final double otherRot = _isLeftArmActive! ? rRot : lRot;
        // Si l'autre bras bouge plus que le bras verrouillé (avec marge de sécurité)
        if (otherRot > lockedRot + 15 && otherRot > 20) _isLeftArmActive = !_isLeftArmActive!;
      } else {
        final double lockedAngle = _isLeftArmActive! ? lAngle : rAngle;
        final double otherAngle = _isLeftArmActive! ? rAngle : lAngle;
        // Si l'autre bras monte plus haut que le bras verrouillé
        if (otherAngle > lockedAngle + 10 && otherAngle > 15) {
          _isLeftArmActive = !_isLeftArmActive!;
        }
      }
    }

    // Determine final active side for this frame
    final bool isL = _isLeftArmActive ?? (lAngle >= rAngle);

    final double trunkLean = BiomechanicsUtils.calculateTrunkLean(
      math.Point((lS.x + rS.x) / 2, (lS.y + rS.y) / 2),
      math.Point((lH.x + rH.x) / 2, (lH.y + rH.y) / 2),
    );

    final double shoulderImbalance = BiomechanicsUtils.calculateShoulderImbalance(lSP, rSP);
    
    final double elbowFlexion = isL 
        ? BiomechanicsUtils.calculateAngle2D(lSP, lEP, lWP)
        : BiomechanicsUtils.calculateAngle2D(rSP, rEP, rWP);

    double finalLeftAngle = lAngle;
    double finalRightAngle = rAngle;
    double angle = isL ? lAngle : rAngle;
    double elevationAngle = isL ? lAngle : rAngle;
    bool? isCorrectDirection;

    if (exerciseId.contains('rotation')) {
      // Calcul 2D de la rotation basé sur la proportion de distance coude-poignet
      double computeRotation2D(math.Point s, math.Point e, math.Point w, bool isInternal, bool isLeft) {
        // Distance épaule-coude pour estimer la longueur de l'avant-bras
        double L = math.sqrt((e.x - s.x) * (e.x - s.x) + (e.y - s.y) * (e.y - s.y));
        if (L < 10) L = 100.0; // Marge de sécurité
        
        // L'avant-bras représente environ 68% de la longueur de l'humérus (L)
        double L_forearm = L * 0.68;
        
        num dx_outward = isLeft ? (w.x - e.x) : (e.x - w.x);
        num dx_inward = -dx_outward;
        
        if (isInternal) {
          // Angle d'entrée vers le buste
          double ratio = (dx_inward / L_forearm).clamp(-1.0, 1.0);
          double angle = math.asin(ratio) * 180.0 / math.pi;
          return angle > 0 ? angle.clamp(0.0, 90.0) : 0.0;
        } else {
          // Angle de sortie vers l'extérieur
          double ratio = (dx_outward / L_forearm).clamp(-1.0, 1.0);
          double angle = math.asin(ratio) * 180.0 / math.pi;
          return angle > 0 ? angle.clamp(0.0, 90.0) : 0.0;
        }
      }

      bool isInternal = exerciseId.contains('rotation_interne');
      double lRot = 0.0, rRot = 0.0;
      
      if (isInternal) {
        lRot = computeRotation2D(lSP, lEP, lWP, true, true);
        rRot = computeRotation2D(rSP, rEP, rWP, true, false);
      } else {
        // Ancienne logique 3D pour la rotation externe (comme demandée par l'utilisateur)
        if (lE != null && lW != null) {
          final dx = lW.x - lE.x, dy = lW.y - lE.y, dz = lW.z - lE.z;
          final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
          if (dist > 0) lRot = math.acos((-dz / dist).clamp(-1.0, 1.0)) * 180 / math.pi - 10;
        }
        if (rE != null && rW != null) {
          final dx = rW.x - rE.x, dy = rW.y - rE.y, dz = rW.z - rE.z;
          final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
          if (dist > 0) rRot = math.acos((-dz / dist).clamp(-1.0, 1.0)) * 180 / math.pi - 10;
        }
      }
      
      finalLeftAngle = lRot.clamp(0.0, 180.0);
      finalRightAngle = rRot.clamp(0.0, 180.0);
      angle = isL ? finalLeftAngle : finalRightAngle;
      
    } else if (exerciseId.contains('adduction')) {
      // Adduction : le bras croise le buste
      // Bras gauche croise -> le coude va vers la gauche de l'écran -> lEP.x < lSP.x
      // Bras droit croise -> le coude va vers la droite de l'écran -> rEP.x > rSP.x
      isCorrectDirection = isL ? (lEP.x < lSP.x) : (rEP.x > rSP.x);
      
      if (isL) {
        finalLeftAngle = isCorrectDirection! ? lAngle : 0.0;
        angle = finalLeftAngle;
      } else {
        finalRightAngle = isCorrectDirection! ? rAngle : 0.0;
        angle = finalRightAngle;
      }
    }

    bool? isArmForward;
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final activeEar = isL
        ? pose.landmarks[PoseLandmarkType.leftEar]
        : pose.landmarks[PoseLandmarkType.rightEar];
    
    final activeShoulder = isL ? lS : rS;
    final activeElbow = isL ? lE : rE;

    if (nose != null && activeEar != null && activeShoulder != null && activeElbow != null) {
      final faceDirectionX = nose.x - activeEar.x;
      final armDirectionX = activeElbow.x - activeShoulder.x;
      if (faceDirectionX.abs() > 5 && armDirectionX.abs() > 5) {
        isArmForward = (faceDirectionX * armDirectionX) > 0;
      }
    }

    final remarks = _generateRemarks.execute(
      exerciseId: exerciseId,
      trunkLean: trunkLean,
      shoulderImbalance: shoulderImbalance,
      elbowFlexion: elbowFlexion,
      angle: angle,
      elevationAngle: elevationAngle,
      isArmForward: isArmForward,
      isCorrectDirection: isCorrectDirection,
    );

    final bool isPostureCorrect = !remarks.any((r) => r.severity == RemarkSeverity.warning);

    return MovementResult(
      angle: angle,
      leftAngle: finalLeftAngle,
      rightAngle: finalRightAngle,
      isPostureCorrect: isPostureCorrect,
      trunkLean: trunkLean,
      shoulderImbalance: shoulderImbalance,
      elbowFlexion: elbowFlexion,
      remarks: remarks,
      isLeftArmActive: isL,
    );
  }

  MovementResult _emptyResult() {
    return MovementResult(
      angle: 0,
      leftAngle: 0,
      rightAngle: 0,
      isPostureCorrect: true,
      trunkLean: 0,
      shoulderImbalance: 0,
      elbowFlexion: 180,
      remarks: [],
      isLeftArmActive: null,
    );
  }

  void resetSide() {
    _isLeftArmActive = null;
  }
}
