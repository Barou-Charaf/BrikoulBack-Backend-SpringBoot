import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiConfig {
  // Flutter Web / Edge on the same laptop.
  // For Android emulator use http://10.0.2.2:9090.
  // For a real phone use your laptop LAN IP, for example http://192.168.1.10:9090.
  static const String baseUrl = 'http://localhost:9090';
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;
  String? token;

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    final response = await _request(() => _http.get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers));
    return _decode(response);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final response = await _request(
      () => _http.post(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers,
        body: jsonEncode(body ?? {}),
      ),
    );
    return _decode(response);
  }

  Future<dynamic> put(String path, [Map<String, dynamic>? body]) async {
    final response = await _request(
      () => _http.put(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers,
        body: jsonEncode(body ?? {}),
      ),
    );
    return _decode(response);
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    final response = await _request(
      () => _http.patch(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers,
        body: body == null ? null : jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  Future<void> delete(String path) async {
    final response = await _request(() => _http.delete(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers));
    if (response.statusCode >= 400) {
      _throw(response);
    }
  }

  Future<http.Response> _request(Future<http.Response> Function() call) async {
    try {
      return await call();
    } catch (_) {
      throw ApiException(
        "Impossible de joindre le backend. Vérifiez que Spring Boot tourne sur ${ApiConfig.baseUrl} et redémarrez-le après les changements CORS.",
      );
    }
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 400) {
      _throw(response);
    }
    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Never _throw(http.Response response) {
    String message = 'Erreur serveur (${response.statusCode}).';
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      message = body['message']?.toString() ?? 'Une erreur est survenue.';
    } catch (_) {
      // Keep fallback message when the response is not JSON.
    }
    throw ApiException(message, statusCode: response.statusCode);
  }
}
