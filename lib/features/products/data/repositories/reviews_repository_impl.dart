import '../../domain/repositories/reviews_repository.dart';
import '../../domain/entities/review.dart';
import '../datasources/reviews_remote_datasource.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource remote;

  ReviewsRepositoryImpl(this.remote);

  @override
  Future<List<Review>> getReviewsByProductId(int productId) async {
    return await remote.getReviewsByProductId(productId);
  }

  @override
  Future<Review> createReview({required int productId, required int rating, String? comment}) async {
    return await remote.createReview(productId: productId, rating: rating, comment: comment);
  }
}
