import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/seller_model.dart';

abstract class SellersRemoteDataSource {
  Future<List<SellerModel>> getAllSellers();
  Future<SellerModel?> getSellerById(int id);
}

class SellersRemoteDataSourceImpl implements SellersRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  SellersRemoteDataSourceImpl(this.client, {this.tokenManager});

  @override
  Future<List<SellerModel>> getAllSellers() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/sellerprofiles/full/all');
    final headers = {'Content-Type': 'application/json'};
    try {
      final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    } catch (_) {}

    final resp = await client.get(uri, headers: headers);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body);
      if (body is List) {
        return body.map((e) => SellerModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (body is Map && body['data'] is List) {
        return (body['data'] as List).map((e) => SellerModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }
    throw Exception('Failed to load sellers: ${resp.statusCode} ${resp.body}');
  }

  @override
  Future<SellerModel?> getSellerById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/sellerprofiles/full/$id');
    final headers = {'Content-Type': 'application/json'};
    try {
      final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    } catch (_) {}

    final resp = await client.get(uri, headers: headers);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body);
      if (body is Map) return SellerModel.fromJson(body as Map<String, dynamic>);
      return null;
    }
    throw Exception('Failed to load seller $id: ${resp.statusCode} ${resp.body}');
  }
}
