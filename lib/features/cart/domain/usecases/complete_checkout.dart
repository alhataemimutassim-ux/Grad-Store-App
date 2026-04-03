import '../repositories/checkout_repository.dart';
import '../../../../features/orders/domain/entities/order.dart';

class CompleteCheckout {
  final CheckoutRepository repository;
  CompleteCheckout(this.repository);

  Future<Order> execute({required int userId, required int paymentMethodId, required String address, required String phone}) {
    try {
      // ignore: avoid_print
      print('DEBUG: CompleteCheckout.execute paymentMethodId=$paymentMethodId');
    } catch (_) {}
    return repository.completeCheckout(paymentMethodId: paymentMethodId, address: address, phone: phone);
  }
}
