import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  /// يُسجّل مستخدمًا جديدًا. السرفر يُعيد رسالة نجاح فقط بدون بيانات المستخدم.
  Future<void> execute({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int roleId,
  }) {
    return repository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      roleId: roleId,
    );
  }
}
