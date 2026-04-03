class Offer {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final double price;
  final double discount;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final bool status;
  final String? mainImage;
  final double? averageRating;
  final int? reviewsCount;

  Offer({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.discount,
    this.startDateTime,
    this.endDateTime,
    required this.status,
    this.mainImage,
    this.averageRating,
    this.reviewsCount,
  });
}
