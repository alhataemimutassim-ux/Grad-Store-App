import '../repositories/cart_repository.dart';

class DeleteCartItem {
  final CartRepository repository;
  DeleteCartItem(this.repository);

  Future<void> execute(int id) {
    return repository.delete(id);
  }
}
