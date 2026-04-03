import '../repositories/categories_repository.dart';

class DeleteCategory {
  final CategoriesRepository repository;
  DeleteCategory(this.repository);

  Future<void> execute(int id) {
    return repository.delete(id);
  }
}
