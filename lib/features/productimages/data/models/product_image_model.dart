import '../../domain/entities/product_image.dart';

class ProductImageModel extends ProductImage {
  ProductImageModel({
    required super.id,
    super.productId,
    super.image,
    super.createdAt,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['idProductImage'] ?? json['id'] ?? 0,
      productId: json['productId'] ?? json['productID'],
      image: json['image'] ?? json['Image'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProductImage': id,
      'productId': productId,
      'image': image,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
