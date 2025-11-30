class AuthService {
  // final ApiClient _apiClient;

  // AuthService(this._apiClient);

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 4) {
      return true;
    }
    return false;
  }

  Future<bool> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));


    return true; // tạm thời luôn thành công để demo
  }

  /// Fake Register for now.
  /// Later: call backend register API.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 8 && name.isNotEmpty) {
      return true;
    }
    return false;
  }
}
