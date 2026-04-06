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
    final refreshToken = tokenManager == null ? null : await tokenManager!.getRefreshToken();

    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    if (refreshToken != null) headers['Cookie'] = 'refreshToken=$refreshToken';

    final response = await client.get(
      Uri.parse(ApiConstants.baseUrl + path),
      headers: headers,
    );

    return await _processResponse(response);
  }

  // ===== POST request example =====
  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
    await _ensureValidToken();
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final refreshToken = tokenManager == null ? null : await tokenManager!.getRefreshToken();

    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    if (refreshToken != null) headers['Cookie'] = 'refreshToken=$refreshToken';

    final response = await client.post(
      Uri.parse(ApiConstants.baseUrl + path),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    return await _processResponse(response);
  }

  // ===== تحقق وتجديد التوكن =====
  Future<void> _ensureValidToken() async {
    // Simplified: ensure token presence only. Token refresh flows can be
    // handled at a higher level to avoid circular dependencies.
    if (tokenManager == null) return;
    final token = await tokenManager!.getAccessToken();
    if (token == null) return;
  }

  Future<Map<String, dynamic>> _processResponse(http.Response response) async {
    // حاول حفظ الكوكيز إذا توفرت
    if (tokenManager != null && response.headers.containsKey('set-cookie')) {
      final setCookieHeader = response.headers['set-cookie'];
      if (setCookieHeader != null) {
        final cookies = setCookieHeader.split(',');
        for (final cookie in cookies) {
          if (cookie.trim().startsWith('refreshToken=')) {
            final parts = cookie.split(';');
            final tokenPart = parts.firstWhere((p) => p.trim().startsWith('refreshToken='));
            final token = tokenPart.split('=')[1];
            await tokenManager!.saveRefreshToken(token);
          }
        }
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {};
      }
    } else {
      String errMsg = 'حدث خطأ في الخادم';
      try {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map) {
            final List<String> errorMessages = [];

            // 1. .NET Core Validation Errors: {"errors": { "Email": ["Invalid format"] }}
            if (decoded.containsKey('errors') && decoded['errors'] is Map) {
              final Map<String, dynamic> errors = decoded['errors'];
              for (final entry in errors.values) {
                if (entry is List) {
                  errorMessages.addAll(entry.map((e) => e.toString()));
                } else if (entry is String) {
                  errorMessages.add(entry);
                }
              }
            }
            
            // 2. Default Message Key
            if (decoded.containsKey('message') && decoded['message'] != null) {
              errorMessages.add(decoded['message'].toString());
            }

            if (errorMessages.isNotEmpty) {
              errMsg = errorMessages.join('\\n');
            } else if (decoded.containsKey('title')) {
              errMsg = decoded['title'].toString();
            }
          } else if (decoded is String) {
            errMsg = decoded;
          }
        }
      } catch (_) {}

      if (response.statusCode == 401) {
        throw ServerException(errMsg.contains('خطأ') ? 'غير مصرح، انتهت صلاحية التوكن' : errMsg);
      } else {
        throw ServerException(errMsg);
      }
    }
  }
}