import 'package:sahtek/core/config/app_config.dart';

import 'http_client.dart';

class EndPoint {
  // ─── Base URL ───────────────────────────────────────────────────────────────
  // static const String _baseUrl = 'http://10.0.2.2:3000';
  static final String _baseUrl = AppConfig.apiBaseUrl;
  // static const String _baseUrl = 'http://your-production-ip:3000';

  /// Single shared HTTP client instance for the whole app
  static final HttpClient client = HttpClient(baseUrl: _baseUrl);

  // ─── Auth / Users ────────────────────────────────────────────────────────────
  static const String signup = 'users/signup';
  static const String signin = 'users/signin';
  static const String signinVerify = 'users/signin/verify';
  static const String refreshToken = 'users/refresh-token';
  static const String deleteAccount = 'users/delete-account';
  static const String changePassword = 'users/change-password';
  static const String updateOtp = 'users/update-otp';
  static const String profile = 'users/profile';
  static const String whoami = 'users/whoami';
  static const String posts = 'users/posts';
  static const String publicExercises = 'users/public-exercises';
  static const String favoritePosts = 'users/favorite-posts';
  static const String updateUser = 'users/update-user';
  static const String uploadImage = 'users/upload-image';
  static const String googleMobileCallback = 'users/auth/google/mobile';
  static String deleteUser(String id) => 'users/delete/$id';
  static String validateDoctor(String id) => 'users/validate-doctor/$id';
  static String validateAdmin(String id) => 'users/validate-admin/$id';
  static String favoritePost(String postId) => 'users/favorite-posts/$postId';

  // ─── Google OAuth ─────────────────────────────────────────────────────────
  static const String googleLogin = 'users/auth/google';
  static const String googleCallback = 'users/auth/google/callback';

  // ─── OTP ─────────────────────────────────────────────────────────────────
  static const String otpSend = 'otp/send';
  static const String otpVerify = 'otp/verify';

  // ─── Specialists ────────────────────────────────────────────────────────
  static String specialists(String query) =>
      'users/specialists/${Uri.encodeComponent(query)}';
  static String specialistById(String id) =>
      'users/specialist/${Uri.encodeComponent(id)}';
  static const String myPatients = 'specialist/patients';

  // ─── Appointments ────────────────────────────────────────────────────────
  // Keep backend naming as-is (`apointment`) to match server route.
  static const String createApointment = 'users/apointment';
  static const String appointments = 'users/appointments';
  static String availableSlots(String specialistId) =>
      'users/available-slots/${Uri.encodeComponent(specialistId)}';

  // ─── Exercises ──────────────────────────────────────────────────────────
  static const String publishExercise = 'specialist/exercises';
  static const String uploadExerciseVideo = 'specialist/exercises/upload-video';
  static String patientExercises(String patientId) =>
      'specialist/exercises/$patientId';
  static const String myExercises = 'patient/exercises';

  // ─── Medical Records ────────────────────────────────────────────────────
  static String medicalRecords(String patientId) =>
      'specialist/medical-records/$patientId';
  static String uploadMedicalRecord(String patientId) =>
      'specialist/medical-records/$patientId/upload';

  // ─── Chat / Messaging ───────────────────────────────────────────────────
  static const String chatConversations = 'chat/conversations';
  static String chatMessages(String conversationId) =>
      'chat/conversations/$conversationId/messages';
  static String chatSendMessage(String conversationId) =>
      'chat/conversations/$conversationId/messages';
  static const String chatUnreadCount = 'chat/unread';
  static const String chatWebSocketNamespace = '/chat';
}
