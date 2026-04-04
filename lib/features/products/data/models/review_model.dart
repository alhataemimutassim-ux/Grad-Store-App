import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  ReviewModel({
    required super.id,
    required super.productId,
    super.userId,
    super.userName,
    required super.rating,
    super.comment,
    super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // defensive parsing
    final id = json['id'] ?? json['reviewId'] ?? json['idReview'] ?? 0;
    final productId = json['productId'] ?? json['productID'] ?? json['product_id'] ?? 0;
    final userId = json['userId'] ?? json['userID'] ?? json['user_id'];
    final userName = json['userName'] ?? json['username'] ?? json['authorName'];
    final ratingRaw = json['rating'] ?? json['rate'] ?? 0;
    final rating = ratingRaw is String ? int.tryParse(ratingRaw) ?? 0 : (ratingRaw as num).toInt();
    final comment = json['comment'] ?? json['body'] ?? json['text'];
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt']);
      } catch (_) {}
    }

    return ReviewModel(
      id: id is int ? id : int.tryParse(id.toString()) ?? 0,
      productId: productId is int ? productId : int.tryParse(productId.toString()) ?? 0,
      userId: userId is int ? userId : (userId != null ? int.tryParse(userId.toString()) : null),
      userName: userName?.toString(),
      rating: rating,
      comment: comment?.toString(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
      'rating': rating,
      if (comment != null) 'comment': comment,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
