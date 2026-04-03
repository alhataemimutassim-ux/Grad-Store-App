import '../repositories/wishlist_repository.dart';
import '../entities/wishlist_item.dart';

class GetMyWishlist {
  final WishlistRepository repository;
  GetMyWishlist(this.repository);

  Future<List<WishlistItem>> execute() async {
    return await repository.getMyWishlist();
  }
}
