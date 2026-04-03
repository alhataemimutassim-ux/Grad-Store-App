class WishlistItem {
  final int id; // IdWishlist
  final int productId;
  final String? name;
  final double? price;
  final double? discount;
  final String? mainImage;
  final int? qty;
  final int? reviewsCount;
  final double? averageRating;

  WishlistItem({
    required this.id,
    required this.productId,
    this.name,
    this.price,
    this.discount,
    this.mainImage,
    this.qty,
    this.reviewsCount,
    this.averageRating,
  });
}
