import 'package:flutter/material.dart';

/// حقل نصي موحّد يستخدم theme الحالي
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final bool obscureText;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key, 
    this.controller, 
    this.label, 
    this.obscureText = false, 
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
      ),
    );
  }
}

