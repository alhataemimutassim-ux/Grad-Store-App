import '../repositories/reviews_repository.dart';
import '../entities/review.dart';

class GetReviewsByProductId {
  final ReviewsRepository repository;
  GetReviewsByProductId(this.repository);

  Future<List<Review>> execute(int productId) async {
    return await repository.getReviewsByProductId(productId);
  }
}
