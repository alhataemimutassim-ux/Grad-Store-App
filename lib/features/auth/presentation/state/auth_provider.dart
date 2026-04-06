import 'package:flutter/material.dart';
import '../../../../features/auth/domain/usecases/login_user.dart';
import '../../../../features/auth/domain/usecases/register_user.dart';
import '../../../../features/auth/domain/usecases/logout_user.dart';
import '../../../../features/auth/domain/usecases/refresh_token.dart';
import '../../../../features/auth/domain/usecases/forgot_password.dart';
import '../../../../features/auth/domain/usecases/reset_password.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../core/utils/app_error_handler.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  /// حالة خاصة: تم إرسال رابط استعادة كلمة المرور بنجاح
  forgotPasswordSent,
  /// حالة خاصة: تم إعادة تعيين كلمة المرور بنجاح
  passwordResetDone,
  /// حالة خاصة: تم التسجيل بنجاح وينتظر المستخدم تسجيل الدخول
  registrationSuccess,
}

class AuthProvider with ChangeNotifier {
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final RefreshTokenUseCase refreshTokenUseCase;
  final ForgotPassword forgotPasswordUseCase;
  final ResetPassword resetPasswordUseCase;
  final TokenManager tokenManager;

  AuthProvider({
    required this.registerUser,
    required this.loginUser,
    required this.logoutUser,
    required this.refreshTokenUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.tokenManager,
  });

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  // ===== Register =====
  /// يُسجّل مستخدمًا جديدًا. السرفر لا يُعيد بيانات المستخدم —
  /// يتغيّر الحالة إلى [AuthStatus.registrationSuccess] لتوجيه الواجهة
  /// نحو صفحة تسجيل الدخول.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int roleId,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await registerUser.execute(
        name: name,
        email: email,
        password: password,
        phone: phone,
        roleId: roleId,
      );
      // التسجيل نجح، لكن المستخدم يحتاج إلى تسجيل الدخول
      _status = AuthStatus.registrationSuccess;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _formatError(e);
    }
    notifyListeners();
  }

  // ===== Login =====
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await loginUser.execute(email: email, password: password);

      // حفظ accessToken
      await tokenManager.saveAccessToken(result.accessToken);

      // حفظ refreshToken إن وُجد
      if (result.refreshToken != null) {
        await tokenManager.saveRefreshToken(result.refreshToken!);
      }

      // إذا أعاد السرفر بيانات المستخدم مع الـ login response، نستخدمها مباشرةً
      if (result.user != null) {
        _user = result.user;
      } else {
        // نستخرج userId من الـ JWT
        final id = await tokenManager.getUserIdFromAccessToken();
        final roleId = await tokenManager.getRoleIdFromAccessToken();
        if (id != null) {
          _user = User(
            idUser: id,
            name: '',
            email: email,
            phone: '',
            roleId: roleId ?? 1,
          );
        }
      }

      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _formatError(e);
    }
    notifyListeners();
  }

  // ===== Refresh =====
  Future<void> refreshToken() async {
    try {
      final token = await refreshTokenUseCase.execute();
      await tokenManager.saveAccessToken(token);
      // لا نغيّر حالة المصادقة هنا
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // ===== Logout =====
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await logoutUser.execute();
    } catch (_) {
      // حتى لو فشل الـ logout من السرفر، نُلغي البيانات المحلية
    } finally {
      await tokenManager.deleteAccessToken();
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // ===== Forgot Password =====
  Future<void> forgotPassword(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await forgotPasswordUseCase.execute(email);
      // نستخدم حالة مخصصة بدلاً من unauthenticated لتجنّب التأثير على شاشات أخرى
      _status = AuthStatus.forgotPasswordSent;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _formatError(e);
    }
    notifyListeners();
  }

  // ===== Reset Password =====
  Future<void> resetPassword({required String token, required String newPassword}) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await resetPasswordUseCase.execute(token: token, newPassword: newPassword);
      _status = AuthStatus.passwordResetDone;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _formatError(e);
    }
    notifyListeners();
  }

  // ===== Helpers =====

  /// تنسيق رسائل الخطأ القادمة من السرفر أو الاستثناءات
  String _formatError(Object e) {
    return AppErrorHandler.getMessage(e);
  }

  /// إعادة الحالة إلى initial (مفيد بعد إغلاق رسائل الخطأ)
  void clearError() {
    if (_status == AuthStatus.error) {
      _status = AuthStatus.initial;
      _errorMessage = '';
      notifyListeners();
    }
  }
}
