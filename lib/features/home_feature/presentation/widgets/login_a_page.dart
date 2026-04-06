import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/features/auth/presentation/state/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:grad_store_app/core/utils/app_validators.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/widgets/app_snackbar.dart';

class LoginaPage extends StatelessWidget {
  const LoginaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    final typography = context.theme.appTypography;

    return AppScaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Header: أيقونة العميل الفخمة ---
              Container(
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: (colors.primary as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_pin_rounded,
                  size: 70.0,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 30.0),

              Text(
                "أهلاً بك مجدداً",
                style: (typography.bodyLarge as TextStyle).copyWith(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                "استكشف أفضل المنتجات والخدمات الطبية",
                textAlign: TextAlign.center,
                style: (typography.bodyMedium as TextStyle).copyWith(
                  color: Colors.grey[600],
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 45.0),

              // --- الحقول (Input Fields) ---
              _buildTextField(
                controller: _emailController,
                label: "البريد الإلكتروني",
                icon: Icons.email_rounded,
                colors: colors,
                typography: typography,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: AppValidators.emailInputFormatters,
              ),
              const SizedBox(height: 18.0),
              _buildTextField(
                controller: _passwordController,
                label: "كلمة المرور",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscure: _obscurePassword,
                onToggle:
                    () => setState(() => _obscurePassword = !_obscurePassword),
                colors: colors,
                typography: typography,
              ),
              
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    // Navigate to Forgot Password
                    Navigator.pushNamed(context, '/forgot_password');
                  },
                  child: Text("نسيت كلمة المرور؟", style: TextStyle(color: colors.primary)),
                ),
              ),

              // --- زر الدخول الرئيسي ---
              const SizedBox(height: 15.0),
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
                              final password = _passwordController.text;
                              if (email.isEmpty || password.isEmpty) {
                                AppSnackBar.showWarning(context, 'يرجى ملء جميع الحقول');
                                return;
                              }
                              
                              final emailError = AppValidators.validateEmail(email);
                              if (emailError != null) {
                                AppSnackBar.showError(context, emailError);
                                return;
                              }

                              await auth.login(email: email, password: password);
                              if (auth.status == AuthStatus.authenticated && context.mounted) {
                                Navigator.pushReplacementNamed(context, '/home');
                              } else if (auth.status == AuthStatus.error && context.mounted) {
                                AppSnackBar.showError(context, auth.errorMessage);
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
                              "دخول كـ عميل",
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
              
              const SizedBox(height: 25.0),

              // --- خيارات إضافية ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(context, '/home'),
                    child: Text(
                      "تصفح كضيف",
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.pushNamed(context, '/register_a'),
                    child: const Text(
                      "ليس لديك حساب؟ سجل الآن",
                      style: TextStyle(color: Colors.black54, fontSize: 13.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // --- الـ Tab Switcher الأسفل ---
      bottomNavigationBar: _buildBottomSelector(context, colors, false),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    required dynamic colors,
    required dynamic typography,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 15.0),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14.0, color: Colors.grey),
        prefixIcon: Icon(icon, color: colors.primary, size: 22.0),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                  onPressed: onToggle,
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
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
      ),
    );
  }

  Widget _buildBottomSelector(
    BuildContext context,
    dynamic colors,
    bool isVendor,
  ) {
    return Container(
      height: 85.0,
      padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 20.0),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTab(context, "عميل", !isVendor, '/login_a', colors),
            ),
            Expanded(
              child: _buildTab(
                context,
                "نقطة مبيعات",
                isVendor,
                '/login_m',
                colors,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String title,
    bool active,
    String route,
    dynamic colors,
  ) {
    return GestureDetector(
      onTap:
          () => active ? null : Navigator.pushReplacementNamed(context, route),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: active ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow:
              active
                  ? [
                    BoxShadow(
                      color: (colors.primary as Color).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey[600],
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 13.0,
          ),
        ),
      ),
    );
  }
}
