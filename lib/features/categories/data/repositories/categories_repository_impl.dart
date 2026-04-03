import 'dart:io';

import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_datasource.dart';
import '../../domain/entities/category.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource remote;

  CategoriesRepositoryImpl(this.remote);

  @override
  Future<int> create({required String name, String? description, String? imagePath}) async {
    final File? f = imagePath != null ? File(imagePath) : null;
    return await remote.create(name: name, description: description, imageFile: f);
  }

  @override
  Future<void> delete(int id) async {
    await remote.delete(id);
  }

  @override
  Future<List<Category>> getAll() async {
    final models = await remote.getAll();
    return models.map((m) => m as Category).toList();
  }

  @override
  Future<Category?> getById(int id) async {
    return await remote.getById(id);
  }

  @override
  Future<void> update(int id, {required String name, String? description, String? imagePath}) async {
    final File? f = imagePath != null ? File(imagePath) : null;
    await remote.update(id, name: name, description: description, imageFile: f);
  }
}
