import 'package:flutter/material.dart';
import 'package:sahtek/features/auth/services/google_auth_service.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/core/api/endpoint.dart';

class GoogleAuthController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<void> signInWithGoogle({required BuildContext context}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await GoogleAuthService.signInWithGoogle();

      if (response == null) {
        // user cancelled
        isLoading = false;
        notifyListeners();
        return;
      }

      // save tokens
      await StorageService.saveSession(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
        userId: response['userId'] ?? '',
        role: response['role'] ?? 'PATIENT',
        imageUrl: response['imageUrl'],
      );

      EndPoint.client.setAuthToken(response['accessToken']);

      if (!context.mounted) return;

      // new Google user → complete profile
      if (response['isNew'] == true) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/complete-profile',
          (route) => false,
        );
      } else {
        // existing user → go to home
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/accueil',
          (route) => false,
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