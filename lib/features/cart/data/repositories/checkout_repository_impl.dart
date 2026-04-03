import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_datasource.dart';
import '../models/payment_method_model.dart';
import '../../../orders/data/models/order_model.dart' as om;
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_item.dart' as oi;

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remote;
  CheckoutRepositoryImpl(this.remote);

  @override
  Future<Order> completeCheckout({required int paymentMethodId, required String address, required String phone}) async {
    try {
      // ignore: avoid_print
      print('DEBUG: CheckoutRepositoryImpl.completeCheckout paymentMethodId=$paymentMethodId');
    } catch (_) {}
    final om.OrderModel model = await remote.completeCheckout(paymentMethodId: paymentMethodId, address: address, phone: phone);
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(model.orderDate);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final items = model.items;

    return Order(
      id: model.idOrder,
      orderDate: parsedDate,
      statusName: model.statusName,
      totalPrice: model.totalPrice,
    items: items
      .map((i) => oi.OrderItem(
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
    );
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    return await remote.getPaymentMethods();
  }
}
