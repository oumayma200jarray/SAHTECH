import 'package:sahtek/core/config/app_config.dart';

class UrlHelper {
  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return url
        .replaceAll('localhost', AppConfig.host)
        .replaceAll('10.0.2.2', AppConfig.host);
  }
}
