class PatientExerciseInfo {
  final String exerciseId;
  final String name;
  final String? description;
  final String? videoUrl;
  final String? category;
  final String? side;

  const PatientExerciseInfo({
    required this.exerciseId,
    required this.name,
    this.description,
    this.videoUrl,
    this.category,
    this.side,
  });

  factory PatientExerciseInfo.fromJson(Map<String, dynamic> json) =>
      PatientExerciseInfo(
        exerciseId: json['exerciseId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        videoUrl: json['videoUrl']?.toString(),
        category: json['category']?.toString(),
        side: json['side']?.toString(),
      );
}

class PatientAssignment {
  final String assignmentId;
  final int repetitions;
  final int series;
  final int seancesParJour;
  final String? frequence;
  final String? consignesDouleur;
  final String? notes;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final PatientExerciseInfo exercise;

  const PatientAssignment({
    required this.assignmentId,
    required this.repetitions,
    required this.series,
    required this.seancesParJour,
    this.frequence,
    this.consignesDouleur,
    this.notes,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    required this.exercise,
  });

  factory PatientAssignment.fromJson(Map<String, dynamic> json) =>
      PatientAssignment(
        assignmentId: json['assignmentId']?.toString() ?? '',
        repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
        series: (json['series'] as num?)?.toInt() ?? 0,
        seancesParJour: (json['seancesParJour'] as num?)?.toInt() ?? 1,
        frequence: json['frequence']?.toString(),
        consignesDouleur: json['consignesDouleur']?.toString(),
        notes: json['notes']?.toString(),
        isCompleted: json['isCompleted'] == true,
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'].toString())
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        exercise: PatientExerciseInfo.fromJson(
          (json['exercise'] as Map<String, dynamic>?) ?? {},
        ),
      );

  PatientAssignment copyWith({bool? isCompleted, DateTime? completedAt}) =>
      PatientAssignment(
        assignmentId: assignmentId,
        repetitions: repetitions,
        series: series,
        seancesParJour: seancesParJour,
        frequence: frequence,
        consignesDouleur: consignesDouleur,
        notes: notes,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt,
        exercise: exercise,
      );
}
