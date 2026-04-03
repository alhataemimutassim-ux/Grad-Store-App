import '../entities/wishlist_item.dart';

abstract class WishlistRepository {
  Future<List<WishlistItem>> getMyWishlist();
  Future<void> addToWishlist(int productId);
  Future<void> removeFromWishlist(int productId);
  Future<bool> toggleWishlist(int productId);
}
