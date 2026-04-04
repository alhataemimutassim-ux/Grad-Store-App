import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/features/auth/presentation/state/auth_provider.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';

class RegisterMPage extends StatefulWidget {
  const RegisterMPage({super.key});

  @override
  State<RegisterMPage> createState() => _RegisterMPageState();
}

class _RegisterMPageState extends State<RegisterMPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    final typography = context.theme.appTypography;

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            const SizedBox(height: 20.0),
            Text(
              "بوابة الموردين",
              style: (typography.bodyLarge as TextStyle).copyWith(
                fontSize: 28.0,
                fontWeight: FontWeight.w900,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "أنشئ حسابك كشريك تقني وابدأ بإدارة أعمالك",
              style: TextStyle(color: Colors.grey[600], fontSize: 14.0),
            ),
            const SizedBox(height: 35.0),

            _buildField(
              _nameController,
              "الاسم الكامل (أو اسم النقطة)",
              Icons.storefront_outlined,
              colors,
            ),
            const SizedBox(height: 16.0),

            _buildField(
              _emailController,
              "البريد الإلكتروني",
              Icons.email_outlined,
              colors,
              type: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),

            _buildField(
              _phoneController,
              "رقم الهاتف",
              Icons.phone_android_rounded,
              colors,
              type: TextInputType.phone,
            ),
            const SizedBox(height: 16.0),
            
            _buildField(
              _passwordController,
              "كلمة المرور",
              Icons.lock_open_rounded,
              colors,
              isPass: true,
            ),

            const SizedBox(height: 35.0),

            SizedBox(
              width: double.infinity,
              height: 55.0,
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return ElevatedButton(
                    onPressed: auth.status == AuthStatus.loading
                        ? null
                        : () async {
                            final name = _nameController.text.trim();
                            final email = _emailController.text.trim();
                            final phone = _phoneController.text.trim();
                            final password = _passwordController.text;

                            if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('الرجاء ملء كافة الحقول')),
                              );
                              return;
                            }

                            await auth.register(
                              name: name,
                              email: email,
                              password: password,
                              phone: phone,
                              roleId: 1, // 1 for Vendor (Seller)
                            );

                            if (auth.status == AuthStatus.registrationSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إنشاء حساب المورد بنجاح! يرجى تسجيل الدخول.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context); // العودة إلى شاشة الدخول
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: auth.status == AuthStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "إنشاء حساب مورد",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16.0),

            SizedBox(
              width: double.infinity,
              height: 55.0,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.g_mobiledata_rounded,
                  size: 30,
                  color: Colors.red,
                ),
                label: const Text(
                  "التسجيل بواسطة جوجل",
                  style: TextStyle(color: Colors.black87),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    dynamic colors, {
    bool isPass = false,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      onTap: onTap,
      obscureText: isPass && _obscurePassword,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: Icon(icon, color: colors.primary, size: 20.0),
        suffixIcon: isPass
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: (colors.primary as Color).withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }

}
