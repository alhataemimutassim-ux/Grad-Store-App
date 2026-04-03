import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getAll();
  Future<CartItem?> getById(int id);
  Future<void> add(int productId, int quantity);
  Future<void> update(int id, int productId, int quantity);
  Future<void> delete(int id);
}
