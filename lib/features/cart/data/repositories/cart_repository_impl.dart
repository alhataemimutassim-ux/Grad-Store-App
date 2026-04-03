import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remote;
  CartRepositoryImpl(this.remote);

  @override
  Future<void> add(int productId, int quantity) async {
    return await remote.create(productId, quantity);
  }

  @override
  Future<void> delete(int id) async {
    return await remote.delete(id);
  }

  @override
  Future<List<CartItem>> getAll() async {
    final models = await remote.getAll();
    return models.map((m) => CartItem(id: m.idCartItem, productId: m.productId, quantity: m.quantity, userId: m.userId)).toList();
  }

  @override
  Future<CartItem?> getById(int id) async {
    final m = await remote.getById(id);
    if (m == null) return null;
    return CartItem(id: m.idCartItem, productId: m.productId, quantity: m.quantity, userId: m.userId);
  }

  @override
  Future<void> update(int id, int productId, int quantity) async {
    return await remote.update(id, productId, quantity);
  }
}
