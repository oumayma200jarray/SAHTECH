import 'package:sahtek/core/api/endpoint.dart';

class SignupService {
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String gender,
    required String address,
    required String role,
    // patient fields
    String? age,
    double? weight,
    double? height,
    // doctor fields
    String? speciality,
    String? bio,
    String? licenseNumber,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? clinicIds,
    String? primaryClinicId,
  }) async {
    final Map<String, dynamic> body = {
      'fullName': fullName,
      'email': email,
      'password': password,
      'phone': phone,
      'gender': gender,
      'address': address,
      'role': role,
    };

    if (role == 'PATIENT') {
      if (age != null) body['age'] = age;
      if (weight != null) body['weight'] = weight;
      if (height != null) body['height'] = height;
    }

    if (role == 'DOCTOR') {
      if (speciality != null) body['speciality'] = speciality;
      if (bio != null) body['bio'] = bio;
      if (licenseNumber != null) body['licenseNumber'] = licenseNumber;
      if (location != null) body['location'] = location;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (clinicIds != null && clinicIds.isNotEmpty) {
        body['clinicIds'] = clinicIds;
      }
      if (primaryClinicId != null && primaryClinicId.isNotEmpty) {
        body['primaryClinicId'] = primaryClinicId;
      }
    }

    return await EndPoint.client.post(
      EndPoint.signup,
      body: body,
      requiresAuth: false,
    );
  }
}
