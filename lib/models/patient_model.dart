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
  final String? lastVisitDate;    // from appointments[0].AvailableSlot.date (ISO)

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
    final patient = json['patient'] as Map<String, dynamic>?;
    final appointments = (patient?['appointments'] as List?) ?? [];
    final firstAppt =
        appointments.isNotEmpty ? appointments[0] as Map? : null;
    final slot = firstAppt?['AvailableSlot'] as Map?;
    // age may live inside nested 'patient' or at the top level depending on the endpoint
    final rawAge = patient?['age'] ?? json['age'];
    return PatientModel(
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      age: _toInt(rawAge),
      weight: _toDouble(patient?['weight'] ?? json['weight']),
      height: _toDouble(patient?['height'] ?? json['height']),
      medicalDocument: (patient?['medicalDocuments'] as List? ?? [])
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
