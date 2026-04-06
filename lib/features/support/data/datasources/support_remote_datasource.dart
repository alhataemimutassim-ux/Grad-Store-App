import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/support_message_model.dart';

abstract class SupportRemoteDataSource {
  Future<void> sendMessage({required String title, required String message});
  Future<List<SupportMessageModel>> getAllMessages();
  Future<void> deleteMessage(int id);
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final http.Client client;
  final TokenManager tokenManager;

  SupportRemoteDataSourceImpl(this.client, {required this.tokenManager});

  Future<Map<String, String>> _headers() async {
    final token = await tokenManager.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<void> sendMessage({required String title, required String message}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/support/send');
    final body = jsonEncode({'title': title, 'message': message});
    final res = await client.post(uri, headers: await _headers(), body: body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'فشل إرسال الرسالة';
      try {
        final json = jsonDecode(res.body);
        msg = json['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  @override
  Future<List<SupportMessageModel>> getAllMessages() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/support/all');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('فشل جلب الرسائل');
    }
    final List<dynamic> json = jsonDecode(res.body);
    return json.map((e) => SupportMessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> deleteMessage(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/support/$id');
    final res = await client.delete(uri, headers: await _headers());
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('فشل حذف الرسالة');
    }
  }
}
