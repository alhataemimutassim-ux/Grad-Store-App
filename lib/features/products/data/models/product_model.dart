import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    required super.qty,
    required super.discount,
    super.type,
    super.brand,
    super.countryOfOrigin,
    required super.isActive,
    super.mainImage,
    required super.sellerId,
    super.sellerName,
    super.sellerPhone,
    super.storeName,
    super.storeLocation,
    super.latitude,
    super.longitude,
    required super.categoryId,
    super.categoryName,
    super.averageRating,
    super.reviewsCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['idProduct'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] ?? 0.0),
      qty: json['qty'] ?? 0,
      discount: (json['discount'] is int) ? (json['discount'] as int).toDouble() : (json['discount'] ?? 0.0),
      type: json['type'],
      brand: json['brand'],
      countryOfOrigin: json['countryOfOrigin'],
      isActive: json['isActive'] ?? false,
      mainImage: json['mainImage'] ?? json['image'],
      sellerId: json['sellerId'] ?? 0,
      sellerName: json['sellerName'],
      sellerPhone: json['sellerPhone'],
      storeName: json['storeName'],
      storeLocation: json['storeLocation'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'],
      averageRating: (() {
        final avg = json['averageRating'] ?? json['AverageRating'];
        if (avg == null) return null;
        return (avg is String) ? double.tryParse(avg) : (avg as num).toDouble();
      })(),
  reviewsCount: json['reviewsCount'] ?? json['ReviewsCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProduct': id,
      'name': name,
      'description': description,
      'price': price,
      'qty': qty,
      'discount': discount,
      'type': type,
      'brand': brand,
      'countryOfOrigin': countryOfOrigin,
      'isActive': isActive,
      'mainImage': mainImage,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'storeName': storeName,
      'storeLocation': storeLocation,
      'latitude': latitude,
      'longitude': longitude,
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
}
