import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Exceptions personnalisées pour gérer les erreurs API de manière uniforme
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {this.statusCode = 500});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Classe centralisée pour toutes les requêtes API (CRUD)
class ApiRequest {
  // L'URL de base de votre serveur (à configurer). 
  // Utilisez 10.0.2.2 pour localhost sur émulateur Android, ou votre vraie URL/IP en prod.
  static const String baseUrl = 'http://10.0.2.2:8000/api'; 
  
  // Singleton pattern
  ApiRequest._privateConstructor();
  static final ApiRequest instance = ApiRequest._privateConstructor();

  // Stocker le token s'il existe
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Générateur de headers centralisé
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

  // Traitement centralisé des réponses HTTP
  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    // Essayer de décoder le corps, s'il y en a un
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (e) {
        body = response.body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else if (statusCode == 401) {
      throw ApiException('Non autorisé (Token invalide ou expiré)', statusCode: statusCode);
    } else if (statusCode == 403) {
      throw ApiException('Accès refusé', statusCode: statusCode);
    } else if (statusCode == 404) {
      throw ApiException('Ressource non trouvée', statusCode: statusCode);
    } else {
      // Tenter de récupérer un message d'erreur depuis le serveur
      String errorMessage = 'Erreur serveur inattendue';
      if (body != null && body is Map && body.containsKey('message')) {
        errorMessage = body['message'];
      }
      throw ApiException(errorMessage, statusCode: statusCode);
    }
  }

  String _buildUrl(String endpoint) {
    // Évite les doubles slash si endpoint commence déjà par /
    final safeEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    // Si endpoint est une URL complète (ex: Google API), on l'utilise telle quelle
    if (endpoint.startsWith('http')) return endpoint;
    
    return '$baseUrl$safeEndpoint';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Opérations CRUD
  // ─────────────────────────────────────────────────────────────────────────────

  /// GET Request
  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 GET: $url');
      final response = await http.get(url, headers: _getHeaders(requiresAuth: requiresAuth));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur réseau ou connexion impossible: $e');
    }
  }

  /// POST Request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data, bool requiresAuth = true}) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 POST: $url');
      final response = await http.post(
        url,
        headers: _getHeaders(requiresAuth: requiresAuth),
        body: data != null ? jsonEncode(data) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur réseau ou connexion impossible: $e');
    }
  }

  /// PUT Request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data, bool requiresAuth = true}) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 PUT: $url');
      final response = await http.put(
        url,
        headers: _getHeaders(requiresAuth: requiresAuth),
        body: data != null ? jsonEncode(data) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur réseau ou connexion impossible: $e');
    }
  }

  /// DELETE Request
  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse(_buildUrl(endpoint));
    try {
      debugPrint('🌐 DELETE: $url');
      final response = await http.delete(url, headers: _getHeaders(requiresAuth: requiresAuth));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur réseau ou connexion impossible: $e');
    }
  }
}
