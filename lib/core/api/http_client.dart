import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/core/config/app_config.dart';
import 'package:sahtek/core/api/endpoint.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {this.statusCode = 500});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class HttpClient {
  final String baseUrl;
  final int timeoutDuration;
  String? _authToken;
  bool _isRefreshing = false;

  HttpClient({required this.baseUrl, this.timeoutDuration = 15});

  // ─── Token management ──────────────────────────────────────────────────────

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // ─── Internal helpers ──────────────────────────────────────────────────────

  Map<String, String> _getHeaders({bool requiresAuth = true}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  String _buildUrl(String endpoint) {
    if (endpoint.startsWith('http')) return endpoint;
    final safeEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$baseUrl$safeEndpoint';
  }

  // ─── Token refresh ─────────────────────────────────────────────────────────

  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null) {
        _isRefreshing = false;
        return false;
      }

      final url = Uri.parse(_buildUrl('users/refresh-token'));
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(Duration(seconds: timeoutDuration));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];

        // save new token to storage
        await prefs.setString('accessToken', newAccessToken);

        // update token in HttpClient
        _authToken = newAccessToken;

        _isRefreshing = false;
        return true;
      }

      _isRefreshing = false;
      return false;
    } catch (e) {
      _isRefreshing = false;
      return false;
    }
  }

  // ─── Response processing ───────────────────────────────────────────────────

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;

    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else if (statusCode == 401) {
      throw ApiException('TOKEN_EXPIRED', statusCode: 401);
    } else if (statusCode == 403) {
      throw ApiException('Forbidden: Access denied', statusCode: statusCode);
    } else if (statusCode == 404) {
      throw ApiException('Not found', statusCode: statusCode);
    } else if (statusCode == 409) {
      // Specific handling for 409 conflicts coming from the server
      String errorMessage = 'Conflict';
      if (body != null && body is Map && body.containsKey('message')) {
        errorMessage = body['message'];
      }

      // If the server indicates the user is not found, we want to force a logout
      // and route the app to the initial auth chooser. This is a global action
      // so we use the AppConfig.navigatorKey to navigate without a BuildContext.
      try {
        if (errorMessage.toString().toLowerCase().contains('user not found')) {
          // Clear local session and tokens
          // Importing StorageService and AppConfig at top of file
          StorageService.clearSession();
          // Ensure HttpClient auth token cleared
          EndPoint.client.clearAuthToken();

          // Navigate to the initial page (chooser) and clear navigation stack
          AppConfig.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        }
      } catch (e) {
        // ignore navigation errors — we'll still throw the ApiException below
      }

      throw ApiException(errorMessage, statusCode: statusCode);
    } else {
      String errorMessage = 'Unexpected server error';
      if (body != null && body is Map && body.containsKey('message')) {
        errorMessage = body['message'];
      }
      throw ApiException(errorMessage, statusCode: statusCode);
    }
  }

  // ─── Request with auto retry ───────────────────────────────────────────────

  Future<dynamic> _executeWithRetry({
    required Future<http.Response> Function() request,
    required bool requiresAuth,
  }) async {
    try {
      final response = await request();
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401 && requiresAuth) {
        // try to refresh token
        final refreshed = await _refreshToken();

        if (refreshed) {
          // retry the same request with new token
          final response = await request();
          return _processResponse(response);
        } else {
          // refresh failed — session expired, force logout
          throw ApiException('SESSION_EXPIRED', statusCode: 401);
        }
      }
      rethrow;
    }
  }

  // ─── CRUD Operations ───────────────────────────────────────────────────────

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse(_buildUrl(endpoint));
    debugPrint('🌐 GET: $url');
    return _executeWithRetry(
      requiresAuth: requiresAuth,
      request: () => http
          .get(url, headers: _getHeaders(requiresAuth: requiresAuth))
          .timeout(Duration(seconds: timeoutDuration)),
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    debugPrint('🌐 POST: $url');
    return _executeWithRetry(
      requiresAuth: requiresAuth,
      request: () => http
          .post(
            url,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: timeoutDuration)),
    );
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    debugPrint('🌐 PATCH: $url');
    return _executeWithRetry(
      requiresAuth: requiresAuth,
      request: () => http
          .patch(
            url,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: timeoutDuration)),
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    debugPrint('🌐 PUT: $url');
    return _executeWithRetry(
      requiresAuth: requiresAuth,
      request: () => http
          .put(
            url,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: timeoutDuration)),
    );
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse(_buildUrl(endpoint));
    debugPrint('🌐 DELETE: $url');
    return _executeWithRetry(
      requiresAuth: requiresAuth,
      request: () => http
          .delete(url, headers: _getHeaders(requiresAuth: requiresAuth))
          .timeout(Duration(seconds: timeoutDuration)),
    );
  }

  Future<dynamic> uploadFile(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? fields,
    bool requiresAuth = true,
    int? uploadTimeoutSeconds,
  }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    debugPrint('🌐 UPLOAD: $url');
    final effectiveTimeout = uploadTimeoutSeconds ?? 120;

    Future<http.Response> makeRequest() async {
      final request = http.MultipartRequest('POST', url);
      if (requiresAuth && _authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      if (fields != null) request.fields.addAll(fields);

      final extension = file.path.split('.').last.toLowerCase();
      final mimeTypes = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'webp': 'image/webp',
        'heic': 'image/heic',
        'gif': 'image/gif',
        'mp4': 'video/mp4',
        'mov': 'video/quicktime',
        'avi': 'video/x-msvideo',
        'mkv': 'video/x-matroska',
        'webm': 'video/webm',
      };
      final contentType = mimeTypes[extension] ?? 'application/octet-stream';

      request.files.add(
        http.MultipartFile(
          fieldName,
          file.openRead(),
          await file.length(),
          filename: file.path.split('/').last,
          contentType: MediaType.parse(contentType),
        ),
      );

      final streamedResponse = await request.send().timeout(
        Duration(seconds: effectiveTimeout),
      );
      return http.Response.fromStream(streamedResponse);
    }

    return _executeWithRetry(requiresAuth: requiresAuth, request: makeRequest);
  }
}
