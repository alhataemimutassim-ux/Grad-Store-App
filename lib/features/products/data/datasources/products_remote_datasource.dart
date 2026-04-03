import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getAll({bool activeOnly = false});
  Future<ProductModel?> getById(int id);
  Future<List<ProductModel>> getAdminProducts(int adminId);
  Future<void> toggleActive(int id);
  Future<int> create({required String name, String? description, required double price, required int qty, required double discount, String? type, String? brand, String? countryOfOrigin, required int categoryId, required int sellerId, File? mainImageFile, List<int>? mainImageBytes, String? mainImageFilename});
  Future<void> update(int id, {required String name, String? description, required double price, required int qty, required double discount, String? type, String? brand, String? countryOfOrigin, required int categoryId, File? mainImageFile, List<int>? mainImageBytes, String? mainImageFilename});
  Future<void> delete(int id);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  ProductsRemoteDataSourceImpl(this.client, {this.tokenManager});

  @override
  Future<List<ProductModel>> getAll({bool activeOnly = false}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/products${activeOnly ? '?activeOnly=true' : ''}');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await client.get(uri, headers: headers);
    final body = res.body.isNotEmpty ? res.body : '[]';
    final List<dynamic> json = body.isNotEmpty ? (jsonDecode(body) as List<dynamic>) : [];
    return json.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ProductModel?> getById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/products/$id');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await client.get(uri, headers: headers);
    if (res.statusCode == 404) return null;
    final Map<String, dynamic> json = jsonDecode(res.body);
    return ProductModel.fromJson(json);
  }

  @override
  Future<List<ProductModel>> getAdminProducts(int adminId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/products/admin/$adminId');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await client.get(uri, headers: headers);
    final body = res.body.isNotEmpty ? res.body : '[]';
    final List<dynamic> json = body.isNotEmpty ? (jsonDecode(body) as List<dynamic>) : [];
    return json.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<int> create({required String name, String? description, required double price, required int qty, required double discount, String? type, String? brand, String? countryOfOrigin, required int categoryId, required int sellerId, File? mainImageFile, List<int>? mainImageBytes, String? mainImageFilename}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/products');
    final request = http.MultipartRequest('POST', uri);
    // fields must match server DTO (case-sensitive)
    request.fields['Name'] = name;
    if (description != null) request.fields['Description'] = description;
    request.fields['Price'] = price.toString();
    request.fields['Qty'] = qty.toString();
    request.fields['Discount'] = discount.toString();
    if (type != null) request.fields['Type'] = type;
    if (brand != null) request.fields['Brand'] = brand;
    if (countryOfOrigin != null) request.fields['CountryOfOrigin'] = countryOfOrigin;
    request.fields['CategoryId'] = categoryId.toString();
    request.fields['SellerId'] = sellerId.toString();

    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    if (mainImageFile != null) {
      final mimeType = lookupMimeType(mainImageFile.path) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'MainImageFile',
          mainImageFile.path,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );
    } else if (mainImageBytes != null && mainImageBytes.isNotEmpty) {
      final filename = mainImageFilename ?? 'upload.jpg';
      final mimeType = lookupMimeType(filename) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          'MainImageFile',
          mainImageBytes,
          filename: filename,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );
    }

    final streamed = await client.send(request);
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final body = resp.body;
      try {
        final Map<String, dynamic> err = jsonDecode(body);
        final msg = err['message'] ?? body;
        throw Exception(msg);
      } catch (_) {
        throw Exception(body);
      }
    }
    final data = resp.body.isNotEmpty ? (jsonDecode(resp.body) as Map<String, dynamic>) : <String, dynamic>{};
    return data['productId'] ?? 0;
  }

  @override
  Future<void> update(int id, {required String name, String? description, required double price, required int qty, required double discount, String? type, String? brand, String? countryOfOrigin, required int categoryId, File? mainImageFile, List<int>? mainImageBytes, String? mainImageFilename}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/products/$id');
    final request = http.MultipartRequest('PUT', uri);
    request.fields['Name'] = name;
    if (description != null) request.fields['Description'] = description;
    request.fields['Price'] = price.toString();
    request.fields['Qty'] = qty.toString();
    request.fields['Discount'] = discount.toString();
    if (type != null) request.fields['Type'] = type;
    if (brand != null) request.fields['Brand'] = brand;
    if (countryOfOrigin != null) request.fields['CountryOfOrigin'] = countryOfOrigin;
    request.fields['CategoryId'] = categoryId.toString();

    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    if (mainImageFile != null) {
      final mimeType = lookupMimeType(mainImageFile.path) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'MainImageFile',
          mainImageFile.path,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );
    } else if (mainImageBytes != null && mainImageBytes.isNotEmpty) {
      final filename = mainImageFilename ?? 'upload.jpg';
      final mimeType = lookupMimeType(filename) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          'MainImageFile',
          mainImageBytes,
          filename: filename,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );
    }

    final streamed = await client.send(request);
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final body = resp.body;
      try {
        final Map<String, dynamic> err = jsonDecode(body);
        final msg = err['message'] ?? body;
        throw Exception(msg);
      } catch (_) {
        throw Exception(body);
      }
    }
  }

  @override
  Future<void> toggleActive(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/products/toggle-active/$id');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await client.put(uri, headers: headers);
    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      final body = res.body;
      try {
        final Map<String, dynamic> err = jsonDecode(body);
        final msg = err['message'] ?? body;
        throw Exception(msg);
      } catch (_) {
        throw Exception(body);
      }
    }
  }

  @override
  Future<void> delete(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/products/$id');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final headers = <String, String>{};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await client.delete(uri, headers: headers);
    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      final body = res.body;
      try {
        final Map<String, dynamic> err = jsonDecode(body);
        final msg = err['message'] ?? body;
        throw Exception(msg);
      } catch (_) {
        throw Exception(body);
      }
    }
  }
}
