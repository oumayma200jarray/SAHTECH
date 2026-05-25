List<String> _toStringList(dynamic val) {
  if (val == null) return [];
  if (val is List) return val.map((e) => e.toString()).toList();
  return [val.toString()];
}

class AssignedPatientUser {
  final String fullName;
  final String? imageUrl;

  const AssignedPatientUser({required this.fullName, this.imageUrl});

  factory AssignedPatientUser.fromJson(Map<String, dynamic> json) =>
      AssignedPatientUser(
        fullName: json['fullName'] ?? '',
        imageUrl: json['imageUrl'],
      );
}

class AssignedPatient {
  final String userId;
  final AssignedPatientUser user;

  const AssignedPatient({required this.userId, required this.user});

  factory AssignedPatient.fromJson(Map<String, dynamic> json) =>
      AssignedPatient(
        userId: json['userId'] ?? '',
        user: AssignedPatientUser.fromJson(
          (json['user'] as Map<String, dynamic>?) ?? {},
        ),
      );
}

class ExerciseSpecialistUser {
  final String fullName;
  final String? imageUrl;

  const ExerciseSpecialistUser({required this.fullName, this.imageUrl});

  factory ExerciseSpecialistUser.fromJson(Map<String, dynamic> json) =>
      ExerciseSpecialistUser(
        fullName: json['fullName'] ?? '',
        imageUrl: json['imageUrl'],
      );
}

class ExerciseSpecialist {
  final ExerciseSpecialistUser? user;

  const ExerciseSpecialist({this.user});

  factory ExerciseSpecialist.fromJson(Map<String, dynamic> json) =>
      ExerciseSpecialist(
        user: json['user'] != null
            ? ExerciseSpecialistUser.fromJson(
                json['user'] as Map<String, dynamic>,
              )
            : null,
      );
}

class ExerciseModel {
  final String exerciseId;
  final String name;
  final String? description;
  final String? videoUrl;
  final bool isPublic;
  final List<String> category;
  final List<String> side;
  final List<AssignedPatient> assignedTo;
  final ExerciseSpecialist? specialist;

  const ExerciseModel({
    required this.exerciseId,
    required this.name,
    this.description,
    this.videoUrl,
    required this.isPublic,
    required this.category,
    required this.side,
    required this.assignedTo,
    this.specialist,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
    exerciseId:
        json['exerciseId']?.toString() ?? json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    description: json['description'],
    videoUrl: json['videoUrl'],
    isPublic: json['isPublic'] == true,
    category: _toStringList(json['category']),
    side: _toStringList(json['side']),
    assignedTo:
        (json['assignedTo'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(AssignedPatient.fromJson)
            .toList() ??
        [],
    specialist: json['specialist'] != null
        ? ExerciseSpecialist.fromJson(
            json['specialist'] as Map<String, dynamic>,
          )
        : null,
  );
}
