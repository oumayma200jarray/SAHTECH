import 'package:flutter/material.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/core/api/http_client.dart';
import 'package:sahtek/core/services/storage_service.dart';
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
          arguments: {'userId': response['userId'], 'email': response['email']},
        );
      }
    } catch (e) {
      if (e is ApiException && e.message == 'TOKEN_EXPIRED') {
        // try refresh token
        final refreshToken = await StorageService.getRefreshToken();
        if (refreshToken != null) {
          final response = await AuthService.refreshToken(
            refreshToken: refreshToken,
          );
          EndPoint.client.setAuthToken(response['accessToken']);
          // retry the original request
        }
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
