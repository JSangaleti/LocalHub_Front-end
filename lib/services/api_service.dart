import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  // Determina a base URL dependendo do ambiente e plataforma
  static String _resolveDefaultBaseUrl() {
    const env = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (env.isNotEmpty) return env;
    if (kIsWeb) return 'http://localhost:3000/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000/api';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:3000/api';
      default:
        return 'http://localhost:3000/api';
    }
  }

  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? _resolveDefaultBaseUrl(),
        _client = client ?? http.Client();

  // ===================== GET =====================
  Future<dynamic> get(String path, {Map<String, String>? queryParameters}) async {
    try {
      var uri = Uri.parse('$baseUrl$path');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }
      final response = await _client.get(uri);
      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      throw ApiException(_connectionHint(e.message));
    } on FormatException catch (e) {
      throw ApiException('Invalid server response: ${e.message}');
    } catch (e) {
      throw ApiException(_connectionHint(e.toString()));
    }
  }

  // ===================== POST =====================
  Future<dynamic> post(String path, Map<String, dynamic> body, {Map<String, String>? queryParameters}) async {
    try {
      var uri = Uri.parse('$baseUrl$path');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      throw ApiException(_connectionHint(e.message));
    } on FormatException catch (e) {
      throw ApiException('Invalid server response: ${e.message}');
    } catch (e) {
      throw ApiException(_connectionHint(e.toString()));
    }
  }

  // ===================== PUT =====================
  Future<dynamic> put(String path, Map<String, dynamic> body, {Map<String, String>? queryParameters}) async {
    try {
      var uri = Uri.parse('$baseUrl$path');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }
      final response = await _client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      throw ApiException(_connectionHint(e.message));
    } on FormatException catch (e) {
      throw ApiException('Invalid server response: ${e.message}');
    } catch (e) {
      throw ApiException(_connectionHint(e.toString()));
    }
  }

  // ===================== DELETE =====================
  Future<dynamic> delete(String path, {Map<String, String>? queryParameters}) async {
    try {
      var uri = Uri.parse('$baseUrl$path');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }
      final response = await _client.delete(uri);
      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      throw ApiException(_connectionHint(e.message));
    } on FormatException catch (e) {
      throw ApiException('Invalid server response: ${e.message}');
    } catch (e) {
      throw ApiException(_connectionHint(e.toString()));
    }
  }

  // ===================== HELPERS =====================
  String _connectionHint(String? detail) {
    final base = 'Could not connect to API at $baseUrl.\n'
        'Make sure the backend is running (e.g., port 3000).\n'
        'On a physical device use: flutter run --dart-define=API_BASE_URL=http://YOUR_IP:3000/api';
    if (detail == null || detail.isEmpty) return base;
    return '$base\n($detail)';
  }

  dynamic _decodeResponse(http.Response response) {
    final hasBody = response.body.trim().isNotEmpty;
    final data = hasBody ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final message = data is Map<String, dynamic>
        ? (data['message']?.toString() ?? 'Request error.')
        : 'Request error.';

    throw ApiException(message, statusCode: response.statusCode);
  }
}