import 'dart:async';
import 'dart:io';

import '../errors/exceptions.dart';
import '../errors/failure.dart';

/// فئة مسؤولة عن معالجة استثناءات التطبيق وتحويلها لرسائل واضحة وملائمة للمستخدم.
class AppErrorHandler {
  static String getMessage(dynamic error) {
    if (error is ServerException) {
      return _localizeMessage(error.message);
    } else if (error is SocketException || error.toString().toLowerCase().contains('socket') || error.toString().toLowerCase().contains('تأكد من اتصال')) {
      return 'لا يوجد اتصال بالإنترنت. تأكد من اتصالك بالشبكة.';
    } else if (error is TimeoutException || error.toString().toLowerCase().contains('timeout')) {
      return 'انتهى وقت الاتصال بالخادم. حاول مرة أخرى.';
    } else if (error is FormatException) {
      return 'حدث خطأ في قراءة استجابة السيرفر.';
    } else if (error is Failure) {
      return _localizeMessage(error.message);
    } else if (error is Exception) {
      final str = error.toString();
      String processed = str.startsWith('Exception: ') ? str.substring('Exception: '.length) : str;
      return _localizeMessage(processed);
    }
    
    return _localizeMessage(error.toString());
  }

  static String _localizeMessage(String msg) {
    // توحيد الرسالة وتحويلها لأحرف صغيرة لتسهيل البحث
    final lower = msg.toLowerCase();

    // التحقق من أخطاء تسجيل الدخول
    if (lower.contains('invalid credentials') || 
        lower.contains('invalid login') || 
        lower.contains('incorrect password') || 
        lower.contains('user not found') ||
        lower.contains('كلمة المرور غير صحيحة') ||
        lower.contains('لايوجد مستخدم')) {
      return 'بيانات تسجيل الدخول خاطئة.';
    }

    // التحقق من حالة تأكيد الحساب
    if (lower.contains('not confirmed') || 
        lower.contains('confirm') || 
        lower.contains('unverified') ||
        lower.contains('يرجى تأكيد')) {
      return 'حسابك غير مفعل، يرجى تأكيد الحساب.';
    }

    // التحقق من الأعطال العامة أو الشبكة
    if (lower.contains('host lookup') || lower.contains('network is unreachable')) {
      return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة الخاصة بك.';
    }

    if (lower.contains('server error') || lower.contains('500')) {
      return 'يوجد خلل في الخادم حالياً. يرجى المحاولة لاحقاً.';
    }

    if (lower.contains('unauthorized') || lower.contains('401')) {
      return 'جلسة العمل منتهية الصلاحية. يرجى تسجيل الدخول مجدداً.';
    }

    // إذا لم تتطابق مع أي شيء، أعد ترجمة النص إذا كان يحتوي على "Exception"
    if (lower == 'حدث خطأ في الخادم' || msg.trim().isEmpty) {
      return 'حدث خطأ غير متوقع، يرجى المحاولة من جديد.';
    }

    // إعادة الرسالة كما هي (قد تكون باللغة العربية مسبقاً مثلاً أخطاء الـ Validation)
    return msg;
  }
}
