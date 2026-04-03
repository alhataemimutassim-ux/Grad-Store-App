import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getMyOrders(int userId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  OrdersRemoteDataSourceImpl(this.client, {this.tokenManager});

  Map<String, String> _baseHeaders(String? token) => {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};

  @override
  Future<List<OrderModel>> getMyOrders(int userId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/orders/my/$userId');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final res = await client.get(uri, headers: _baseHeaders(token));
    if (!(res.statusCode >= 200 && res.statusCode < 300)) throw Exception(res.body);
    final List<dynamic> json = jsonDecode(res.body) as List<dynamic>;
    return json.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
