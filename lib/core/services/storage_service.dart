import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _accessToken = 'accessToken';
  static const _refreshToken = 'refreshToken';
  static const _userId = 'userId';
  static const _role = 'role';
  static const _imageUrl = 'imageUrl';

  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
    String? imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessToken, accessToken);
    await prefs.setString(_refreshToken, refreshToken);
    await prefs.setString(_userId, userId);
    await prefs.setString(_role, role);
    if (imageUrl != null) await prefs.setString(_imageUrl, imageUrl);
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
}