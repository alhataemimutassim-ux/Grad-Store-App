import 'package:flutter/material.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/usecases/send_support_message.dart';
import '../../domain/usecases/get_all_support_messages.dart';
import '../../domain/usecases/delete_support_message.dart';
import '../../../../core/utils/app_error_handler.dart';

enum SupportStatus { initial, loading, success, error }

class SupportProvider with ChangeNotifier {
  final SendSupportMessage sendSupportMessage;
  final GetAllSupportMessages getAllSupportMessages;
  final DeleteSupportMessage deleteSupportMessage;

  SupportProvider({
    required this.sendSupportMessage,
    required this.getAllSupportMessages,
    required this.deleteSupportMessage,
  });

  SupportStatus _status = SupportStatus.initial;
  SupportStatus get status => _status;

  String _error = '';
  String get error => _error;

  List<SupportMessage> _messages = [];
  List<SupportMessage> get messages => _messages;

  /// إرسال رسالة دعم جديدة
  Future<bool> send({required String title, required String message}) async {
    _status = SupportStatus.loading;
    _error = '';
    notifyListeners();
    try {
      await sendSupportMessage.execute(title: title, message: message);
      _status = SupportStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = AppErrorHandler.getMessage(e);
      _status = SupportStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// جلب جميع الرسائل (للمدير فقط)
  Future<void> fetchAll() async {
    _status = SupportStatus.loading;
    _error = '';
    notifyListeners();
    try {
      _messages = await getAllSupportMessages.execute();
      _status = SupportStatus.success;
    } catch (e) {
      _error = AppErrorHandler.getMessage(e);
      _status = SupportStatus.error;
    }
    notifyListeners();
  }

  /// حذف رسالة (للمدير فقط)
  Future<bool> delete(int id) async {
    try {
      await deleteSupportMessage.execute(id);
      _messages.removeWhere((m) => m.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = AppErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    }
  }
}
