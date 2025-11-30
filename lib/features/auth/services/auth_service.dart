import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Backend URL - thay đổi theo backend thực tế của bạn
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://localhost:8000/api/v1';
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',
    ],
    serverClientId: '740558145310-ehpe5h14crocaas9hl1htmkdu87eofk6.apps.googleusercontent.com',
  );

  String? _authToken;

  /// Login với email/password
  /// Endpoint: POST /auth/login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'] ?? data['access_token'];
        return true;
      }
      return false;
    } catch (e) {
      print('Login Error: $e');
      return false;
    }
  }

  /// Register tài khoản mới
  /// Endpoint: POST /auth/register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'] ?? data['access_token'];
        return true;
      }
      return false;
    } catch (e) {
      print('Register Error: $e');
      return false;
    }
  }

  /// Google Sign-In
  /// Endpoint: POST /auth/google/verify
  Future<bool> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': idToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'] ?? data['access_token'];
        return true;
      }

      return false;
    } catch (e) {
      print('Google Login Error: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _authToken = null;
    await _googleSignIn.signOut();
  }

  /// Get stored auth token
  String? get authToken => _authToken;
}
