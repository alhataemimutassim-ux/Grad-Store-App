import '../../../auth/data/datasources/auth_remote_datasource.dart' show LoginResult;

abstract class AuthRepository {
  /// تسجيل مستخدم جديد — السرفر لا يُعيد بيانات المستخدم.
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