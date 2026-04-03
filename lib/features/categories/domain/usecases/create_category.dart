import '../repositories/categories_repository.dart';

class CreateCategoryRequest {
  final String name;
  final String? description;
  final String? localImagePath; // local file path

  CreateCategoryRequest({required this.name, this.description, this.localImagePath});
}

class CreateCategory {
  final CategoriesRepository repository;
  CreateCategory(this.repository);

  Future<int> execute(CreateCategoryRequest req) {
    return repository.create(name: req.name, description: req.description, imagePath: req.localImagePath);
  }
}
