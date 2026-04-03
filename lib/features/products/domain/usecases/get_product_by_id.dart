import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductById {
  final ProductsRepository repository;
  GetProductById(this.repository);

  Future<Product?> execute(int id) {
    return repository.getById(id);
  }
}
