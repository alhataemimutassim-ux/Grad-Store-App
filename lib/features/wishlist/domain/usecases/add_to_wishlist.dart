import '../repositories/wishlist_repository.dart';

class AddToWishlist {
  final WishlistRepository repository;
  AddToWishlist(this.repository);

  Future<void> execute(int productId) async {
    return await repository.addToWishlist(productId);
  }
}
