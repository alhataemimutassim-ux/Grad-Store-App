import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_all_categories.dart';
import '../../domain/usecases/get_category_by_id.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/delete_category.dart';

enum CategoriesStatus { initial, loading, loaded, error }

class CategoriesProvider with ChangeNotifier {
  final GetAllCategories getAll;
  final GetCategoryById getById;
  final CreateCategory create;
  final UpdateCategory update;
  final DeleteCategory delete;

  CategoriesProvider({
    required this.getAll,
    required this.getById,
    required this.create,
    required this.update,
    required this.delete,
  });

  CategoriesStatus _status = CategoriesStatus.initial;
  CategoriesStatus get status => _status;

  String _error = '';
  String get error => _error;

  List<Category> _items = [];
  List<Category> get items => _items;

  Future<void> fetchAll() async {
    _status = CategoriesStatus.loading;
    notifyListeners();
    try {
      _items = await getAll.execute();
      _status = CategoriesStatus.loaded;
    } catch (e) {
      _error = _extractMessage(e);
      _status = CategoriesStatus.error;
    }
    notifyListeners();
  }

  Future<Category?> fetchById(int id) async {
    return await getById.execute(id);
  }

  Future<int> createCategory({required String name, String? description, File? imageFile}) async {
    // provider-level handles file -> localPath and passes to repo (implementation detail)
    // Here we call use-case which in turn calls repository. For simplicity, repository remote methods handle files.
    final req = CreateCategoryRequest(name: name, description: description, localImagePath: imageFile?.path);
    try {
      final id = await create.execute(req);
      return id;
    } catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  Future<void> updateCategory({required int id, required String name, String? description, File? imageFile}) async {
    final req = UpdateCategoryRequest(id: id, name: name, description: description, localImagePath: imageFile?.path);
    try {
      return await update.execute(req);
    } catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      return await delete.execute(id);
    } catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  String _extractMessage(Object? e) {
    var msg = e?.toString() ?? 'حدث خطأ غير معروف';
    // try to parse JSON message inside exception string
    try {
      // if message is a JSON object
      final parsed = jsonDecode(msg);
      if (parsed is Map && parsed['message'] != null) return parsed['message'].toString();
    } catch (_) {}
    return msg;
  }
}
