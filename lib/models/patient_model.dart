import 'package:sahtek/models/medical_document_model.dart';

class PatientModel {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final double weight;
  final double height;
  final List<MedicalDocument> medicalDocument;
  final String imageUrl;

  PatientModel({
    required this.userId,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.weight,
    required this.height,
    required this.medicalDocument,
    required this.imageUrl,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      age: json["patient"]['age'] ?? 0,
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      weight: (json["patient"]['weight'] ?? 0.0).toDouble(),
      height: (json["patient"]['height'] ?? 0.0).toDouble(),
      medicalDocument: (json["patient"]['medicalDocument'] ?? []).map((doc) => MedicalDocument.fromJson(doc)).toList(),
      imageUrl: json['imageUrl'] ?? 'https://i.pravatar.cc/150?u=jean',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'age': age,
      'phone': phone,
      'weight': weight,
      'height': height,
      'medicalDocument': medicalDocument,
      'imageUrl': imageUrl,
    };
  }

  PatientModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    double? weight,
    double? height,
    List<MedicalDocument>? medicalDocument,
    String? imageUrl,
  }) {
    return PatientModel(
      userId: userId,
      age: age ,
      gender: gender ,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
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
