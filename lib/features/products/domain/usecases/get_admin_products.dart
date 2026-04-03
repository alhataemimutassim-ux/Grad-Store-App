import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetAdminProducts {
  final ProductsRepository repository;
  GetAdminProducts(this.repository);

  Future<List<Product>> execute(int adminId) {
    return repository.getAdminProducts(adminId);
  }
}
