import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/features/auth/presentation/state/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    final typography = context.theme.appTypography;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40.0),
              Container(
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: (colors.primary as Color).withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 70.0,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 30.0),
              Text(
                "استعادة كلمة المرور",
                style: (typography.bodyLarge as TextStyle).copyWith(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                "أدخل بريدك الإلكتروني ليتم إرسال رابط لاستعادة كلمة المرور.",
                textAlign: TextAlign.center,
                style: (typography.bodyMedium as TextStyle).copyWith(
                  color: Colors.grey[600],
                  fontSize: 14.0,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 45.0),
              TextField(
                controller: _emailController,
                style: const TextStyle(fontSize: 15.0),
                decoration: InputDecoration(
                  labelText: "البريد الإلكتروني",
                  labelStyle: const TextStyle(fontSize: 14.0, color: Colors.grey),
                  prefixIcon: Icon(Icons.email_rounded, color: colors.primary, size: 22.0),
                  filled: true,
                  fillColor: (colors.primary as Color).withAlpha(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
                ),
              ),
              const SizedBox(height: 35.0),
              SizedBox(
                width: double.infinity,
                height: 58.0,
                child: Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return ElevatedButton(
                      onPressed: auth.status == AuthStatus.loading
                          ? null
                          : () async {
                              final email = _emailController.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('الرجاء إدخال البريد الإلكتروني')),
                                );
                                return;
                              }
                              await auth.forgotPassword(email);

                              if (!context.mounted) return;
                              if (auth.status == AuthStatus.forgotPasswordSent) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم إرسال رابط الاستعادة إلى بريدك الإلكتروني بنجاح!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context); // العودة إلى تسجيل الدخول
                              } else if (auth.status == AuthStatus.error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(auth.errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: auth.status == AuthStatus.loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "إرسال الرابط",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
