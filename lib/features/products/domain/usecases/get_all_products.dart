import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetAllProducts {
  final ProductsRepository repository;
  GetAllProducts(this.repository);

  Future<List<Product>> execute({bool activeOnly = false}) {
    return repository.getAll(activeOnly: activeOnly);
  }
}
