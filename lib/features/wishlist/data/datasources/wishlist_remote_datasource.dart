import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/wishlist_item_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<WishlistItemModel>> getMyWishlist();
  Future<void> addToWishlist(int productId);
  Future<void> removeFromWishlist(int productId);
  Future<bool> toggleWishlist(int productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  WishlistRemoteDataSourceImpl(this.client, {this.tokenManager});

  Map<String, String> _authHeaders([Map<String, String>? extra]) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  @override
  Future<List<WishlistItemModel>> getMyWishlist() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/wishlist/my');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final headers = token == null ? _authHeaders() : _authHeaders({'Authorization': 'Bearer $token'});
    final resp = await client.get(uri, headers: headers);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (kDebugMode) debugPrint('Wishlist.getMyWishlist raw body: ${resp.body}');
      final body = json.decode(resp.body);
      // Direct list
      if (body is List) return body.map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>)).toList();

      if (body is Map) {
        // Common envelopes
        if (body['data'] is List) return (body['data'] as List).map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>)).toList();
        if (body['items'] is List) return (body['items'] as List).map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>)).toList();
        if (body['result'] is List) return (body['result'] as List).map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>)).toList();
        // nested map containing list under data -> items
        if (body['data'] is Map && body['data']['items'] is List) return (body['data']['items'] as List).map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>)).toList();

        // fallback: find first List value in the map
        for (final v in body.values) {
          if (v is List) return v.map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }

      // nothing matched
      return [];
    }
    throw Exception('Failed to load wishlist: ${resp.statusCode} ${resp.body}');
  }

  @override
  Future<void> addToWishlist(int productId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/wishlist/add');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final headers = token == null ? _authHeaders() : _authHeaders({'Authorization': 'Bearer $token'});
  // Send the expected JSON body matching the API contract: { "productId": <int> }
  final body = json.encode({'productId': productId});
  if (kDebugMode) debugPrint('Wishlist.addToWishlist request body: $body');
  final resp = await client.post(uri, headers: headers, body: body);
  if (kDebugMode) debugPrint('Wishlist.addToWishlist response: ${resp.statusCode} ${resp.body}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) return;
    throw Exception('Failed to add to wishlist: ${resp.statusCode} ${resp.body}');
  }

  @override
  Future<void> removeFromWishlist(int productId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/wishlist/remove');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final headers = token == null ? _authHeaders() : _authHeaders({'Authorization': 'Bearer $token'});
  // Use the API contract: { "productId": <int> }
  final body = json.encode({'productId': productId});
  if (kDebugMode) debugPrint('Wishlist.removeFromWishlist request body: $body');
  final resp = await client.post(uri, headers: headers, body: body);
  if (kDebugMode) debugPrint('Wishlist.removeFromWishlist response: ${resp.statusCode} ${resp.body}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) return;
    throw Exception('Failed to remove from wishlist: ${resp.statusCode} ${resp.body}');
  }

  @override
  Future<bool> toggleWishlist(int productId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/wishlist/toggle');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final headers = token == null ? _authHeaders() : _authHeaders({'Authorization': 'Bearer $token'});
  final body = json.encode({'productId': productId});
  if (kDebugMode) debugPrint('Wishlist.toggleWishlist request body: $body');
  final resp = await client.post(uri, headers: headers, body: body);
  if (kDebugMode) debugPrint('Wishlist.toggleWishlist response: ${resp.statusCode} ${resp.body}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body);
      if (body is Map && body.containsKey('added')) return body['added'] == true;
      // some endpoints return { added: true } or plain { message }
      return true;
    }
    throw Exception('Failed to toggle wishlist: ${resp.statusCode} ${resp.body}');
  }
}
