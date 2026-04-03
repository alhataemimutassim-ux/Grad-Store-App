import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class GetAllCategories {
  final CategoriesRepository repository;
  GetAllCategories(this.repository);

  Future<List<Category>> execute() {
    return repository.getAll();
  }
}
