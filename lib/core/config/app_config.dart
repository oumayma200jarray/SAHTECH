import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late final String host;

  static late final String apiBaseUrl;
  static late final String minioBaseUrl;

  // Global navigator key used for programmatic navigation from services
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Initialize AppConfig with values from .env file
  static Future<void> initialize() async {
    await dotenv.load();
    host = dotenv.env['HOST'] ?? '10.0.2.2';
    apiBaseUrl = 'http://$host:3000';
    minioBaseUrl = 'http://$host:9000';
  }
}
