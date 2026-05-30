import 'package:sahtek/models/medical_document_model.dart';

class PatientModel {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final int age;
  final String gender;
  final double weight;
  final double height;
  final List<MedicalDocument> medicalDocument;
  final String imageUrl;
  final String? primaryCondition; // from appointments[0].reason
  final String? lastVisitDate; // from appointments[0].AvailableSlot.date (ISO)

  PatientModel({
    required this.userId,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.address,
    required this.weight,
    required this.height,
    required this.medicalDocument,
    required this.imageUrl,
    this.primaryCondition,
    this.lastVisitDate,
  });

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? patient = (json['patient'] is Map)
        ? (json['patient'] as Map<String, dynamic>)
        : null;

    // Some endpoints return nested patient data, others return flat objects.
    // We try multiple fallbacks for each field to be resilient to API shape changes.
    final appointments =
        ((patient?['appointments'] ?? json['appointments']) as List?) ?? [];
    final firstAppt = appointments.isNotEmpty
        ? (appointments[0] as Map?)
        : null;
    final slot = (firstAppt != null && firstAppt['AvailableSlot'] is Map)
        ? (firstAppt['AvailableSlot'] as Map?)
        : null;

    // age may live inside nested 'patient' or at the top level depending on the endpoint
    final rawAge = patient?['age'] ?? json['age'];

    // Resolve fields with fallbacks
    final resolvedUserId =
        json['userId'] ??
        json['id'] ??
        patient?['userId'] ??
        patient?['id'] ??
        '';
    final resolvedFullName =
        patient?['fullName'] ??
        patient?['name'] ??
        json['fullName'] ??
        json['name'] ??
        '';
    final resolvedEmail = patient?['email'] ?? json['email'] ?? '';
    final resolvedPhone = patient?['phone'] ?? json['phone'] ?? '';
    final resolvedAddress = patient?['address'] ?? json['address'] ?? '';
    final resolvedGender = patient?['gender'] ?? json['gender'] ?? '';
    final resolvedImage =
        patient?['imageUrl'] ??
        json['imageUrl'] ??
        patient?['avatar'] ??
        json['avatar'] ??
        '';

    // medical documents can be under patient or at top-level
    final rawMedicalDocuments =
        (patient?['medicalDocuments'] ?? json['medicalDocuments']) as List? ??
        [];

    return PatientModel(
      userId: resolvedUserId.toString(),
      fullName: resolvedFullName.toString(),
      email: resolvedEmail.toString(),
      phone: resolvedPhone.toString(),
      address: resolvedAddress.toString(),
      gender: resolvedGender.toString(),
      imageUrl: resolvedImage.toString(),
      age: _toInt(rawAge),
      weight: _toDouble(patient?['weight'] ?? json['weight']),
      height: _toDouble(patient?['height'] ?? json['height']),
      medicalDocument: rawMedicalDocuments
          .whereType<Map<String, dynamic>>()
          .map((doc) => MedicalDocument.fromJson(doc))
          .toList(),
      primaryCondition: firstAppt?['reason']?.toString(),
      lastVisitDate: slot?['date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address, // 👈 add this - required by DTO
      'age': age.toString(), // 👈 DTO expects string not int
      'weight': weight,
      'height': height,
      // remove imageUrl - not in DTO, has its own endpoint
    };
  }

  PatientModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    int? age,
    double? weight,
    double? height,
    List<MedicalDocument>? medicalDocument,
    String? imageUrl,
  }) {
    return PatientModel(
      userId: userId,
      age: age ?? this.age,
      gender: gender,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      medicalDocument: medicalDocument ?? this.medicalDocument,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory PatientModel.empty() {
    return PatientModel(
      userId: '',
      age: 0,
      gender: '',
      fullName: '',
      email: '',
      phone: '',
      address: '',
      weight: 0.0,
      height: 0.0,
      medicalDocument: [
        MedicalDocument(
          id: '',
          title: '',
          date: DateTime.now(),
          type: DocumentType.pdf,
          category: '',
          fileUrl: '',
        ),
      ],
      imageUrl: 'https://i.pravatar.cc/150?u=jean',
    );
  }
}
