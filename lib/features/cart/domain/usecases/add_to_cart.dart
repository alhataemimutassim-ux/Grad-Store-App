import '../repositories/cart_repository.dart';

class AddToCart {
  final CartRepository repository;
  AddToCart(this.repository);

  Future<void> execute(int productId, int quantity) {
    return repository.add(productId, quantity);
  }
}
