import '../repositories/products_repository.dart';

class DeleteProduct {
  final ProductsRepository repository;
  DeleteProduct(this.repository);

  Future<void> execute(int id) {
    return repository.delete(id);
  }
}
