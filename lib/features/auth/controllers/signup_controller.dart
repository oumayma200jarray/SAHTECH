import 'package:flutter/material.dart';
import 'package:sahtek/features/auth/services/signup_service.dart';
import 'package:sahtek/features/auth/services/auth_service.dart';

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
    String? clinic,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. create the account
      await SignupService.signup(
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
        clinic: clinic,
        location: location,
        latitude: latitude,
        longitude: longitude,
      );

      // 2. automatically signin to trigger OTP
      final signinResponse = await AuthService.signIn(
        email: email,
        password: password,
      );

      if (!context.mounted) return;

      // 3. navigate to OTP page
      Navigator.pushNamed(
        context,
        '/otp-verification',
        arguments: {
          'userId': signinResponse['userId'],
          'email': signinResponse['email'],
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