import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getAll();
  Future<CartItemModel?> getById(int id);
  Future<void> create(int productId, int quantity);
  Future<void> update(int id, int productId, int quantity);
  Future<void> delete(int id);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  CartRemoteDataSourceImpl(this.client, {this.tokenManager});

  Map<String, String> _baseHeaders(String? token) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  @override
  Future<List<CartItemModel>> getAll() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/cartitems');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final res = await client.get(uri, headers: _baseHeaders(token));
    final body = res.body.isNotEmpty ? res.body : '[]';
    final List<dynamic> json = body.isNotEmpty ? (jsonDecode(body) as List<dynamic>) : [];
    return json.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<CartItemModel?> getById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/cartitems/$id');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final res = await client.get(uri, headers: _baseHeaders(token));
    if (res.statusCode == 404) return null;
    final Map<String, dynamic> json = jsonDecode(res.body);
    return CartItemModel.fromJson(json);
  }

  @override
  Future<void> create(int productId, int quantity) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/cartitems');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final dto = {'ProductId': productId, 'Quantity': quantity};
    final res = await client.post(uri, headers: _baseHeaders(token), body: jsonEncode(dto));
    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception(res.body);
    }
  }

  @override
  Future<void> update(int id, int productId, int quantity) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/cartitems/$id');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final dto = {'ProductId': productId, 'Quantity': quantity};
    final res = await client.put(uri, headers: _baseHeaders(token), body: jsonEncode(dto));
    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception(res.body);
    }
  }

  @override
  Future<void> delete(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/cartitems/$id');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final res = await client.delete(uri, headers: _baseHeaders(token));
    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception(res.body);
    }
  }
}
