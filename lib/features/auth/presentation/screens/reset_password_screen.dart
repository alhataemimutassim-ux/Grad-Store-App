import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/features/auth/presentation/state/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    final typography = context.theme.appTypography;

    return Scaffold(
      appBar: AppBar(
        title: Text('تغيير كلمة المرور', style: TextStyle(color: colors.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: (colors.primary as Color).withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.password_rounded,
                  size: 70.0,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 30.0),
              Text(
                "أدخل تفاصيل المرور الجديدة",
                style: (typography.bodyMedium as TextStyle).copyWith(
                  color: Colors.grey[600],
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 45.0),
              _buildTextField(
                controller: _passwordController,
                label: "كلمة المرور الجديدة",
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                colors: colors,
              ),
              const SizedBox(height: 18.0),
              _buildTextField(
                controller: _confirmPasswordController,
                label: "تأكيد كلمة المرور",
                icon: Icons.lock_reset_rounded,
                obscure: _obscureConfirmPassword,
                onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                colors: colors,
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
                              final pass = _passwordController.text;
                              final confirmPass = _confirmPasswordController.text;
                              if (pass.isEmpty || confirmPass.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('الرجاء ملء كافة الحقول')),
                                );
                                return;
                              }
                              if (pass != confirmPass) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('كلمات المرور غير متطابقة')),
                                );
                                return;
                              }
                              
                              await auth.resetPassword(token: widget.token, newPassword: pass);

                              if (!context.mounted) return;
                              if (auth.status == AuthStatus.passwordResetDone) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم تغيير كلمة المرور بنجاح!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pushNamedAndRemoveUntil(context, '/login_a', (route) => false);
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
                              "حفظ كلمة المرور",
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
    required dynamic colors,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 15.0),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14.0, color: Colors.grey),
        prefixIcon: Icon(icon, color: colors.primary, size: 22.0),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: Colors.grey,
            size: 20.0,
          ),
          onPressed: onToggle,
        ),
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
    );
  }
}
