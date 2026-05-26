import 'package:flutter/material.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/features/auth/services/auth_service.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/core/services/push_notification_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';

class AuthInitService {
  static Future<void> checkAndRestoreSession(BuildContext context) async {
    debugPrint('🔓 AuthInitService.checkAndRestoreSession: called');
    final accessToken = await StorageService.getAccessToken();
    final refreshToken = await StorageService.getRefreshToken();

    // no tokens at all → go to login
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      debugPrint('🔓 AuthInitService: no tokens, routing to /connexion');
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

      // token is still valid → go to home or dashboard based on role
      final role = await StorageService.getRole();
      debugPrint(
        '🔓 AuthInitService: token valid, role from storage = "$role"',
      );
      final targetRoute =
          (role != null &&
              (role.toUpperCase() == 'SPECIALIST' ||
                  role.toUpperCase() == 'SPECIALISTE' ||
                  role.toUpperCase() == 'DOCTOR'))
          ? '/dashboard_specialiste'
          : '/accueil';
      debugPrint('🔓 AuthInitService: routing to $targetRoute');

      await PushNotificationService.syncStoredTokenToBackend();

      // load profile into provider if available (defer to next frame)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final provider = Provider.of<GlobalDataProvider>(
            context,
            listen: false,
          );
          await provider.loadProfile();
        } catch (_) {
          // ignore if provider not available yet
        }
      });

      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
    } catch (e) {
      // access token expired → try refresh token
      debugPrint('🔓 AuthInitService: token validation failed, error: $e');
      try {
        debugPrint('🔓 AuthInitService: attempting token refresh...');
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
        await PushNotificationService.syncStoredTokenToBackend();

        final role = (await StorageService.getRole()) ?? '';
        debugPrint('🔓 AuthInitService: token refreshed, role = "$role"');
        final targetRoute =
            (role.toUpperCase() == 'SPECIALIST' ||
                role.toUpperCase() == 'SPECIALISTE' ||
                role.toUpperCase() == 'DOCTOR')
            ? '/dashboard_specialiste'
            : '/accueil';
        debugPrint(
          '🔓 AuthInitService: routing to $targetRoute (after refresh)',
        );

        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          targetRoute,
          (route) => false,
        );
      } catch (e) {
        // refresh token also expired → clear storage and go to login
        debugPrint(
          '🔓 AuthInitService: token refresh failed, clearing session and going to /connexion. Error: $e',
        );
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
