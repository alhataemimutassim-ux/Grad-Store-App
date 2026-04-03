import 'package:flutter/material.dart';
import '../../../../core/utils/token_manager.dart';
import '../../data/models/payment_method_model.dart';
import '../../domain/usecases/get_payment_methods.dart';
import '../../domain/usecases/complete_checkout.dart';
import '../../../../features/orders/domain/entities/order.dart';
import '../../domain/entities/cart_item.dart';

enum CheckoutStatus { initial, loading, ready, submitting, success, error }

class CheckoutProvider with ChangeNotifier {
  final GetPaymentMethods getMethods;
  final CompleteCheckout complete;
  final TokenManager tokenManager;

  CheckoutProvider({required this.getMethods, required this.complete, required this.tokenManager});

  CheckoutStatus _status = CheckoutStatus.initial;
  CheckoutStatus get status => _status;

  String _error = '';
  String get error => _error;

  List<PaymentMethodModel> _methods = [];
  List<PaymentMethodModel> get methods => _methods;

  int? _selectedMethodId;
  int? get selectedMethodId => _selectedMethodId;

  void setSelectedMethod(int? id) {
    _selectedMethodId = id;
    notifyListeners();
  }

  String address = '';
  String phone = '';

  Future<void> loadMethods() async {
    _status = CheckoutStatus.loading;
    notifyListeners();
    try {
      final res = await getMethods.execute();
      _methods = res.cast<PaymentMethodModel>();
      _selectedMethodId = _methods.isNotEmpty ? _methods.first.id : null;
      _status = CheckoutStatus.ready;
    } catch (e) {
      _error = e.toString();
      _status = CheckoutStatus.error;
    }
    notifyListeners();
  }

  Order? _lastOrder;
  Order? get lastOrder => _lastOrder;

  Future<Order?> submit({required List<CartItem> items}) async {
    _status = CheckoutStatus.submitting;
    notifyListeners();
    // Debug: show selected payment method and inputs at submit time
    try {
      // debug info
      // ignore: avoid_print
      print('DEBUG: CheckoutProvider.submit selectedMethodId=$_selectedMethodId, address=$address, phone=$phone');
      int? id = await tokenManager.getUserIdFromAccessToken();
      id = 1;
      if (_selectedMethodId == null) throw Exception('اختر طريقة دفع');
      final Order created = await complete.execute(userId: id, paymentMethodId: _selectedMethodId!, address: address, phone: phone);
      _lastOrder = created;
      _status = CheckoutStatus.success;
    } catch (e, st) {
      // Debug: capture full error and stacktrace to diagnose mapping/parsing issues
      try {
        // ignore: avoid_print
        print('DEBUG: CheckoutProvider.submit caught error: $e');
        // ignore: avoid_print
        print(st);
      } catch (_) {}
      _error = e.toString();
      _status = CheckoutStatus.error;
      _lastOrder = null;
    }
    notifyListeners();
    return _lastOrder;
  }
}
