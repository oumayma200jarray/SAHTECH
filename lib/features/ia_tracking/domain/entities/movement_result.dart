import 'package:flutter/foundation.dart';

enum RemarkSeverity { info, warning, success }

class ClinicalRemark {
  final String message;
  final RemarkSeverity severity;
  final String? metricName;

  const ClinicalRemark({
    required this.message,
    required this.severity,
    this.metricName,
  });
}

class MovementResult {
  final double angle;
  final double leftAngle;
  final double rightAngle;
  final bool isPostureCorrect;
  final double trunkLean;
  final double shoulderImbalance;
  final double elbowFlexion;
  final List<ClinicalRemark> remarks;
  final bool? isLeftArmActive;

  const MovementResult({
    required this.angle,
    required this.leftAngle,
    required this.rightAngle,
    required this.isPostureCorrect,
    required this.trunkLean,
    required this.shoulderImbalance,
    required this.elbowFlexion,
    required this.remarks,
    this.isLeftArmActive,
  });

  factory MovementResult.initial() => const MovementResult(
        angle: 0.0,
        leftAngle: 0.0,
        rightAngle: 0.0,
        isPostureCorrect: true,
        trunkLean: 0.0,
        shoulderImbalance: 0.0,
        elbowFlexion: 180.0,
        remarks: [],
        isLeftArmActive: null,
      );

  MovementResult copyWith({
    double? angle,
    double? leftAngle,
    double? rightAngle,
    bool? isPostureCorrect,
    double? trunkLean,
    double? shoulderImbalance,
    double? elbowFlexion,
    List<ClinicalRemark>? remarks,
    bool? isLeftArmActive,
  }) {
    return MovementResult(
      angle: angle ?? this.angle,
      leftAngle: leftAngle ?? this.leftAngle,
      rightAngle: rightAngle ?? this.rightAngle,
      isPostureCorrect: isPostureCorrect ?? this.isPostureCorrect,
      trunkLean: trunkLean ?? this.trunkLean,
      shoulderImbalance: shoulderImbalance ?? this.shoulderImbalance,
      elbowFlexion: elbowFlexion ?? this.elbowFlexion,
      remarks: remarks ?? this.remarks,
      isLeftArmActive: isLeftArmActive ?? this.isLeftArmActive,
    );
  }
}
