import 'package:flutter/material.dart';
import 'package:sahtek/features/auth/services/signup_service.dart';

class SignupController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String selectedRole = 'PATIENT';
  String selectedGender = 'MALE';

  void setRole(String role) {
    selectedRole = role;
    notifyListeners();
  }

  void setGender(String gender) {
    selectedGender = gender;
    notifyListeners();
  }

  Future<void> signup({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required BuildContext context,
    // patient
    String? age,
    double? weight,
    double? height,
    // doctor
    String? speciality,
    String? bio,
    String? licenseNumber,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? clinicIds,
    String? primaryClinicId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final signupResponse = await SignupService.signup(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        gender: selectedGender,
        address: address,
        role: selectedRole,
        age: age,
        weight: weight,
        height: height,
        speciality: speciality,
        bio: bio,
        licenseNumber: licenseNumber,
        location: location,
        latitude: latitude,
        longitude: longitude,
        clinicIds: clinicIds,
        primaryClinicId: primaryClinicId,
      );

      if (!context.mounted) return;

      Navigator.pushNamed(
        context,
        '/otp-verification',
        arguments: {
          'userId': signupResponse['userId'] ?? signupResponse['id'],
          'email': signupResponse['email'] ?? email,
          'type': 'EMAIL_VERIFICATION',
        },
      );
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
