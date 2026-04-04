import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/review_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<ReviewModel>> getReviewsByProductId(int productId);
  Future<ReviewModel> createReview({required int productId, required int rating, String? comment});
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  ReviewsRemoteDataSourceImpl(this.client, {this.tokenManager});

  @override
  Future<List<ReviewModel>> getReviewsByProductId(int productId) async {
    // API returns a single review for /reviews/$id, so we fetch all reviews and filter by productId
    final uri = Uri.parse('${ApiConstants.baseUrl}/reviews');
    final resp = await client.get(uri);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body);
      if (body is List) {
        return body
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .where((review) => review.productId == productId)
            .toList();
      }
      // maybe wrapped
      if (body is Map && body['data'] is List) {
        return (body['data'] as List)
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .where((review) => review.productId == productId)
            .toList();
      }
      return [];
    }
    throw Exception('Failed to load reviews: ${resp.statusCode}');
  }

  @override
  Future<ReviewModel> createReview({required int productId, required int rating, String? comment}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/reviews');
    final headers = {'Content-Type': 'application/json'};
  final token = await tokenManager?.getAccessToken();
  if (token != null) headers['Authorization'] = 'Bearer $token';

    final Map<String, dynamic> payload = {
      'productId': productId,
      'rating': rating,
    };
    if (comment != null) payload['comment'] = comment;
    final body = json.encode(payload);

    final resp = await client.post(uri, headers: headers, body: body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final parsed = json.decode(resp.body);
      if (parsed is Map<String, dynamic>) return ReviewModel.fromJson(parsed);
      // if API wraps created resource
      if (parsed is Map && parsed['data'] is Map) return ReviewModel.fromJson(parsed['data'] as Map<String, dynamic>);
      throw Exception('Unexpected create review response');
    }
    throw Exception('Failed to create review: ${resp.statusCode} ${resp.body}');
  }
}
