import '../repositories/cart_repository.dart';

class UpdateCartItem {
  final CartRepository repository;
  UpdateCartItem(this.repository);

  Future<void> execute(int id, int productId, int quantity) {
    return repository.update(id, productId, quantity);
  }
}
