import 'package:fe_chronos/features/auth/services/auth_service.dart';
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

  /// Google Sign-In
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
}
