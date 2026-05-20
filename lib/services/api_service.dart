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

  ApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? _resolveDefaultBaseUrl(),
        _client = client ?? http.Client();

  Future<dynamic> get(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await _client.get(uri);
      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      throw ApiException(_connectionHint(e.message));
    } on FormatException catch (e) {
      throw ApiException('Resposta invalida do servidor: ${e.message}');
    } catch (e) {
      throw ApiException(_connectionHint(e.toString()));
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
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
      throw ApiException('Resposta invalida do servidor: ${e.message}');
    } catch (e) {
      throw ApiException(_connectionHint(e.toString()));
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
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
      throw ApiException('Resposta invalida do servidor: ${e.message}');
    } catch (e) {
      throw ApiException(_connectionHint(e.toString()));
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await _client.delete(uri);
      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      throw ApiException(_connectionHint(e.message));
    } on FormatException catch (e) {
      throw ApiException('Resposta invalida do servidor: ${e.message}');
    } catch (e) {
      throw ApiException(_connectionHint(e.toString()));
    }
  }

  String _connectionHint(String? detail) {
    final base = 'Nao foi possivel conectar a API em $baseUrl.\n'
        'Confirme que o backend esta rodando (ex.: porta 3000).\n'
        'Em celular fisico use: flutter run --dart-define=API_BASE_URL=http://SEU_IP:3000/api';
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
        ? (data['message']?.toString() ?? 'Erro na requisicao.')
        : 'Erro na requisicao.';

    throw ApiException(message, statusCode: response.statusCode);
  }
}
