import '../entities/order.dart';
import '../../data/repositories/orders_repository_impl.dart';

class GetMyOrders {
  final OrdersRepository repository;

  GetMyOrders(this.repository);

  Future<List<Order>> execute(int userId) => repository.getMyOrders(userId);
}
