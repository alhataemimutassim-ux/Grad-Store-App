import 'package:flutter/material.dart';

/// حقل نصي موحّد يستخدم theme الحالي
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final bool obscureText;
  final Widget? prefixIcon;

  const AppTextField({super.key, this.controller, this.label, this.obscureText = false, this.prefixIcon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
