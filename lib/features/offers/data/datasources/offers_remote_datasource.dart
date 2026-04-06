import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/offer_model.dart';

abstract class OffersRemoteDataSource {
  Future<List<OfferModel>> getPublicOffers();
}

class OffersRemoteDataSourceImpl implements OffersRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  OffersRemoteDataSourceImpl(this.client, {this.tokenManager});

  @override
  Future<List<OfferModel>> getPublicOffers() async {
    // نستخدم /offers بدلاً من /offers/public لأن public يرجع قائمة فارغة
    final uri = Uri.parse('${ApiConstants.baseUrl}/offers');
    final headers = {'Content-Type': 'application/json'};
    try {
      final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    } catch (_) {}

    final resp = await client.get(uri, headers: headers);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = jsonDecode(resp.body);
      if (body is List) {
        return body.map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (body is Map && body['data'] is List) {
        return (body['data'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }
    // إذا 401 (غير مسجل) نرجع قائمة فارغة بدلاً من رمي استثناء
    if (resp.statusCode == 401) return [];
    throw Exception('Failed to load offers: ${resp.statusCode} ${resp.body}');
  }
}
