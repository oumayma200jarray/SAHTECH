import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _accessToken = 'accessToken';
  static const _refreshToken = 'refreshToken';
  static const _userId = 'userId';
  static const _role = 'role';
  static const _imageUrl = 'imageUrl';
  static const _needsProfileCompletion = 'needsProfileCompletion';
  static const _requires2FA = 'requires2FA';
  static const _fcmToken = 'fcmToken';

  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
    String? imageUrl,
  }) async {
    debugPrint('💾 StorageService.saveSession: saving role = "$role"');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessToken, accessToken);
    await prefs.setString(_refreshToken, refreshToken);
    await prefs.setString(_userId, userId);
    await prefs.setString(_role, role);
    if (imageUrl != null) await prefs.setString(_imageUrl, imageUrl);
    final saved = await prefs.getString(_role);
    debugPrint(
      '💾 StorageService.saveSession: verified stored role = "$saved"',
    );
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshToken);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userId);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_role);
  }

  static Future<String?> getImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_imageUrl);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> setNeedsProfileCompletion(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_needsProfileCompletion, value);
  }

  static Future<bool> getNeedsProfileCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_needsProfileCompletion) ?? false;
  }

  static Future<void> setRequires2FA(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_requires2FA, value);
  }

  static Future<bool> getRequires2FA() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_requires2FA) ?? false;
  }

  static Future<void> setFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmToken, token);
  }

  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmToken);
  }
}
