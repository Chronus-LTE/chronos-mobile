import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyAuthToken = 'auth_token';
  static const String _keyIsFirstTime = 'is_first_time';

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
      // Scopes for Chronus features:
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/tasks',
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/gmail.send',
      'https://www.googleapis.com/auth/gmail.modify',
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
        await _saveToken(_authToken);
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
        await _saveToken(_authToken);
        return true;
      }
      return false;
    } catch (e) {
      print('Register Error: $e');
      return false;
    }
  }

  /// Google Sign-In (Mobile)
  /// Endpoint: POST /auth/google/mobile
  /// Uses serverAuthCode to allow backend to get refresh_token
  Future<bool> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled sign-in
        return false;
      }

      // Get server auth code (NOT idToken)
      final String? serverAuthCode = googleUser.serverAuthCode;

      if (serverAuthCode == null) {
        print('Error: Failed to get server auth code');
        return false;
      }

      // Send server auth code to backend
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google/mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'server_auth_code': serverAuthCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['access_token'];
        await _saveToken(_authToken);
        return true;
      } else {
        print('Google Sign-In Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _authToken = null;
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
  }

  /// Get stored auth token
  String? get authToken => _authToken;

  // --- Persistence Helpers ---

  Future<void> _saveToken(String? token) async {
    if (token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
  }

  /// Try to auto-login by checking stored token
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyAuthToken)) return false;

    _authToken = prefs.getString(_keyAuthToken);
    return _authToken != null;
  }

  /// Check if it's the first time the app is opened
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstTime) ?? true;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstTime, false);
  }
}
