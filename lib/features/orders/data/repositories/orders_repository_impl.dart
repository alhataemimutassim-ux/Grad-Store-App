import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../datasources/orders_remote_datasource.dart';

abstract class OrdersRepository {
  Future<List<Order>> getMyOrders(int userId);
}

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remote;

  OrdersRepositoryImpl(this.remote);

  @override
  Future<List<Order>> getMyOrders(int userId) async {
    final models = await remote.getMyOrders(userId);
    return models
        .map((m) => Order(
              id: m.idOrder,
              orderDate: DateTime.parse(m.orderDate),
              statusName: m.statusName,
              totalPrice: m.totalPrice,
              items: m.items
                  .map((i) => OrderItem(
                        productId: i.productId,
                        productName: i.productName,
                        unitPrice: i.unitPrice,
                        quantity: i.quantity,
                        total: i.total,
                        productImage: i.productImage,
                        sellerId: i.sellerId,
                        sellerName: i.sellerName,
                      ))
                  .toList(),
            ))
        .toList();
  }
}
