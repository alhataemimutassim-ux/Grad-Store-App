import '../entities/review.dart';

abstract class ReviewsRepository {
  Future<List<Review>> getReviewsByProductId(int productId);
  Future<Review> createReview({required int productId, required int rating, String? comment});
}
