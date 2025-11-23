import 'dart:async';

class AuthService {
  /// Tạm mock: nếu email không rỗng và password >= 4 ký tự => login ok
  Future<bool> login({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1)); // giả lập call API

    if (email.isNotEmpty && password.length >= 4) {
      // TODO: sau này gọi API thật:
      // final res = await _apiClient.post('/auth/login', body: {
      //   'email': email,
      //   'password': password,
      // });
      // return res['success'] == true;
      return true;
    }
    return false;
  }
}
