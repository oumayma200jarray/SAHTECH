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

      final requires2FA = response['require2FA'] == true;
      await StorageService.setRequires2FA(requires2FA);

      if (requires2FA) {
        // navigate to OTP page with userId
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {'userId': response['userId'], 'email': response['email']},
        );
      } else {
        await StorageService.saveSession(
          accessToken: response['accessToken'],
          refreshToken: response['refreshToken'],
          userId: response['userId'],
          role: response['role'],
          imageUrl: response['imageUrl'],
        );

        EndPoint.client.setAuthToken(response['accessToken']);

        final savedRole = response['role']?.toString().toUpperCase() ?? '';
        final targetRoute =
            (savedRole == 'SPECIALIST' || savedRole == 'SPECIALISTE')
            ? '/dashboard_specialiste'
            : '/accueil';

        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          targetRoute,
          (route) => false,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        if (e.message == 'TOKEN_EXPIRED') {
          // try refresh token
          final refreshToken = await StorageService.getRefreshToken();
          if (refreshToken != null) {
            final response = await AuthService.refreshToken(
              refreshToken: refreshToken,
            );
            EndPoint.client.setAuthToken(response['accessToken']);
            // retry the original request
          }
        } else {
          // Set error message to display on UI (Invalid credentials, etc.)
          errorMessage = e.message;
        }
      } else {
        // Handle unexpected errors
        errorMessage = 'An unexpected error occurred. Please try again.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
