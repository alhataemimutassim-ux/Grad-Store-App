class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int qty;
  final double discount;

  final String? type;
  final String? brand;
  final String? countryOfOrigin;

  final bool isActive;
  final String? mainImage;

  final int sellerId;
  final String? sellerName;
  final String? sellerPhone;

  final String? storeName;
  final String? storeLocation;
  final double? latitude;
  final double? longitude;

  final int categoryId;
  final String? categoryName;
  final double? averageRating;
  final int? reviewsCount;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.qty,
    required this.discount,
    this.type,
    this.brand,
    this.countryOfOrigin,
    required this.isActive,
    this.mainImage,
    required this.sellerId,
    this.sellerName,
    this.sellerPhone,
    this.storeName,
    this.storeLocation,
    this.latitude,
    this.longitude,
    required this.categoryId,
    this.categoryName,
    this.averageRating,
    this.reviewsCount,
  });
}
