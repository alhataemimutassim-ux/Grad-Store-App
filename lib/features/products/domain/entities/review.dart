class Review {
  final int id;
  final int productId;
  final int? userId;
  final String? userName;
  final int rating; // 1..5
  final String? comment;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.productId,
    this.userId,
    this.userName,
    required this.rating,
    this.comment,
    this.createdAt,
  });
}
