import '../../../auth/data/datasources/auth_remote_datasource.dart' show LoginResult;
import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<LoginResult> execute({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}
