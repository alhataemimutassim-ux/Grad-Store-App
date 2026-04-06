import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/features/auth/presentation/state/auth_provider.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/login_a_page.dart';

class AuthGuard {
  static Future<void> checkAuth(BuildContext context, {required VoidCallback onAuthenticated}) async {
    final authProvider = context.read<AuthProvider>();
    final token = await authProvider.tokenManager.getAccessToken();

    if (token != null && token.isNotEmpty) {
      onAuthenticated();
    } else {
      if (context.mounted) {
        _showLoginDialog(context);
      }
    }
  }

  static void _showLoginDialog(BuildContext context) {
    final colors = context.theme.appColors;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.corners)),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: colors.primary),
            const SizedBox(width: 8),
            const Text('تسجيل الدخول مطلوب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text('يجب عليك تسجيل الدخول لتتمكن من إضافة المنتجات إلى السلة أو المفضلة. هل تريد تسجيل الدخول الآن؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: colors.gray4)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.smallCorners)),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              appPush(context, const LoginaPage()); // Navigate to login page
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }
}
