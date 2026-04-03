import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/entities/wishlist_item.dart';
import '../datasources/wishlist_remote_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remote;
  WishlistRepositoryImpl(this.remote);

  @override
  Future<void> addToWishlist(int productId) async => await remote.addToWishlist(productId);

  @override
  Future<List<WishlistItem>> getMyWishlist() async {
    final list = await remote.getMyWishlist();
    return list.map((e) => WishlistItem(
          id: e.id,
          productId: e.productId,
          name: e.name,
          price: e.price,
          discount: e.discount,
          mainImage: e.mainImage,
          qty: e.qty,
          reviewsCount: e.reviewsCount,
          averageRating: e.averageRating,
        )).toList();
  }

  @override
  Future<void> removeFromWishlist(int productId) async => await remote.removeFromWishlist(productId);

  @override
  Future<bool> toggleWishlist(int productId) async => await remote.toggleWishlist(productId);
}
