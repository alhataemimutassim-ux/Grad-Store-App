import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<String> execute({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}

// lib/features/auth/domain/usecases/refresh_token.dart


// lib/features/auth/domain/usecases/logout_user.dart
