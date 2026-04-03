import '../repositories/checkout_repository.dart';
import '../../data/models/payment_method_model.dart';

class GetPaymentMethods {
  final CheckoutRepository repository;
  GetPaymentMethods(this.repository);

  Future<List<PaymentMethodModel>> execute() {
    return repository.getPaymentMethods();
  }
}
