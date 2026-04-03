import '../../domain/entities/wishlist_item.dart';

class WishlistItemModel extends WishlistItem {
  WishlistItemModel({
    required super.id,
    required super.productId,
    super.name,
    super.price,
    super.discount,
    super.mainImage,
    super.qty,
    super.reviewsCount,
    super.averageRating,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
  final id = json['idWishlist'] ?? json['IdWishlist'] ?? json['id'] ?? json['Id'] ?? 0;
  // Product info may be nested under 'product' or 'Product' or present at the top-level.
  final prodRaw = json['product'] ?? json['Product'];
  final prod = prodRaw is Map<String, dynamic> ? prodRaw : <String, dynamic>{};
  final productIdRaw = json['productId'] ?? json['ProductId'] ?? json['IdProduct'] ?? json['idProduct'] ?? (prod['idProduct'] ?? prod['IdProduct'] ?? prod['productId'] ?? prod['id'] ?? prod['Id']);
  final productId = productIdRaw ?? 0;
  final name = prod['name'] ?? prod['Name'];
  final priceRaw = prod['Price'] ?? prod['price'] ?? json['price'] ?? json['Price'];
    final price = priceRaw == null ? null : (priceRaw is String ? double.tryParse(priceRaw) : (priceRaw as num).toDouble());
    final discountRaw = prod['Discount'] ?? prod['discount'];
    final discount = discountRaw == null ? null : (discountRaw is String ? double.tryParse(discountRaw) : (discountRaw as num).toDouble());
    final mainImage = prod['MainImage'] ?? prod['mainImage'] ?? prod['image'];
    final qty = prod['Qty'] ?? prod['qty'];
    final reviewsCount = prod['ReviewsCount'] ?? prod['reviewsCount'];
    final avgRaw = prod['AverageRating'] ?? prod['averageRating'] ?? prod['Average'] ?? 0;
    final averageRating = avgRaw == null ? null : (avgRaw is String ? double.tryParse(avgRaw) : (avgRaw as num).toDouble());

    return WishlistItemModel(
      id: id is int ? id : int.tryParse(id.toString()) ?? 0,
      productId: productId is int ? productId : int.tryParse(productId.toString()) ?? 0,
      name: name?.toString(),
      price: price,
      discount: discount,
      mainImage: mainImage?.toString(),
      qty: qty is int ? qty : (qty != null ? int.tryParse(qty.toString()) : null),
      reviewsCount: reviewsCount is int ? reviewsCount : (reviewsCount != null ? int.tryParse(reviewsCount.toString()) : null),
      averageRating: averageRating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdWishlist': id,
      'Product': {
        'IdProduct': productId,
        if (name != null) 'Name': name,
        if (price != null) 'Price': price,
        if (discount != null) 'Discount': discount,
        if (mainImage != null) 'MainImage': mainImage,
        if (qty != null) 'Qty': qty,
        if (reviewsCount != null) 'ReviewsCount': reviewsCount,
        if (averageRating != null) 'AverageRating': averageRating,
      }
    };
  }
}
