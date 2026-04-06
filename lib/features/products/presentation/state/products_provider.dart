import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grad_store_app/core/utils/token_manager.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/get_product_by_id.dart';
import '../../domain/usecases/get_admin_products.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/toggle_active_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/repositories/products_repository.dart';

enum ProductsStatus { initial, loading, loaded, error }

class ProductsProvider with ChangeNotifier {
  final GetAllProducts getAll;
  final GetProductById getById;
  final GetAdminProducts getAdminProducts;
  final CreateProduct create;
  final UpdateProduct update;
  final ToggleActiveProduct toggleActive;
  final DeleteProduct delete;

  List<Product> _items = [];
  List<Product> get items => _items;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Product> _searchResults = [];
  List<Product> get searchResults => _searchResults;

  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  ProductsProvider({
    required this.getAll,
    required this.getById,
    required this.getAdminProducts,
    required this.create,
    required this.update,
    required this.toggleActive,
    required this.delete,
    required TokenManager tokenManager,
  }) {
    loadRecentSearches();
  }

  ProductsStatus _status = ProductsStatus.initial;
  ProductsStatus get status => _status;

  String _error = '';
  String get error => _error;

  Future<void> fetchAll({bool activeOnly = false}) async {
    _status = ProductsStatus.loading;
    notifyListeners();
    try {
      _items = await getAll.execute(activeOnly: activeOnly);
      _status = ProductsStatus.loaded;
    } catch (e) {
      _error = _extractMessage(e);
      _status = ProductsStatus.error;
    }
    notifyListeners();
  }

  Future<Product?> fetchById(int id) async {
    return await getById.execute(id);
  }

  // ===== Search Logic =====
  void searchProducts(String query) {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = [];
    } else {
      final lowerQuery = query.toLowerCase();
      _searchResults = _items.where((p) {
        return p.name.toLowerCase().contains(lowerQuery) ||
            (p.description?.toLowerCase().contains(lowerQuery) ?? false) ||
            (p.brand?.toLowerCase().contains(lowerQuery) ?? false) ||
            (p.type?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches.removeWhere((q) => q.toLowerCase() == query.trim().toLowerCase());
      _recentSearches.insert(0, query.trim());
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
      await prefs.setStringList('recentSearches', _recentSearches);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recentSearches');
      _recentSearches = [];
      notifyListeners();
    } catch (_) {}
  }

  Future<List<Product>> fetchAdminProducts(int adminId) async {
    return await getAdminProducts.execute(adminId);
  }

  Future<int> createProduct({required String name, String? description, required double price, required int qty, required double discount, String? type, String? brand, String? countryOfOrigin, required int categoryId, required int sellerId, String? localImagePath, Uint8List? imageBytes, String? imageFilename}) async {
    final req = CreateProductRequest(
      name: name,
      description: description,
      price: price,
      qty: qty,
      discount: discount,
      type: type,
      brand: brand,
      countryOfOrigin: countryOfOrigin,
      categoryId: categoryId,
      sellerId: sellerId,
      localImagePath: localImagePath,
      imageBytes: imageBytes,
      imageFilename: imageFilename,
    );
    try {
      final id = await create.execute(req);
      return id;
    } catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  Future<void> updateProduct({required int id, required String name, String? description, required double price, required int qty, required double discount, String? type, String? brand, String? countryOfOrigin, required int categoryId, String? localImagePath, Uint8List? imageBytes, String? imageFilename}) async {
    final req = UpdateProductRequest(
      id: id,
      name: name,
      description: description,
      price: price,
      qty: qty,
      discount: discount,
      type: type,
      brand: brand,
      countryOfOrigin: countryOfOrigin,
      categoryId: categoryId,
      localImagePath: localImagePath,
      imageBytes: imageBytes,
      imageFilename: imageFilename,
    );
    try {
      return await update.execute(req);
    } catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  Future<void> toggleActiveProduct(int id) async {
    try {
      return await toggleActive.execute(id);
    } catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      return await delete.execute(id);
    } catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  String _extractMessage(Object? e) {
    var msg = e?.toString() ?? 'حدث خطأ غير معروف';
    try {
      final parsed = jsonDecode(msg);
      if (parsed is Map && parsed['message'] != null) return parsed['message'].toString();
    } catch (_) {}
    return msg;
  }
}
