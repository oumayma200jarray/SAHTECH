import 'http_client.dart';

class EndPoint {
  // ─── Base URL ───────────────────────────────────────────────────────────────
  static const String _baseUrl = 'http://10.0.2.2:3000';
  // static const String _baseUrl = 'http://your-production-ip:3000';

  /// Single shared HTTP client instance for the whole app
  static final HttpClient client = HttpClient(baseUrl: _baseUrl);

  // ─── Auth / Users ────────────────────────────────────────────────────────────
  static const String signup           = 'users/signup';
  static const String signin           = 'users/signin';
  static const String signinVerify     = 'users/signin/verify';
  static const String refreshToken     = 'users/refresh-token';
  static const String profile          = 'users/profile';
  static const String whoami           = 'users/whoami';
  static const String updateUser       = 'users/update-user';
  static const String uploadImage = 'users/upload-image';
  static String deleteUser(String id)       => 'users/delete/$id';
  static String validateDoctor(String id)   => 'users/validate-doctor/$id';
  static String validateAdmin(String id)    => 'users/validate-admin/$id';

  // ─── Google OAuth ─────────────────────────────────────────────────────────
  static const String googleLogin      = 'users/auth/google';
  static const String googleCallback   = 'users/auth/google/callback';

  // ─── OTP ─────────────────────────────────────────────────────────────────
  static const String otpSend          = 'otp/send';
  static const String otpVerify        = 'otp/verify';
}