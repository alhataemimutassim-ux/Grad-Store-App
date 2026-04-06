import 'dart:ui';
import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackBar {
  /// عرض رسالة خطأ
  static void showError(BuildContext context, String message) {
    _showCustomSnackBar(context, message, SnackBarType.error);
  }

  /// عرض رسالة نجاح
  static void showSuccess(BuildContext context, String message) {
    _showCustomSnackBar(context, message, SnackBarType.success);
  }

  /// عرض تنبيه
  static void showWarning(BuildContext context, String message) {
    _showCustomSnackBar(context, message, SnackBarType.warning);
  }

  /// عرض معلومة
  static void showInfo(BuildContext context, String message) {
    _showCustomSnackBar(context, message, SnackBarType.info);
  }

  static void _showCustomSnackBar(BuildContext context, String message, SnackBarType type) {
    // إغلاق أي سناك بار نشط لضمان العرض المباشر
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = const Color(0xFF10B981);
        iconColor = Colors.white;
        icon = Icons.check_circle_rounded;
        break;
      case SnackBarType.error:
        backgroundColor = const Color(0xFFEF4444);
        iconColor = Colors.white;
        icon = Icons.error_outline_rounded;
        break;
      case SnackBarType.warning:
        backgroundColor = const Color(0xFFF59E0B);
        iconColor = Colors.white;
        icon = Icons.warning_amber_rounded;
        break;
      case SnackBarType.info:
        backgroundColor = const Color(0xFF3B82F6);
        iconColor = Colors.white;
        icon = Icons.info_outline_rounded;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      duration: const Duration(seconds: 4),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
