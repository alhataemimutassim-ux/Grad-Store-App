import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/get_cart_items.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/update_cart_item.dart';
import '../../domain/usecases/delete_cart_item.dart';
import '../../domain/usecases/get_cart_item_by_id.dart';

enum CartStatus { initial, loading, loaded, error }

class CartProvider with ChangeNotifier {
  final GetCartItems getAll;
  final AddToCart add;
  final UpdateCartItem update;
  final DeleteCartItem delete;
  final GetCartItemById getById;
  final http.Client client;
  final TokenManager tokenManager;

  CartProvider({required this.getAll, required this.add, required this.update, required this.delete, required this.getById, required this.client, required this.tokenManager});

  CartStatus _status = CartStatus.initial;
  CartStatus get status => _status;

  String _error = '';
  String get error => _error;

  List<CartItem> _items = [];
  List<CartItem> get items => _items;
  final Map<int, ProductModel> _productCache = {};
  Map<int, ProductModel> get productCache => _productCache;
  bool _loadingProducts = false;
  bool get loadingProducts => _loadingProducts;

  double get totalAmount {
    double sum = 0;
    for (var item in _items) {
      final p = _productCache[item.productId];
      if (p != null) {
        final price = p.price;
        final disc = p.discount;
        sum += (price - (price * disc / 100)) * item.quantity;
      }
    }
    return sum;
  }

  Future<void> fetchAll() async {
    _status = CartStatus.loading;
    notifyListeners();
    try {
      _items = await getAll.execute();
      _status = CartStatus.loaded;
      // after fetching items, batch fetch product details
      _fetchProductsForItems();
    } catch (e) {
      _error = e.toString();
      _status = CartStatus.error;
    }
    notifyListeners();
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    try {
      await add.execute(productId, quantity);
      await fetchAll();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> changeQuantity(int cartItemId, int newQty) async {
    try {
      final item = _items.firstWhere((i) => i.id == cartItemId);
      await update.execute(cartItemId, item.productId, newQty);
      await fetchAll();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> remove(int cartItemId) async {
    try {
      await delete.execute(cartItemId);
      await fetchAll();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // helper to fetch product details quickly (used by UI)
  Future<ProductModel?> fetchProductById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/products/$id');
    final token = await tokenManager.getAccessToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await client.get(uri, headers: headers);
    if (res.statusCode != 200) return null;
    final Map<String, dynamic> json = jsonDecode(res.body);
    return ProductModel.fromJson(json);
  }

  Future<void> _fetchProductsForItems() async {
    final ids = _items.map((e) => e.productId).toSet().toList();
    if (ids.isEmpty) return;
    _loadingProducts = true;
    notifyListeners();
    try {
      final futures = ids.map((id) async {
        final p = await fetchProductById(id);
        if (p != null) _productCache[id] = p;
      });
      await Future.wait(futures);
    } catch (_) {}
    _loadingProducts = false;
    notifyListeners();
  }

  Future<double> computeTotal() async {
    double sum = 0;
    // ensure cache has all products
    final missing = _items.map((e) => e.productId).where((id) => !_productCache.containsKey(id)).toSet().toList();
    if (missing.isNotEmpty) {
      final futures = missing.map((id) async {
        final p = await fetchProductById(id);
        if (p != null) _productCache[id] = p;
      });
      await Future.wait(futures);
    }
    for (var item in _items) {
      final p = _productCache[item.productId];
      if (p != null) {
        final price = p.price;
        final disc = p.discount;
        sum += (price - (price * disc / 100)) * item.quantity;
      }
    }
    return sum;
  }
}
