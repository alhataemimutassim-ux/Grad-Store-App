import '../repositories/categories_repository.dart';

class UpdateCategoryRequest {
  final int id;
  final String name;
  final String? description;
  final String? localImagePath;

  UpdateCategoryRequest({required this.id, required this.name, this.description, this.localImagePath});
}

class UpdateCategory {
  final CategoriesRepository repository;
  UpdateCategory(this.repository);

  Future<void> execute(UpdateCategoryRequest req) {
    return repository.update(req.id, name: req.name, description: req.description, imagePath: req.localImagePath);
  }
}
