import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../utils/token_manager.dart';

class ApiClient {
  final http.Client client;
  final TokenManager? tokenManager;

  /// Creates an [ApiClient]. The [tokenManager] is optional; if not
  /// provided, authorization headers won't be sent automatically.
  ApiClient({
    http.Client? client,
    this.tokenManager,
  }) : client = client ?? http.Client();

  // ===== GET request example =====
  Future<Map<String, dynamic>> get(String path) async {
    await _ensureValidToken();
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final response = await client.get(
      Uri.parse(ApiConstants.baseUrl + path),
      headers: headers,
    );

    return _processResponse(response);
  }

  // ===== POST request example =====
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    await _ensureValidToken();
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final response = await client.post(
      Uri.parse(ApiConstants.baseUrl + path),
      headers: headers,
      body: jsonEncode(body),
    );

    return _processResponse(response);
  }

  // ===== تحقق وتجديد التوكن =====
  Future<void> _ensureValidToken() async {
    // Simplified: ensure token presence only. Token refresh flows can be
    // handled at a higher level to avoid circular dependencies.
    if (tokenManager == null) return;
    final token = await tokenManager!.getAccessToken();
    if (token == null) return;
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw ServerException('غير مصرح، انتهت صلاحية التوكن');
    } else {
      throw ServerException('خطأ في السيرفر');
    }
  }
}