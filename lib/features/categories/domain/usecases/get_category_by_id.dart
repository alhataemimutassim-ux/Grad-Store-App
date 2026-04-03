import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class GetCategoryById {
  final CategoriesRepository repository;
  GetCategoryById(this.repository);

  Future<Category?> execute(int id) {
    return repository.getById(id);
  }
}
