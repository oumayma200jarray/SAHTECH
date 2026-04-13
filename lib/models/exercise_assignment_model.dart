import 'dart:io';

/// Model representing an exercise assigned by a specialist to a patient.
/// Used when publishing from the "Publier Exercice" screen.
class ExerciseAssignment {
  final String? id;
  final String patientId;
  final String exerciseType; // ex: 'Squat', 'Flexion de l'épaule'
  final int duration;        // in seconds
  final int repetitions;
  final File? videoFile;     // local file picked by specialist
  final String? videoUrl;    // URL returned by backend after upload
  final DateTime? createdAt;

  ExerciseAssignment({
    this.id,
    required this.patientId,
    required this.exerciseType,
    required this.duration,
    required this.repetitions,
    this.videoFile,
    this.videoUrl,
    this.createdAt,
  });

  /// Serialize for API request (without file — file is sent via multipart)
  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'exerciseType': exerciseType,
      'duration': duration,
      'repetitions': repetitions,
    };
  }

  factory ExerciseAssignment.fromJson(Map<String, dynamic> json) {
    return ExerciseAssignment(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId'] ?? '',
      exerciseType: json['exerciseType'] ?? '',
      duration: json['duration'] ?? 0,
      repetitions: json['repetitions'] ?? 0,
      videoUrl: json['videoUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  /// Convert to ContentModel-compatible map for the patient's selection_test_ia page
  Map<String, dynamic> toContentJson() {
    return {
      'id': id ?? '',
      'title': exerciseType,
      'subtitle': '${duration}s • $repetitions reps',
      'description': 'Exercice assigné par votre spécialiste',
      'videoUrl': videoUrl,
      'duration': '${duration}s',
      'exerciseType': exerciseType,
    };
  }
}
