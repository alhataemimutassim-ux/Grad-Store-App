import 'package:flutter/material.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/usecases/get_my_wishlist.dart';
import '../../domain/usecases/add_to_wishlist.dart';
import '../../domain/usecases/remove_from_wishlist.dart';
import '../../domain/usecases/toggle_wishlist.dart';

enum WishlistStatus { initial, loading, loaded, error, submitting }

class WishlistProvider with ChangeNotifier {
  final GetMyWishlist getMyWishlist;
  final AddToWishlist addToWishlist;
  final RemoveFromWishlist removeFromWishlist;
  final ToggleWishlist toggleWishlist;

  WishlistProvider({
    required this.getMyWishlist,
    required this.addToWishlist,
    required this.removeFromWishlist,
    required this.toggleWishlist,
  });

  WishlistStatus _status = WishlistStatus.initial;
  WishlistStatus get status => _status;

  String _error = '';
  String get error => _error;

  List<WishlistItem> _items = [];
  List<WishlistItem> get items => _items;

  Set<int> _productIds = {};

  Future<void> fetchMyWishlist() async {
    _status = WishlistStatus.loading;
    notifyListeners();
    try {
      final list = await getMyWishlist.execute();
      _items = list;
      _productIds = _items.map((e) => e.productId).toSet();
      _status = WishlistStatus.loaded;
    } catch (e) {
      _status = WishlistStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  bool isInWishlist(int productId) => _productIds.contains(productId);

  Future<void> add(int productId) async {
    _status = WishlistStatus.submitting;
    notifyListeners();
    try {
      await addToWishlist.execute(productId);
      await fetchMyWishlist();
    } catch (e) {
      _status = WishlistStatus.error;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(int productId) async {
    _status = WishlistStatus.submitting;
    notifyListeners();
    try {
      await removeFromWishlist.execute(productId);
      await fetchMyWishlist();
    } catch (e) {
      _status = WishlistStatus.error;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> toggle(int productId) async {
    _status = WishlistStatus.submitting;
    notifyListeners();
    try {
      final added = await toggleWishlist.execute(productId);
      await fetchMyWishlist();
      return added;
    } catch (e) {
      _status = WishlistStatus.error;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
