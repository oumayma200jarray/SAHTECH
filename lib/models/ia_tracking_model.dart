import 'package:flutter/material.dart';
import 'package:sahtek/models/content_model.dart';

class IATrackingData {
  final String? exerciseId;
  final String title;
  double currentValue; // Rendu mutable pour les mises à jour en direct
  final String unit; // ex: "°"
  final double objective; // ex: 180
  final double precision; // Pourcentage de confiance IA
  String guidanceText; // Rendu mutable pour les conseils dynamiques
  final List<double> angleHistory; // Pour le graphique
  final List<double> painHistory; // Historique de douleur synchronisé
  final double? painLevel; // Niveau de douleur final (0-10)
  final DateTime date;
  final List<String> sessionFrames; // Pour le Time-Lapse

  // Métriques de qualité du mouvement (pour éviter que l'IA ne valide des mouvements "tricheurs")
  double
  trunkLeanAngle; // Angle d'inclinaison du corps (le patient se penche pour tricher)
  double
  elbowFlexion; // Angle du coude (le bras doit rester tendu pour certains exercices)
  bool
  isPostureCorrect; // Flag global indiquant si le mouvement respecte la biomécanique

  IATrackingData({
    this.exerciseId,
    required this.title,
    required this.currentValue,
    required this.unit,
    required this.objective,
    required this.precision,
    required this.guidanceText,
    this.angleHistory = const [],
    this.painHistory = const [],
    this.painLevel,
    required this.date,
    this.sessionFrames = const [],
    this.trunkLeanAngle = 0.0,
    this.elbowFlexion = 180.0,
    this.isPostureCorrect = true,
  });

  /// Crée un objet de tracking à partir d'un exercice (ContentModel)
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
  );

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'title': title,
    'currentValue': currentValue,
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
    'elbowFlexion': elbowFlexion,
    'isPostureCorrect': isPostureCorrect,
  };

  factory IATrackingData.fromJson(Map<String, dynamic> json) => IATrackingData(
    exerciseId: json['exerciseId'],
    title: json['title'],
    currentValue: (json['currentValue'] as num).toDouble(),
    unit: json['unit'],
    objective: (json['objective'] as num).toDouble(),
    precision: (json['precision'] as num).toDouble(),
    guidanceText: json['guidanceText'],
    angleHistory:
        (json['angleHistory'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [],
    painHistory:
        (json['painHistory'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [],
    painLevel: json['painLevel'] != null
        ? (json['painLevel'] as num).toDouble()
        : null,
    date: DateTime.parse(json['date']),
    sessionFrames:
        (json['sessionFrames'] as List?)?.map((e) => e as String).toList() ??
        [],
    trunkLeanAngle: (json['trunkLeanAngle'] ?? 0.0).toDouble(),
    elbowFlexion: (json['elbowFlexion'] ?? 180.0).toDouble(),
    isPostureCorrect: json['isPostureCorrect'] ?? true,
  );
}
