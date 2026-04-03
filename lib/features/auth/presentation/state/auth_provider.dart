import 'package:flutter/material.dart';
import '../../../../features/auth/domain/usecases/login_user.dart';
import '../../../../features/auth/domain/usecases/register_user.dart';
import '../../../../features/auth/domain/usecases/logout_user.dart';
import '../../../../features/auth/domain/usecases/refresh_token.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../core/utils/token_manager.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final RefreshTokenUseCase refreshTokenUseCase;
  final TokenManager tokenManager;

  AuthProvider({
    required this.registerUser,
    required this.loginUser,
    required this.logoutUser,
    required this.refreshTokenUseCase,
    required this.tokenManager,
  });

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  // ===== Register =====
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int roleId,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      _user = await registerUser.execute(
        name: name,
        email: email,
        password: password,
        phone: phone,
        roleId: roleId,
      );
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // ===== Login =====
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await loginUser.execute(email: email, password: password);
      await tokenManager.saveAccessToken(token);
      // try to extract user id from token and set a lightweight User object
      final id = await tokenManager.getUserIdFromAccessToken();
      if (id != null) {
        _user = User(idUser: id, name: '', email: '', phone: '', roleId: 1);
      }
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // ===== Refresh =====
  Future<void> refreshToken() async {
    try {
      final token = await refreshTokenUseCase.execute();
      await tokenManager.saveAccessToken(token);
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ===== Logout =====
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await logoutUser.execute();
      await tokenManager.deleteAccessToken();
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
