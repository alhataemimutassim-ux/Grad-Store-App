import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

/// نتيجة تسجيل الدخول التي تحتوي على التوكن وبيانات المستخدم إذا أتت من السرفر.
class LoginResult {
  final String accessToken;
  final String? refreshToken;
  // بيانات المستخدم إذا أعادها السرفر مع الـ login response
  final UserModel? user;

  LoginResult({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });
}

abstract class AuthRemoteDataSource {
  /// تسجيل مستخدم جديد — السرفر يُعيد رسالة نجاح فقط (لا يُعيد بيانات المستخدم).
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int roleId,
  });

  /// تسجيل الدخول — يُعيد [LoginResult] يحتوي على accessToken وإن وُجد refreshToken.
  Future<LoginResult> login({
    required String email,
    required String password,
  });

  Future<String> refreshToken();

  Future<void> logout();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({required String token, required String newPassword});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int roleId,
  }) async {
    // السرفر يُعيد رسالة نجاح فقط عند التسجيل
    await apiClient.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'roleId': roleId,
    });
    // لا نُعيد بيانات المستخدم لأن السرفر لا يُعيدها
  }

  @override
  Future<LoginResult> login({required String email, required String password}) async {
    final response = await apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    // استخرج accessToken — يدعم مفاتيح مختلفة
    final accessToken = (response['accessToken'] ??
        response['access_token'] ??
        response['token'] ??
        '').toString();

    if (accessToken.isEmpty) {
      throw Exception('لم يُعد السرفر access token صالح');
    }

    // استخرج refreshToken إذا أُعيد
    final refreshToken = (response['refreshToken'] ??
        response['refresh_token'])?.toString();

    // استخرج بيانات المستخدم من الـ response إذا أُعيدت
    UserModel? user;
    final userRaw = response['user'] ?? response['User'] ?? response['userData'];
    if (userRaw is Map<String, dynamic>) {
      try {
        user = UserModel.fromJson(userRaw);
      } catch (_) {}
    }

    return LoginResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  @override
  Future<String> refreshToken() async {
    final response = await apiClient.post('/auth/refresh');
    final token = (response['accessToken'] ?? response['access_token'] ?? response['token'])?.toString();
    if (token == null || token.isEmpty) throw Exception('فشل تجديد التوكن');
    return token;
  }

  @override
  Future<void> logout() async {
    await apiClient.post('/auth/logout');
  }

  @override
  Future<void> forgotPassword(String email) async {
    await apiClient.post('/auth/forgot-password', {'email': email});
  }

  @override
  Future<void> resetPassword({required String token, required String newPassword}) async {
    await apiClient.post('/auth/reset-password', {
      'token': token,
      'newPassword': newPassword,
    });
  }
}
