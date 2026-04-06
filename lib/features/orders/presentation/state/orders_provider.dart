import 'package:flutter/material.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/usecases/get_my_orders.dart';
import '../../../../core/utils/token_manager.dart';

enum OrdersStatus { initial, loading, loaded, error }

class OrdersProvider with ChangeNotifier {
  final GetMyOrders getMyOrders;
  final TokenManager tokenManager;

  OrdersProvider({required this.getMyOrders, required this.tokenManager});

  OrdersStatus _status = OrdersStatus.initial;
  OrdersStatus get status => _status;

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  String _error = '';
  String get error => _error;

  Future<void> fetchMyOrders() async {
    _status = OrdersStatus.loading;
    notifyListeners();
    try {
      final id = await tokenManager.getUserIdFromAccessToken() ?? 0;
      final res = await getMyOrders.execute(id);
      _orders = res;
      _status = OrdersStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = OrdersStatus.error;
    }
    notifyListeners();
  }

  Future<void> cancelOrder(int orderId) async {
    // محاكاة الإلغاء في الواجهة محلياً ريثما يتم توفير رابط (Endpoint) رسمي للإلغاء من السيرفر
    // البحث عن الطلب وتحديث حالته محلياً لتصبح ملغي
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = _orders[index];
      // إنشاء نسخة جديدة من الطلب بنفس البيانات لكن بحالة ملغي
      _orders[index] = Order(
        id: oldOrder.id,
        orderDate: oldOrder.orderDate,
        statusName: 'ملغي',
        totalPrice: oldOrder.totalPrice,
        items: oldOrder.items,
      );
      notifyListeners();
    }
  }
}

