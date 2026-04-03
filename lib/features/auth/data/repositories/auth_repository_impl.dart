import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int roleId,
  }) async {
    return await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      roleId: roleId,
    );
  }

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<String> refreshToken() async {
    return await remoteDataSource.refreshToken();
  }

  @override
  Future<void> logout() async {
    return await remoteDataSource.logout();
  }
}