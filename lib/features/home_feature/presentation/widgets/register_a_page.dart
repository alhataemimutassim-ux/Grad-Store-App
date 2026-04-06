import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/state/auth_provider.dart';

class RegisterAPage extends StatefulWidget {
  const RegisterAPage({super.key});

  @override
  State<RegisterAPage> createState() => _RegisterAPageState();
}

class _RegisterAPageState extends State<RegisterAPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  /// حالة تحليل كلمة المرور
  int _passwordStrength = 0;

  /// false = طالب (roleId: 2) | true = بائع (roleId: 1)
  bool _isVendor = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();

    _passwordController.addListener(() {
      setState(() {
        _passwordStrength =
            AppValidators.passwordStrength(_passwordController.text);
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _switchRole(bool isVendor) {
    if (_isVendor == isVendor) return;
    _animCtrl.reverse().then((_) {
      setState(() => _isVendor = isVendor);
      _animCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    final typography = context.theme.appTypography;

    final roleId = _isVendor ? 1 : 2;
    final roleLabel = _isVendor ? 'بائع' : 'طالب';
    final roleIcon =
        _isVendor ? Icons.storefront_rounded : Icons.school_rounded;

    return AppScaffold(
      bottomNavigationBar: _buildRoleSelector(colors),
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

            // ─── Header ─────────────────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(roleIcon, color: colors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إنشاء حساب جديد',
                        style: typography.bodyLarge.copyWith(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                      Text(
                        'التسجيل كـ $roleLabel',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28.0),

            // ─── Fields ──────────────────────────────────────────────────────
            _buildField(
              _nameController,
              'الاسم الكامل',
              Icons.person_outline,
              colors,
            ),
            const SizedBox(height: 16.0),

            _buildField(
              _emailController,
              'البريد الإلكتروني',
              Icons.email_outlined,
              colors,
              type: TextInputType.emailAddress,
              inputFormatters: AppValidators.emailInputFormatters,
            ),
            const SizedBox(height: 16.0),

            _buildField(
              _phoneController,
              'رقم الهاتف',
              Icons.phone_android_rounded,
              colors,
              type: TextInputType.phone,
              inputFormatters: AppValidators.phoneInputFormatters,
            ),
            const SizedBox(height: 16.0),

            // ─── Password Field ──────────────────────────────────────────────
            _buildField(
              _passwordController,
              'كلمة المرور',
              Icons.lock_open_rounded,
              colors,
              isPass: true,
              isConfirm: false,
            ),

            // ─── Strength Indicator ──────────────────────────────────────────
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildStrengthIndicator(colors),
            ],

            const SizedBox(height: 16.0),

            // ─── Requirements hint ───────────────────────────────────────────
            _buildPasswordRequirements(),

            const SizedBox(height: 16.0),

            // ─── Confirm Password ────────────────────────────────────────────
            _buildField(
              _confirmPasswordController,
              'تأكيد كلمة المرور',
              Icons.lock_rounded,
              colors,
              isPass: true,
              isConfirm: true,
            ),

            const SizedBox(height: 14),

            // ─── Role badge ──────────────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(roleIcon, color: colors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'سيتم إنشاء حساب $roleLabel',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28.0),

            // ─── Submit Button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56.0,
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
                            final confirmPass =
                                _confirmPasswordController.text;

                            if (name.isEmpty ||
                                email.isEmpty ||
                                phone.isEmpty ||
                                password.isEmpty ||
                                confirmPass.isEmpty) {
                              AppSnackBar.showWarning(
                                  context, 'الرجاء ملء كافة الحقول');
                              return;
                            }

                            final emailErr =
                                AppValidators.validateEmail(email);
                            if (emailErr != null) {
                              AppSnackBar.showError(context, emailErr);
                              return;
                            }

                            final phoneErr =
                                AppValidators.validatePhone(phone);
                            if (phoneErr != null) {
                              AppSnackBar.showError(context, phoneErr);
                              return;
                            }

                            final passwordErr =
                                AppValidators.validatePassword(password);
                            if (passwordErr != null) {
                              AppSnackBar.showError(context, passwordErr);
                              return;
                            }

                            final confirmErr =
                                AppValidators.validateConfirmPassword(
                                    confirmPass, password);
                            if (confirmErr != null) {
                              AppSnackBar.showError(context, confirmErr);
                              return;
                            }

                            await auth.register(
                              name: name,
                              email: email,
                              password: password,
                              phone: phone,
                              roleId: roleId, // ✅ 1=بائع | 2=طالب
                            );

                            if (auth.status ==
                                    AuthStatus.registrationSuccess &&
                                context.mounted) {
                              AppSnackBar.showSuccess(
                                context,
                                'تم إنشاء حساب $roleLabel بنجاح! يرجى تسجيل الدخول.',
                              );
                              Navigator.pop(context);
                            } else if (auth.status == AuthStatus.error &&
                                context.mounted) {
                              AppSnackBar.showError(
                                  context, auth.errorMessage);
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
                        : Text(
                            'إنشاء حساب $roleLabel',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── Password Strength Indicator ─────────────────────────────────────────
  Widget _buildStrengthIndicator(dynamic colors) {
    final rgb = AppValidators.passwordStrengthColor(_passwordStrength);
    final color = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
    final label =
        AppValidators.passwordStrengthLabel(_passwordStrength);
    final fraction = (_passwordStrength + 1) / 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: fraction,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Password Requirements ────────────────────────────────────────────────
  Widget _buildPasswordRequirements() {
    final pass = _passwordController.text;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'متطلبات كلمة المرور:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          _buildRequirementRow(
              '8 أحرف على الأقل', pass.length >= 8),
          _buildRequirementRow(
              'حرف كبير (A-Z)', RegExp(r'[A-Z]').hasMatch(pass)),
          _buildRequirementRow(
              'حرف صغير (a-z)', RegExp(r'[a-z]').hasMatch(pass)),
          _buildRequirementRow(
              'رقم واحد على الأقل (0-9)', RegExp(r'[0-9]').hasMatch(pass)),
          _buildRequirementRow(
              'حرفين على الأقل', RegExp(r'[a-zA-Z].*[a-zA-Z]').hasMatch(pass)),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              key: ValueKey(met),
              size: 16,
              color: met ? const Color(0xFF10B981) : Colors.grey[400],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: met ? const Color(0xFF10B981) : Colors.grey[500],
              fontWeight: met ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Role Selector ────────────────────────────────────────────────────────
  Widget _buildRoleSelector(dynamic colors) {
    return Container(
      height: 90.0,
      padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Row(
          children: [
            Expanded(
                child: _buildRoleTab(
                    'طالب', Icons.school_rounded, false, colors)),
            Expanded(
                child: _buildRoleTab(
                    'بائع', Icons.storefront_rounded, true, colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTab(
    String title,
    IconData icon,
    bool isVendor,
    dynamic colors,
  ) {
    final active = _isVendor == isVendor;
    return GestureDetector(
      onTap: () => _switchRole(isVendor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3),
                    blurRadius: 8.0,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? Colors.white : Colors.grey[500],
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: active ? FontWeight.bold : FontWeight.w600,
                color: active ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Field Builder ────────────────────────────────────────────────────────
  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    dynamic colors, {
    bool isPass = false,
    bool isConfirm = false,
    TextInputType? type,
    List<TextInputFormatter>? inputFormatters,
  }) {
    // هل حقل التأكيد يتطابق مع كلمة المرور؟
    final bool confirmMatch = isConfirm &&
        _confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text == _passwordController.text;

    final obscure = isConfirm ? _obscureConfirm : _obscurePassword;

    return TextField(
      controller: ctrl,
      obscureText: isPass && obscure,
      keyboardType: type,
      inputFormatters: inputFormatters,
      onChanged: (_) => setState(() {}), // إعادة البناء لتحديث مؤشرات التأكيد
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: Icon(icon, color: colors.primary, size: 20.0),
        suffixIcon: isPass
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة التطابق لحقل التأكيد
                  if (isConfirm && _confirmPasswordController.text.isNotEmpty)
                    Icon(
                      confirmMatch
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 18,
                      color: confirmMatch
                          ? const Color(0xFF10B981)
                          : Colors.redAccent,
                    ),
                  IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => setState(() {
                      if (isConfirm) {
                        _obscureConfirm = !_obscureConfirm;
                      } else {
                        _obscurePassword = !_obscurePassword;
                      }
                    }),
                  ),
                ],
              )
            : null,
        filled: true,
        fillColor: isConfirm && _confirmPasswordController.text.isNotEmpty
            ? (confirmMatch
                ? const Color(0xFF10B981).withValues(alpha: 0.05)
                : Colors.red.withValues(alpha: 0.05))
            : colors.primary.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: isConfirm && _confirmPasswordController.text.isNotEmpty
                ? (confirmMatch
                    ? const Color(0xFF10B981)
                    : Colors.redAccent)
                : colors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
