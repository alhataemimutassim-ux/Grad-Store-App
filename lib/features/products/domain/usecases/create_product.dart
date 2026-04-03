import '../repositories/products_repository.dart';

class CreateProduct {
  final ProductsRepository repository;
  CreateProduct(this.repository);

  Future<int> execute(CreateProductRequest request) {
    return repository.create(request);
  }
}
