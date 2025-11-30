import 'package:chronus/features/auth/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService);

  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(String email, String password) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.login(
        email: email,
        password: password,
      );

      if (success) {
        _isLoggedIn = true;
      } else {
        _errorMessage = 'Invalid email or password.';
      }
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      if (kDebugMode) {
        print(e);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Google Sign-In (Native SDK)
  Future<void> loginWithGoogle() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.loginWithGoogle();
      if (success) {
        _isLoggedIn = true;
      } else {
        _errorMessage = 'Google login failed.';
      }
    } catch (e) {
      _errorMessage = 'Google login error. Please try again.';
      if (kDebugMode) {
        print(e);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register new user
  Future<void> register(String name, String email, String password) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      if (success) {
        _isLoggedIn = true;
      } else {
        _errorMessage = 'Registration failed. Please try again.';
      }
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      if (kDebugMode) {
        print(e);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  /// Check if user is already logged in (via stored token)
  Future<bool> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.tryAutoLogin();
    _isLoggedIn = success;

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Check if this is the first time app launch
  Future<bool> checkFirstTime() async {
    return await _authService.isFirstTime();
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await _authService.completeOnboarding();
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
