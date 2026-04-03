import '../repositories/products_repository.dart';

class ToggleActiveProduct {
  final ProductsRepository repository;
  ToggleActiveProduct(this.repository);

  Future<void> execute(int id) {
    return repository.toggleActive(id);
  }
}
