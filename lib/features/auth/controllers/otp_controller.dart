import 'package:flutter/material.dart';
import 'package:sahtek/features/auth/services/auth_service.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/core/api/endpoint.dart';

class OtpController extends ChangeNotifier {
  bool isLoading = false;
  bool isResending = false;
  String? errorMessage;

  Future<void> verifyOtp({
    required String userId,
    required String code,
    required BuildContext context,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.verifySignIn(
        userId: userId,
        code: code,
      );

      await StorageService.saveSession(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
        userId: response['userId'],
        role: response['role'],
        imageUrl: response['imageUrl'],
      );

      // set token for all future requests
      EndPoint.client.setAuthToken(response['accessToken']);

      final savedRole = response['role']?.toString().toUpperCase() ?? '';
      final targetRoute = (savedRole == 'SPECIALIST' || savedRole == 'SPECIALISTE') 
          ? '/dashboard_specialiste' 
          : '/accueil';

      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        targetRoute,
        (route) => false,
      );
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp({
    required String userId,
    required String email, // 👈 add email
    required BuildContext context,
  }) async {
    isResending = true;
    errorMessage = null;
    notifyListeners();

    try {
      await AuthService.sendOtp(
        userId: userId,
        email: email,
        type: 'TWO_FACTOR',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New code sent successfully')),
      );
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    } finally {
      isResending = false;
      notifyListeners();
    }
  }
}