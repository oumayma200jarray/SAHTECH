class UrlHelper {
  static String fixImageUrl(String? url) {
    print('Fixing URL: $url'); // Debug log
    if (url == null || url.isEmpty) return '';
    return url.replaceAll('localhost', '10.0.2.2');
  }
}
