import '../repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  Future<void> execute({required String token, required String newPassword}) {
    return repository.resetPassword(token: token, newPassword: newPassword);
  }
}
