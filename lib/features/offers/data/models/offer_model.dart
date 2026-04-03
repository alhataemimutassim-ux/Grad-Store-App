import '../../domain/entities/offer.dart';

class OfferModel extends Offer {
  OfferModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productImage,
    required super.price,
    required super.discount,
    super.startDateTime,
    super.endDateTime,
    required super.status,
    super.mainImage,
    super.averageRating,
    super.reviewsCount,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    DateTime? parseDate(String? s) => s == null ? null : DateTime.tryParse(s);

    return OfferModel(
      id: (json['idOffer'] ?? json['id'] ?? 0) is int ? (json['idOffer'] ?? json['id'] ?? 0) : int.tryParse((json['idOffer'] ?? json['id']).toString()) ?? 0,
      productId: (json['productId'] ?? 0) is int ? (json['productId'] ?? 0) : int.tryParse((json['productId'] ?? 0).toString()) ?? 0,
      productName: (json['productName'] ?? json['product_name'] ?? '').toString(),
      productImage: (json['productImage'] ?? json['product_image'] ?? json['mainImage'])?.toString(),
      price: parseDouble(json['price']),
      discount: parseDouble(json['discount']),
      startDateTime: parseDate(json['startDateTime']?.toString()),
      endDateTime: parseDate(json['endDateTime']?.toString()),
      status: (json['status'] ?? false) is bool ? (json['status'] ?? false) : (json['status'].toString().toLowerCase() == 'true'),
      mainImage: json['mainImage']?.toString(),
      averageRating: json['averageRating'] == null ? null : parseDouble(json['averageRating']),
      reviewsCount: json['reviewsCount'] is int ? json['reviewsCount'] : (json['reviewsCount'] != null ? int.tryParse(json['reviewsCount'].toString()) : null),
    );
  }
}
