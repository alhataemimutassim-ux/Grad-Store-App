import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/payment_method_model.dart';
import '../../../orders/data/models/order_model.dart' as om;

abstract class CheckoutRemoteDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<om.OrderModel> completeCheckout({
    required int paymentMethodId,
    required String address,
    required String phone,
  });
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  CheckoutRemoteDataSourceImpl(this.client, {this.tokenManager});

  Map<String, String> _baseHeaders(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/paymentmethods');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final res = await client.get(uri, headers: _baseHeaders(token));
    final body = res.body.isNotEmpty ? res.body : '[]';
    final List<dynamic> jsonList = jsonDecode(body) as List<dynamic>;
    return jsonList.map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<om.OrderModel> completeCheckout({
    required int paymentMethodId,
    required String address,
    required String phone,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/orders/checkout');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final dto = {
      'PaymentMethodId': paymentMethodId,
      'Address': address,
      'Phone': phone,
    };
    final res = await client.post(uri, headers: _baseHeaders(token), body: jsonEncode(dto));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('فشل إرسال الطلب (${res.statusCode}): ${res.body}');
    }
    final Map<String, dynamic> body =
        res.body.isNotEmpty ? jsonDecode(res.body) as Map<String, dynamic> : <String, dynamic>{};
    return om.OrderModel.fromJson(body);
  }
}
