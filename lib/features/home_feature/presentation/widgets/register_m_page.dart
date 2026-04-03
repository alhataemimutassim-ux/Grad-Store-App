import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';

class RegisterMPage extends StatefulWidget {
  const RegisterMPage({super.key});

  @override
  State<RegisterMPage> createState() => _RegisterMPageState();
}

class _RegisterMPageState extends State<RegisterMPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _customGenderController = TextEditingController();

  bool _obscurePassword = true;
  String? _gender = "ذكر";
  DateTime? _birthDate;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _majorController.dispose();
    _passwordController.dispose();
    _customGenderController.dispose();
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

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    _firstNameController,
                    "الاسم الأول",
                    Icons.person_outline,
                    colors,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildField(
                    _lastNameController,
                    "الاسم الأخير",
                    Icons.person_outline,
                    colors,
                  ),
                ),
              ],
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

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    _ageController,
                    "تاريخ الميلاد",
                    Icons.calendar_today_outlined,
                    colors,
                    readOnly: true,
                    onTap: _pickBirthDate,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(child: _buildGenderDropdown(colors)),
              ],
            ),

            if (_gender == "مخصص") ...[
              const SizedBox(height: 16.0),
              _buildField(
                _customGenderController,
                "تحديد الجنس",
                Icons.edit_note_rounded,
                colors,
              ),
            ],

            const SizedBox(height: 16.0),
            _buildField(
              _majorController,
              "التخصص الجامعي",
              Icons.school_outlined,
              colors,
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
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text(
                  "إنشاء حساب مورد",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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

  Widget _buildGenderDropdown(dynamic colors) {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: "الجنس",
        prefixIcon: Icon(Icons.wc_rounded, color: colors.primary, size: 20.0),
        filled: true,
        fillColor: (colors.primary as Color).withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: "ذكر", child: Text("ذكر")),
        DropdownMenuItem(value: "أنثى", child: Text("أنثى")),
        DropdownMenuItem(value: "مخصص", child: Text("مخصص")),
      ],
      onChanged: (val) => setState(() => _gender = val),
    );
  }

  Future<void> _pickBirthDate() async {
    DateTime temp = _birthDate ?? DateTime(1995);
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SizedBox(
        height: 300,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("إلغاء"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _birthDate = temp;
                      _ageController.text =
                          "${temp.day}/${temp.month}/${temp.year}";
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text("تم"),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: temp,
                onDateTimeChanged: (d) => temp = d,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
