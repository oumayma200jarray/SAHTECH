import 'package:sahtek/models/clinic_model.dart';

class SpecialistModel {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String licenseNumber;
  final String gender;
  final String specialty;
  final SpecialistUser? user;
  final PrimaryClinic? primaryClinic;
  final List<PrimaryClinic>? clinics;
  final String location;
  final String bio;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final double distance;
  final String availability;
  final double latitude;
  final double longitude;

  SpecialistModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.bio,
    required this.licenseNumber,
    required this.gender,
    required this.specialty,
    this.user,
    this.primaryClinic,
    this.clinics,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.distance,
    required this.availability,
    required this.latitude,
    required this.longitude,
  });

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory SpecialistModel.fromJson(Map<String, dynamic> json) {
    final specialist = json['specialist'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    print('SpecialistModel.fromJson: ${json['bio']}');
    final rawPrimaryClinic =
        specialist?['primaryClinic'] ?? json['primaryClinic'];
    final primaryClinic = (rawPrimaryClinic is Map<String, dynamic>)
        ? PrimaryClinic.fromJson(rawPrimaryClinic)
        : null;

    // parse clinics list if present
    final rawClinics = specialist?['clinics'] ?? json['clinics'];
    List<PrimaryClinic>? clinics;
    if (rawClinics is List) {
      clinics = rawClinics
          .whereType<Map<String, dynamic>>()
          .map((e) => PrimaryClinic.fromJson(e))
          .toList();
    }

    // parse nested user object
    final parsedUser = (user != null) ? SpecialistUser.fromJson(user) : null;

    return SpecialistModel(
      userId: (json['userId'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? user?['fullName'] ?? json['name'] ?? '')
          .toString(),
      gender: (json['gender'] ?? user?['gender'] ?? '').toString(),
      email: (json['email'] ?? user?['email'] ?? '').toString(),
      phone: (json['phone'] ?? user?['phone'] ?? '').toString(),
      specialty:
          (specialist?['speciality'] ??
                  specialist?['specialty'] ??
                  json['speciality'] ??
                  json['specialty'] ??
                  '')
              .toString(),
      licenseNumber: (specialist?['licenseNumber'] ?? '').toString(),
      bio: (specialist?['bio'] ?? json['bio'] ?? '').toString(),
      user: parsedUser,
      primaryClinic: primaryClinic,
      clinics: clinics,
      location: (specialist?['location'] ?? json['location'] ?? '').toString(),
      rating: _toDouble(specialist?['rating'] ?? json['rating']),
      reviewsCount: _toInt(specialist?['reviewsCount'] ?? json['reviewsCount']),
      imageUrl: (json['imageUrl'] ?? user?['imageUrl'] ?? '').toString(),
      latitude: _toDouble(specialist?['latitude'] ?? json['latitude']),
      longitude: _toDouble(specialist?['longitude'] ?? json['longitude']),
      distance: _toDouble(json['distance']),
      availability: (specialist?['availability'] ?? json['availability'] ?? '')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': location,
      'imageUrl': imageUrl,
      'specialist': {
        'speciality': specialty,
        'bio': bio,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
      },
    };
  }
}

/// Lightweight user object embedded in the specialist response.
class SpecialistUser {
  final String fullName;
  final String imageUrl;
  final String gender;
  final String email;
  final String phone;

  SpecialistUser({
    required this.fullName,
    required this.imageUrl,
    required this.gender,
    required this.email,
    required this.phone,
  });

  factory SpecialistUser.fromJson(Map<String, dynamic> json) {
    return SpecialistUser(
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}
