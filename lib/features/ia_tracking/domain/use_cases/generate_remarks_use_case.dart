import 'package:sahtek/features/ia_tracking/domain/entities/movement_result.dart';

class GenerateRemarksUseCase {
  get shoulderImbalance => null;

  List<ClinicalRemark> execute({
    required String exerciseId,
    required double trunkLean,
    required double shoulderImbalance,
    required double elbowFlexion,
    required double angle,
    double? elevationAngle,
    bool? isArmForward,
    bool? isCorrectDirection,
  }) {
    final List<ClinicalRemark> remarks = [];

    // Direction Check
    if (isCorrectDirection == false) {
      String errMsg = "Attention, mouvement incorrect.";
      if (exerciseId.contains('rotation_externe')) {
        errMsg = "Attention, tournez votre bras vers l'extérieur.";
      } else if (exerciseId.contains('rotation_interne')) {
        errMsg = "Attention, tournez votre bras vers l'intérieur.";
      } else if (exerciseId.contains('adduction')) {
        errMsg = "Attention, ramenez le bras vers l'intérieur devant votre buste.";
      }
      remarks.add(ClinicalRemark(
        message: errMsg,
        severity: RemarkSeverity.warning,
        metricName: "Direction",
      ));
    }

    // 1. Erreurs Générales
    if (trunkLean.abs() > 15.0) {
      remarks.add(ClinicalRemark(
        message: "Attention, votre buste penche. Gardez le dos droit.",
        severity: RemarkSeverity.warning,
        metricName: "Buste",
      ));
    }

    if (shoulderImbalance > 12.0) {
      remarks.add(const ClinicalRemark(
        message: "Attention, gardez vos épaules bien horizontales et équilibrées.",
        severity: RemarkSeverity.warning,
        metricName: "Épaules",
      ));
    }

    // 2. Erreurs Spécifiques par Exercice
    if (exerciseId.contains('flexion')) {
      if (shoulderImbalance > 15.0) {
        remarks.add(const ClinicalRemark(message: "Gardez l'épaule détendue et continuez de lever le bras.", severity: RemarkSeverity.warning, metricName: "Épaules"));
      }
      if (trunkLean < -10.0) {
        remarks.add(const ClinicalRemark(message: "Attention, ne cambrez pas le dos vers l'arrière.", severity: RemarkSeverity.warning));
      }
      if (isArmForward == false && angle > 15.0) {
        remarks.add(const ClinicalRemark(message: "Attention, vous levez le bras vers l'arrière. Gardez-le vers l'avant.", severity: RemarkSeverity.warning));
      }
    } else if (exerciseId.contains('abduction')) {
      if (shoulderImbalance > 15.0) {
        remarks.add(const ClinicalRemark(message: "Gardez votre épaule bien basse et continuez de monter le bras.", severity: RemarkSeverity.warning, metricName: "Épaules"));
      }
      if (trunkLean.abs() > 10.0) {
        remarks.add(const ClinicalRemark(message: "Attention, ne penchez pas votre corps sur le côté.", severity: RemarkSeverity.warning));
      }
    } else if (exerciseId.contains('extension')) {
      if (trunkLean > 10.0) {
        remarks.add(const ClinicalRemark(message: "Attention, ne penchez pas le tronc vers l'avant.", severity: RemarkSeverity.warning));
      }
    } else if (exerciseId.contains('adduction')) {
      if (shoulderImbalance > 15.0) {
        remarks.add(const ClinicalRemark(message: "Attention, gardez vos épaules bien horizontales.", severity: RemarkSeverity.warning));
      }
      if (trunkLean.abs() > 10.0) {
        remarks.add(const ClinicalRemark(message: "Attention, ne basculez pas le corps pour ramener le bras.", severity: RemarkSeverity.warning));
      }
    } else if (exerciseId.contains('rotation')) {
      if (trunkLean.abs() > 10.0) {
        remarks.add(const ClinicalRemark(message: "Attention, gardez votre buste bien droit.", severity: RemarkSeverity.warning));
      }
      
      // Rotation-specific: Elbow must be tucked (Angle should be small)
      // and flexion must be ~90 degrees
      if (elbowFlexion > 110 || elbowFlexion < 70) {
        remarks.add(const ClinicalRemark(message: "Attention, pliez bien le coude à 90 degrés.", severity: RemarkSeverity.warning));
      }
      
      // If elevation/abduction is too high during rotation
      final double elevation = elevationAngle ?? 0.0;
      if (elevation > 25.0) {
        remarks.add(const ClinicalRemark(message: "Attention, gardez votre coude bien collé au corps.", severity: RemarkSeverity.warning));
      }
    }

    return remarks;
  }
}
