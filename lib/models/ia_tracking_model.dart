import 'package:flutter/material.dart';
import 'package:sahtek/models/content_model.dart';

enum CameraView { front, profile, back }

class IATrackingData {
  final String? exerciseId;
  final String title;
  double currentValue;
  double leftValue;
  double rightValue;
  final String unit;
  final double objective;
  double precision;
  String guidanceText;
  final List<double> angleHistory;
  final List<double> painHistory;
  final double? painLevel;
  final DateTime date;
  final List<String> sessionFrames;
  String? aiSummary;
  CameraView selectedView;

  // Métriques de qualité
  double trunkLeanAngle;
  double signedTrunkLean;
  double elbowFlexion;
  bool isPostureCorrect;
  double shoulderImbalance;
  double avgShoulderImbalance;
  
  // Stats de session
  int repetitionCount;
  int totalRepsPlanned;
  double avgTrunkLean;
  double maxTrunkLean;
  double minElbowFlexion;

  final List<String> remarks;
  final bool isHealthy;
  final String side;

  IATrackingData({
    this.exerciseId,
    required this.title,
    required this.currentValue,
    this.leftValue = 0.0,
    this.rightValue = 0.0,
    required this.unit,
    required this.objective,
    this.precision = 0.0,
    this.guidanceText = '',
    this.angleHistory = const [],
    this.painHistory = const [],
    this.painLevel,
    required this.date,
    this.sessionFrames = const [],
    this.trunkLeanAngle = 0.0,
    this.signedTrunkLean = 0.0,
    this.elbowFlexion = 180.0,
    this.isPostureCorrect = true,
    this.aiSummary,
    this.shoulderImbalance = 0.0,
    this.repetitionCount = 0,
    this.totalRepsPlanned = 10,
    this.avgTrunkLean = 0.0,
    this.maxTrunkLean = 0.0,
    this.minElbowFlexion = 180.0,
    this.avgShoulderImbalance = 0.0,
    this.selectedView = CameraView.front,
    this.remarks = const [],
    this.isHealthy = false,
    this.side = "Gauche",
  });

  factory IATrackingData.fromContent(ContentModel content) => IATrackingData(
    exerciseId: content.id,
    title: content.title.toUpperCase(),
    currentValue: 0.0,
    unit: '°',
    objective: content.id.contains('rotation') ? 90.0 : 180.0,
    precision: 0.0,
    guidanceText: 'Prêt à commencer',
    date: DateTime.now(),
    sessionFrames: [],
    selectedView: content.id.contains('flexion')
        ? CameraView.profile
        : CameraView.front,
  );

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'title': title,
    'currentValue': currentValue,
    'leftValue': leftValue,
    'rightValue': rightValue,
    'unit': unit,
    'objective': objective,
    'precision': precision,
    'guidanceText': guidanceText,
    'angleHistory': angleHistory,
    'painHistory': painHistory,
    'painLevel': painLevel,
    'date': date.toIso8601String(),
    'sessionFrames': sessionFrames,
    'trunkLeanAngle': trunkLeanAngle,
    'signedTrunkLean': signedTrunkLean,
    'elbowFlexion': elbowFlexion,
    'isPostureCorrect': isPostureCorrect,
    'aiSummary': aiSummary,
    'shoulderImbalance': shoulderImbalance,
    'repetitionCount': repetitionCount,
    'totalRepsPlanned': totalRepsPlanned,
    'avgTrunkLean': avgTrunkLean,
    'maxTrunkLean': maxTrunkLean,
    'minElbowFlexion': minElbowFlexion,
    'avgShoulderImbalance': avgShoulderImbalance,
    'selectedView': selectedView.index,
    'isHealthy': isHealthy,
    'side': side,
    'remarks': remarks,
  };

  factory IATrackingData.fromJson(Map<String, dynamic> json) => IATrackingData(
    exerciseId: json['exerciseId'],
    title: json['title'],
    currentValue: (json['currentValue'] as num).toDouble(),
    leftValue: (json['leftValue'] ?? 0.0).toDouble(),
    rightValue: (json['rightValue'] ?? 0.0).toDouble(),
    unit: json['unit'],
    objective: (json['objective'] as num).toDouble(),
    precision: (json['precision'] as num?)?.toDouble() ?? 0.0,
    guidanceText: json['guidanceText'] ?? '',
    angleHistory: (json['angleHistory'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? <double>[],
    painHistory: (json['painHistory'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? <double>[],
    painLevel: json['painLevel'] != null ? (json['painLevel'] as num).toDouble() : null,
    date: DateTime.parse(json['date']),
    sessionFrames: (json['sessionFrames'] as List?)?.map((e) => e as String).toList() ?? <String>[],
    trunkLeanAngle: (json['trunkLeanAngle'] ?? 0.0).toDouble(),
    signedTrunkLean: (json['signedTrunkLean'] ?? 0.0).toDouble(),
    elbowFlexion: (json['elbowFlexion'] ?? 180.0).toDouble(),
    isPostureCorrect: json['isPostureCorrect'] ?? true,
    aiSummary: json['aiSummary'],
    shoulderImbalance: (json['shoulderImbalance'] ?? 0.0).toDouble(),
    repetitionCount: json['repetitionCount'] ?? 0,
    totalRepsPlanned: json['totalRepsPlanned'] ?? 10,
    avgTrunkLean: (json['avgTrunkLean'] ?? 0.0).toDouble(),
    maxTrunkLean: (json['maxTrunkLean'] ?? 0.0).toDouble(),
    minElbowFlexion: (json['minElbowFlexion'] ?? 180.0).toDouble(),
    avgShoulderImbalance: (json['avgShoulderImbalance'] ?? 0.0).toDouble(),
    selectedView: CameraView.values[json['selectedView'] ?? 0],
    isHealthy: json['isHealthy'] ?? false,
    side: json['side'] ?? "Gauche",
    remarks: (json['remarks'] as List?)?.map((e) => e as String).toList() ?? <String>[],
  );
}
