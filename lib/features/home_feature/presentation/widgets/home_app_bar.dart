import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/sized_context.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/core/widgets/app_search_bar.dart';
import 'package:grad_store_app/features/auth/presentation/state/auth_provider.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/login_a_page.dart';
import '../screens/search_screen.dart';

import '../../../../core/gen/assets.gen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoggedIn = authProvider.status == AuthStatus.authenticated;
        return Column(
          children: [
            AppBar(
              backgroundColor: colors.primary,
              // Logo image يسار بدلاً من النص
              leading: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Assets.images.logo.image(fit: BoxFit.contain),
                ),
              ),
              leadingWidth: 60,
              titleSpacing: 8,
              title: Text(
                'Grad Store',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              actions: [
                // زر تسجيل الدخول / الخروج
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () async {
                      if (isLoggedIn) {
                        // تسجيل الخروج مع تأكيد
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('تسجيل الخروج'),
                            content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('إلغاء'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('خروج', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await authProvider.logout();
                        }
                      } else {
                        appPush(context, const LoginaPage());
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isLoggedIn
                            ? Colors.red.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLoggedIn ? Colors.red.shade200 : Colors.white54,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          Icon(
                            isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                            color: isLoggedIn ? Colors.red.shade200 : Colors.white,
                            size: 18,
                          ),
                          Text(
                            isLoggedIn ? 'خروج' : 'دخول',
                            style: TextStyle(
                              color: isLoggedIn ? Colors.red.shade200 : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                Container(
                  height: 50,
                  width: context.widthPx,
                  decoration: BoxDecoration(
                    color: context.theme.appColors.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(Dimens.extraLargePadding),
                      bottomRight: Radius.circular(Dimens.extraLargePadding),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 25,
                    left: Dimens.largePadding,
                    right: Dimens.largePadding,
                  ),
                  child: Hero(
                    tag: 'search_bar_hero',
                    child: Material(
                      type: MaterialType.transparency,
                      child: AppSearchBar(
                        readOnly: true,
                        onTap: () {
                          appPush(context, const SearchScreen());
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height + 80);
}
