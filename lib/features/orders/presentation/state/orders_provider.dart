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
      final id = 1;
      // NOTE: `id` here is a placeholder; in real flow fetch from TokenManager or auth provider.
      final res = await getMyOrders.execute(id);
      _orders = res;
      _status = OrdersStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = OrdersStatus.error;
    }
    notifyListeners();
  }
}
