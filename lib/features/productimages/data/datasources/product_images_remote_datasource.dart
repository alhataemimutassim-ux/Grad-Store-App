import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/product_image_model.dart';

abstract class ProductImagesRemoteDataSource {
  Future<List<ProductImageModel>> getAll();
  Future<List<ProductImageModel>> getByProductId(int productId);
}

class ProductImagesRemoteDataSourceImpl
    implements ProductImagesRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  ProductImagesRemoteDataSourceImpl(this.client, {this.tokenManager});

  @override
  Future<List<ProductImageModel>> getAll() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/productimages');
    final token = tokenManager == null
        ? null
        : await tokenManager!.getAccessToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await client.get(uri, headers: headers);
    final body = res.body.isNotEmpty ? res.body : '[]';
    final List<dynamic> json = body.isNotEmpty
        ? (jsonDecode(body) as List<dynamic>)
        : [];
    return json
        .map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductImageModel>> getByProductId(int productId) async {
    // Backend expects: GET /api/productimages/byproduct_id/{id}
    final uri = Uri.parse('${ApiConstants.baseUrl}/productimages/byproduct_id/$productId');
    final token = tokenManager == null
        ? null
        : await tokenManager!.getAccessToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await client.get(uri, headers: headers);
    final body = res.body.isNotEmpty ? res.body : '[]';
    final List<dynamic> json = body.isNotEmpty
        ? (jsonDecode(body) as List<dynamic>)
        : [];
    return json
        .map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
