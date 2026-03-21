import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

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

  HttpClient({
    required this.baseUrl,
    this.timeoutDuration = 30,
  });

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
      throw ApiException('Unauthorized: Invalid or expired token',
          statusCode: statusCode);
    } else if (statusCode == 403) {
      throw ApiException('Forbidden: Access denied', statusCode: statusCode);
    } else if (statusCode == 404) {
      throw ApiException('Not found', statusCode: statusCode);
    } else {
      String errorMessage = 'Unexpected server error';
      if (body != null && body is Map && body.containsKey('message')) {
        errorMessage = body['message'];
      }
      throw ApiException(errorMessage, statusCode: statusCode);
    }
  }

  // ─── CRUD Operations ───────────────────────────────────────────────────────

  Future<dynamic> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 GET: $url');
      final response = await http
          .get(url, headers: _getHeaders(requiresAuth: requiresAuth))
          .timeout(Duration(seconds: timeoutDuration));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// renamed `data` to `body` to match service calls
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 POST: $url');
      final response = await http
          .post(
            url,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 PUT: $url');
      final response = await http
          .put(
            url,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 PATCH: $url');
      final response = await http
          .patch(
            url,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 DELETE: $url');
      final response = await http
          .delete(url, headers: _getHeaders(requiresAuth: requiresAuth))
          .timeout(Duration(seconds: timeoutDuration));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// multipart POST for file uploads (images, PDFs, videos)
  Future<dynamic> uploadFile(
    String endpoint, {
    required File file,
    required String fieldName, // 'file' for image upload
    Map<String, String>? fields, // extra form fields if needed
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 UPLOAD: $url');

      final request = http.MultipartRequest('POST', url);

      // add auth header
      if (requiresAuth && _authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // add extra fields if any
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // attach the file
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      final streamedResponse = await request.send()
          .timeout(Duration(seconds: timeoutDuration));
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}