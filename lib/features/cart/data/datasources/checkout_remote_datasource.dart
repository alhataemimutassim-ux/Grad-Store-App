import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/payment_method_model.dart';

import '../../../orders/data/models/order_model.dart' as om;

abstract class CheckoutRemoteDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<om.OrderModel> completeCheckout({ required int paymentMethodId, required String address, required String phone});
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  CheckoutRemoteDataSourceImpl(this.client, {this.tokenManager});

  Map<String, String> _baseHeaders(String? token) => {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/paymentmethods');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final res = await client.get(uri, headers: _baseHeaders(token));
    final body = res.body.isNotEmpty ? res.body : '[]';
    final List<dynamic> json = body.isNotEmpty ? (jsonDecode(body) as List<dynamic>) : [];
    return json.map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<om.OrderModel> completeCheckout({required int paymentMethodId, required String address, required String phone}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/orders/checkout');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final dto = { 'PaymentMethodId': paymentMethodId, 'Address': address, 'Phone': phone};
    // Debug logging (development only): show token and payload being sent
    // Remove or guard these prints in production
    try {
      // ignore: avoid_print
      print('DEBUG: Checkout completeCheckout - token=${token?.substring(0, token.length>20?20:token.length)}...');
      // ignore: avoid_print
      print('DEBUG: Checkout payload: ${dto.toString()}');
    } catch (_) {}
    final res = await client.post(uri, headers: _baseHeaders(token), body: jsonEncode(dto));
    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception(res.body);
    }
    // Debug: print response body to help diagnose mapping issues
    try {
      // ignore: avoid_print
      print('DEBUG: Checkout response body: ${res.body}');
    } catch (_) {}
    final Map<String, dynamic> body = res.body.isNotEmpty ? jsonDecode(res.body) as Map<String, dynamic> : <String, dynamic>{};
    return om.OrderModel.fromJson(body);
  }
}
