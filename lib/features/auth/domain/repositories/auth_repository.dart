import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int roleId,
  });

  Future<String> login({
    required String email,
    required String password,
  });

  Future<String> refreshToken();

  Future<void> logout();
}