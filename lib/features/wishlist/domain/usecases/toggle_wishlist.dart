import '../repositories/wishlist_repository.dart';

class ToggleWishlist {
  final WishlistRepository repository;
  ToggleWishlist(this.repository);

  Future<bool> execute(int productId) async {
    return await repository.toggleWishlist(productId);
  }
}
