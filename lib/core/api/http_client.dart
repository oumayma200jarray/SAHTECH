import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Custom exception for uniform API error handling
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {this.statusCode = 500});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Centralized HTTP client for all API requests
class HttpClient {
  final String baseUrl;
  final int timeoutDuration;

  String? _authToken;

  HttpClient({
    required this.baseUrl,
    this.timeoutDuration = 15,
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // Token management
  // ─────────────────────────────────────────────────────────────────────────────

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Internal helpers
  // ─────────────────────────────────────────────────────────────────────────────

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
    // If already a full URL, use as-is
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
      throw ApiException('Unauthorized: Invalid or expired token', statusCode: statusCode);
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

  // ─────────────────────────────────────────────────────────────────────────────
  // CRUD Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// GET request
  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
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

  /// POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data, bool requiresAuth = true}) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 POST: $url');
      final response = await http
          .post(
            url,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data, bool requiresAuth = true}) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 PUT: $url');
      final response = await http
          .put(
            url,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// PATCH request
  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? data, bool requiresAuth = true}) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 PATCH: $url');
      final response = await http
          .patch(
            url,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
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
}