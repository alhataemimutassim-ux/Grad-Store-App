import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class GetCartItemById {
  final CartRepository repository;
  GetCartItemById(this.repository);

  Future<CartItem?> execute(int id) {
    return repository.getById(id);
  }
}
