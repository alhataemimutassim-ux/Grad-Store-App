import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register({
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

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int roleId,
  }) async {
    await apiClient.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'roleId': roleId,
    });

    // عادة API ترجع رسالة فقط، لكن ممكن ترجع بيانات المستخدم
    // إذا لم ترجع بيانات، يمكن إعادة نموذج جزئي
    return UserModel(
      idUser: 0,
      name: name,
      email: email,
      phone: phone,
      roleId: roleId,
    );
  }

  @override
  Future<String> login({required String email, required String password}) async {
    final response = await apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    return response['accessToken'];
  }

  @override
  Future<String> refreshToken() async {
    final response = await apiClient.post('/auth/refresh', {});
    return response['accessToken'];
  }

  @override
  Future<void> logout() async {
    await apiClient.post('/auth/logout', {});
  }
}
