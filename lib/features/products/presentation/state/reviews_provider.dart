import 'package:flutter/material.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_reviews_by_product_id.dart';
import '../../domain/usecases/create_review.dart';
import '../../../../core/utils/token_manager.dart';

enum ReviewsStatus { initial, loading, loaded, error, submitting }

class ReviewsProvider with ChangeNotifier {
  final GetReviewsByProductId getReviews;
  final CreateReview createReview;
  final TokenManager? tokenManager;

  ReviewsProvider({required this.getReviews, required this.createReview, this.tokenManager});

  ReviewsStatus _status = ReviewsStatus.initial;
  ReviewsStatus get status => _status;

  String _error = '';
  String get error => _error;

  List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    final sum = _reviews.fold<int>(0, (s, r) => s + r.rating);
    return sum / _reviews.length;
  }

  int get reviewsCount => _reviews.length;

  Future<void> fetchForProduct(int productId) async {
    _status = ReviewsStatus.loading;
    notifyListeners();
    try {
      final list = await getReviews.execute(productId);
      _reviews = list;
      _status = ReviewsStatus.loaded;
    } catch (e) {
      _status = ReviewsStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> submitReview({required int productId, required int rating, String? comment}) async {
    _status = ReviewsStatus.submitting;
    notifyListeners();
    try {
      await createReview.execute(productId: productId, rating: rating, comment: comment);
      // refresh
      await fetchForProduct(productId);
    } catch (e) {
      _status = ReviewsStatus.error;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
