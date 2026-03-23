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
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] as Map<String, dynamic>?; // 👈 nullable

    return PatientModel(
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://i.pravatar.cc/150?u=jean',
      age: patient?['age'] ?? 0, // 👈 safe null access
      weight: (patient?['weight'] ?? 0.0).toDouble(),
      height: (patient?['height'] ?? 0.0).toDouble(),
      medicalDocument: (patient?['medicalDocuments'] as List? ?? [])
          .map((doc) => MedicalDocument.fromJson(doc))
          .toList(),
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
