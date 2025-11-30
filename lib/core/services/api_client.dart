import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:io';

class ApiClient {
  // TODO: sửa thành URL backend thật của nhóm
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? {}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      // có thể custom error sau
      throw Exception('Request failed: ${response.statusCode}');
    }
  }
}
