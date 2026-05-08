/// Doctor Availability Slot Model
class DoctorDailySlotModel {
  final int availabilityId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;
  final String? place;

  DoctorDailySlotModel({
    required this.availabilityId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    this.place,
  });

  factory DoctorDailySlotModel.fromJson(Map<String, dynamic> json) {
    return DoctorDailySlotModel(
      availabilityId: json['availabilityId'] ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      isBooked: json['isBooked'] ?? false,
      place: json['place'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availabilityId': availabilityId,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isBooked': isBooked,
      'place': place,
    };
  }
}

/// Doctor Appointment Model (from doctor's perspective)
class DoctorAppointmentModel {
  final int appointmentId;
  final String status; // SCHEDULED, ACEPTED, REJECTED, COMPLETED, CANCELLED
  final String reason;
  final String patientName;
  final String? patientImage;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String place;

  DoctorAppointmentModel({
    required this.appointmentId,
    required this.status,
    required this.reason,
    required this.patientName,
    this.patientImage,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.place,
  });

  factory DoctorAppointmentModel.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentModel(
      appointmentId: json['appointmentId'] ?? 0,
      status: json['status'] ?? 'SCHEDULED',
      reason: json['reason'] ?? '',
      patientName: json['patientName'] ?? '',
      patientImage: json['patientImage'],
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      place: json['place'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'status': status,
      'reason': reason,
      'patientName': patientName,
      'patientImage': patientImage,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'place': place,
    };
  }
}

/// Doctor Post Model
class DoctorPostModel {
  final int postId;
  final String title;
  final String description;
  final String type; // ARTICLE, IMAGE, VIDEO
  final String? url;
  final bool isPublished;
  final DateTime createdAt;

  DoctorPostModel({
    required this.postId,
    required this.title,
    required this.description,
    required this.type,
    this.url,
    required this.isPublished,
    required this.createdAt,
  });

  factory DoctorPostModel.fromJson(Map<String, dynamic> json) {
    return DoctorPostModel(
      postId: json['postId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'ARTICLE',
      url: json['url'],
      isPublished: json['isPublished'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'title': title,
      'description': description,
      'type': type,
      'url': url,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Patient Data from Doctor perspective (for patient list)
class DoctorPatientModel {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String? imageUrl;
  final PatientDetailsModel? patientDetails;

  DoctorPatientModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    this.imageUrl,
    this.patientDetails,
  });

  factory DoctorPatientModel.fromJson(Map<String, dynamic> json) {
    return DoctorPatientModel(
      userId: (json['userId'] ?? json['id'] ?? '').toString(),
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? 'MALE',
      imageUrl: json['imageUrl'],
      patientDetails: json['patient'] != null
          ? PatientDetailsModel.fromJson(json['patient'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'imageUrl': imageUrl,
      'patient': patientDetails?.toJson(),
    };
  }
}

/// Patient Details from Doctor perspective
class PatientDetailsModel {
  final int age;
  final int? height; // in cm
  final int? weight; // in kg
  final List<MedicalHistoryItemModel> medicalHistory;
  final List<PatientAppointmentModel> appointments;

  PatientDetailsModel({
    required this.age,
    this.height,
    this.weight,
    this.medicalHistory = const [],
    this.appointments = const [],
  });

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory PatientDetailsModel.fromJson(Map<String, dynamic> json) {
    var historyList = json['medicalHistory'] as List? ?? [];
    List<MedicalHistoryItemModel> history = historyList
        .map((i) => MedicalHistoryItemModel.fromJson(i))
        .toList();

    var appointmentsList = json['appointments'] as List? ?? [];
    List<PatientAppointmentModel> appointments = appointmentsList
        .map((i) => PatientAppointmentModel.fromJson(i))
        .toList();

    return PatientDetailsModel(
      age: _toInt(json['age']),
      height: json['height'] == null ? null : _toInt(json['height']),
      weight: json['weight'] == null ? null : _toInt(json['weight']),
      medicalHistory: history,
      appointments: appointments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'height': height,
      'weight': weight,
      'medicalHistory': medicalHistory.map((e) => e.toJson()).toList(),
      'appointments': appointments.map((e) => e.toJson()).toList(),
    };
  }
}

/// Medical History Item
class MedicalHistoryItemModel {
  final String title;
  final String category; // pdf, image, video, etc.
  final String fileUrl;

  MedicalHistoryItemModel({
    required this.title,
    required this.category,
    required this.fileUrl,
  });

  factory MedicalHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryItemModel(
      title: json['title'] ?? '',
      category: json['category'] ?? 'pdf',
      fileUrl: json['fileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'category': category, 'fileUrl': fileUrl};
  }
}

/// Patient Appointment for Doctor view
class PatientAppointmentModel {
  final String reason;
  final AvailableSlotModel? availableSlot;

  PatientAppointmentModel({required this.reason, this.availableSlot});

  factory PatientAppointmentModel.fromJson(Map<String, dynamic> json) {
    return PatientAppointmentModel(
      reason: json['reason'] ?? '',
      availableSlot: json['AvailableSlot'] != null
          ? AvailableSlotModel.fromJson(json['AvailableSlot'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'reason': reason, 'AvailableSlot': availableSlot?.toJson()};
  }
}

/// Available Slot (from appointments)
class AvailableSlotModel {
  final DateTime date;
  final DateTime startTime;

  AvailableSlotModel({required this.date, required this.startTime});

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotModel(
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
    };
  }
}
