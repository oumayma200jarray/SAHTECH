import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late final String host;

  static late final String apiBaseUrl;
  static late final String minioBaseUrl;

  /// Initialize AppConfig with values from .env file
  static Future<void> initialize() async {
    await dotenv.load();
    host = dotenv.env['HOST'] ?? '10.0.2.2';
    apiBaseUrl = 'http://$host:4000';
    minioBaseUrl = 'http://$host:9000';
  }
}
