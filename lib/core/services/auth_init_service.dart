import 'package:flutter/material.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/features/auth/services/auth_service.dart';
import 'package:sahtek/core/api/endpoint.dart';

class AuthInitService {
  static Future<void> checkAndRestoreSession(BuildContext context) async {
    final accessToken = await StorageService.getAccessToken();
    final refreshToken = await StorageService.getRefreshToken();

    // no tokens at all → go to login
    if (accessToken == null || refreshToken == null) {
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/connexion',
        (route) => false,
      );
      return;
    }

    // try to use the access token first
    // if it works great, if not try refresh
    try {
      // set the token and try to get profile
      EndPoint.client.setAuthToken(accessToken);
      await EndPoint.client.get('users/whoami');

      // token is still valid → go to home
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/accueil',
        (route) => false,
      );
    } catch (e) {
      // access token expired → try refresh token
      try {
        final response = await AuthService.refreshToken(
          refreshToken: refreshToken,
        );

        // save new access token
        await StorageService.saveSession(
          accessToken: response['accessToken'],
          refreshToken: refreshToken, // refresh token stays the same
          userId: (await StorageService.getUserId()) ?? '',
          role: (await StorageService.getRole()) ?? '',
          imageUrl: await StorageService.getImageUrl(),
        );

        // set new token in HttpClient
        EndPoint.client.setAuthToken(response['accessToken']);

        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/accueil',
          (route) => false,
        );
      } catch (e) {
        // refresh token also expired → clear storage and go to login
        await StorageService.clearSession();
        EndPoint.client.clearAuthToken();

        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/connexion',
          (route) => false,
        );
      }
    }
  }
}