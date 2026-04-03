import '../../domain/entities/category.dart';

abstract class CategoriesRepository {
  Future<List<Category>> getAll();
  Future<Category?> getById(int id);
  Future<int> create({required String name, String? description, String? imagePath});
  Future<void> update(int id, {required String name, String? description, String? imagePath});
  Future<void> delete(int id);
}
