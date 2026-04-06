import 'package:flutter/services.dart';

class AppValidators {
  /// التحقق من أن الحقل ليس فارغاً
  static String? validateRequired(String? value, {String fieldName = 'هذا الحقل'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// التحقق من صحة البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    // التحقق من وجود مسافات
    if (value.contains(' ')) {
      return 'البريد الإلكتروني يجب أن لا يحتوي على مسافات';
    }

    // التحقق من أن النص لا يحتوي على حروف عربية
    final arabicCharRegExp = RegExp(r'[\u0600-\u06FF]');
    if (arabicCharRegExp.hasMatch(value)) {
      return 'البريد الإلكتروني يجب أن يكون باللغة الإنجليزية';
    }

    // التحقق المعتمد للإيميل
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  /// التحقق من صحة رقم الهاتف
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    
    final phoneRegExp = RegExp(r'^[0-9]+$');
    if (!phoneRegExp.hasMatch(value.trim())) {
      return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
    }

    if (value.trim().length < 8) {
      return 'رقم الهاتف قصير جداً';
    }

    if (value.trim().length > 15) {
      return 'رقم الهاتف طويل جداً';
    }

    return null;
  }

  /// التحقق القوي من كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن لا تقل عن 8 أحرف';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    if (!RegExp(r'[a-zA-Z].*[a-zA-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرفين على الأقل';
    }
    return null;
  }

  /// تقييم قوة كلمة المرور
  /// يعيد قيمة من 0 إلى 4
  static int passwordStrength(String value) {
    if (value.isEmpty) return 0;
    int score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[a-z]').hasMatch(value) && RegExp(r'[0-9]').hasMatch(value)) score++;
    if (value.length >= 12 && RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) score++;
    return score;
  }

  /// نص قوة كلمة المرور
  static String passwordStrengthLabel(int strength) {
    switch (strength) {
      case 0: return 'ضعيفة جداً';
      case 1: return 'ضعيفة';
      case 2: return 'متوسطة';
      case 3: return 'قوية';
      case 4: return 'قوية جداً';
      default: return '';
    }
  }

  /// لون مؤشر القوة
  static List<int> passwordStrengthColor(int strength) {
    // Returns [R, G, B]
    switch (strength) {
      case 0: return [239, 68, 68];   // أحمر
      case 1: return [249, 115, 22];  // برتقالي
      case 2: return [234, 179, 8];   // أصفر
      case 3: return [34, 197, 94];   // أخضر
      case 4: return [16, 185, 129];  // أخضر داكن
      default: return [200, 200, 200];
    }
  }


  /// التحقق من تطابق كلمتي المرور
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != originalPassword) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  // ============================================
  // Formatter Utilities للمنع أثناء الكتابة
  // ============================================

  /// مقيد لحقل البريد الإلكتروني: يمنع الحروف العربية والمسافات
  static List<TextInputFormatter> emailInputFormatters = [
    FilteringTextInputFormatter.deny(RegExp(r'[\u0600-\u06FF]')), // منع الحروف العربية
    FilteringTextInputFormatter.deny(RegExp(r'\s')), // منع المسافات
  ];

  /// مقيد لحقل الهاتف/الأرقام: يسمح فقط بالأرقام وعلامة + (اختياري)
  static List<TextInputFormatter> phoneInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
  ];
  
  /// مقيد للأرقام فقط (للأكواد والأسعار وغيرها)
  static List<TextInputFormatter> digitsOnlyFormatters = [
    FilteringTextInputFormatter.digitsOnly,
  ];
}
