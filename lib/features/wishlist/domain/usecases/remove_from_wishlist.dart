import '../repositories/wishlist_repository.dart';

class RemoveFromWishlist {
  final WishlistRepository repository;
  RemoveFromWishlist(this.repository);

  Future<void> execute(int productId) async {
    return await repository.removeFromWishlist(productId);
  }
}
