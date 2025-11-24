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

  /// Fake Google Login for now.
  /// Later: call backend Google OAuth API and handle token.
  Future<bool> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));

    // TODO: sau này:
    // final res = await _apiClient.post('/auth/google', body: {...});
    // return res['success'] == true;

    return true; // tạm thời luôn thành công để demo
  }
}
