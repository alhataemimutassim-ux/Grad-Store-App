import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getAll();
  Future<CategoryModel?> getById(int id);
  Future<int> create({required String name, String? description, File? imageFile});
  Future<void> update(int id, {required String name, String? description, File? imageFile});
  Future<void> delete(int id);
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  CategoriesRemoteDataSourceImpl(this.client, {this.tokenManager});

  @override
  Future<List<CategoryModel>> getAll() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/categories');
  final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
  final headers = {'Content-Type': 'application/json'};
  if (token != null) headers['Authorization'] = 'Bearer $token';
  final res = await client.get(uri, headers: headers);
    final body = res.body.isNotEmpty ? (res.body) : '[]';
    final List<dynamic> json = body.isNotEmpty ? (jsonDecode(body) as List<dynamic>) : [];
    return json.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<CategoryModel?> getById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/categories/$id');
  final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
  final headers = {'Content-Type': 'application/json'};
  if (token != null) headers['Authorization'] = 'Bearer $token';
  final res = await client.get(uri, headers: headers);
    if (res.statusCode == 404) return null;
    final Map<String, dynamic> json = jsonDecode(res.body);
    return CategoryModel.fromJson(json);
  }

  @override
  Future<int> create({required String name, String? description, File? imageFile}) async {
  final uri = Uri.parse('${ApiConstants.baseUrl}/categories');
  final request = http.MultipartRequest('POST', uri);
    // Use field names matching the API DTO (case-sensitive)
    request.fields['Name'] = name;
    if (description != null) request.fields['Description'] = description;
  final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
  if (token != null) request.headers['Authorization'] = 'Bearer $token';

    if (imageFile != null) {
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'ImageFile',
          imageFile.path,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );
    }

  final streamed = await client.send(request);
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      // try to extract server message
      String body = resp.body;
      try {
        final Map<String, dynamic> err = jsonDecode(body);
        final msg = err['message'] ?? body;
        throw Exception(msg);
      } catch (_) {
        throw Exception(body);
      }
    }

    final data = resp.body.isNotEmpty ? (jsonDecode(resp.body) as Map<String, dynamic>) : <String, dynamic>{};
    return data['categoryId'] ?? 0;
  }

  @override
  Future<void> update(int id, {required String name, String? description, File? imageFile}) async {
  final uri = Uri.parse('${ApiConstants.baseUrl}/categories/$id');
  final request = http.MultipartRequest('PUT', uri);
    // Use field names that match the server DTO
    request.fields['Name'] = name;
    if (description != null) request.fields['Description'] = description;
  final token2 = tokenManager == null ? null : await tokenManager!.getAccessToken();
  if (token2 != null) request.headers['Authorization'] = 'Bearer $token2';

    if (imageFile != null) {
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'ImageFile',
          imageFile.path,
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
  Future<void> delete(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/categories/$id');
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

// helpers (imports moved to top)
