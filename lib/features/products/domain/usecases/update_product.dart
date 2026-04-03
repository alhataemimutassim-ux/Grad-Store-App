import '../repositories/products_repository.dart';

class UpdateProduct {
  final ProductsRepository repository;
  UpdateProduct(this.repository);

  Future<void> execute(UpdateProductRequest request) {
    return repository.update(request);
  }
}
