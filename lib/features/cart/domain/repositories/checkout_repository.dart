import '../../data/models/payment_method_model.dart' as pm;
import '../../../../features/orders/domain/entities/order.dart';

abstract class CheckoutRepository {
  Future<List<pm.PaymentMethodModel>> getPaymentMethods();
  Future<Order> completeCheckout({required int paymentMethodId, required String address, required String phone});
}
