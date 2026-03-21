import 'package:flutter/material.dart';
import 'package:sahtek/features/auth/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.signIn(
        email: email,
        password: password,
      );

      if (response['require2FA'] == true) {
        // navigate to OTP page with userId
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {
            'userId': response['userId'],
            'email': response['email'],
          },
        );
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
