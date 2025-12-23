import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chronus/features/auth/services/auth_service.dart';

import 'dart:io';

class ApiClient {
  final AuthService _authService;

  ApiClient(this._authService);

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = _authService.authToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(uri, headers: _headers);
    return response;
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body ?? {}),
    );
    return response;
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(uri, headers: _headers);
    return response;
  }

  // Legacy method for backward compatibility
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await post(path, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      // có thể custom error sau
      throw Exception('Request failed: ${response.statusCode}');
    }
  }
}
