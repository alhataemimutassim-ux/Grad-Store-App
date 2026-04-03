import '../repositories/reviews_repository.dart';
import '../entities/review.dart';

class CreateReview {
  final ReviewsRepository repository;
  CreateReview(this.repository);

  Future<Review> execute({required int productId, required int rating, String? comment}) async {
    return await repository.createReview(productId: productId, rating: rating, comment: comment);
  }
}
