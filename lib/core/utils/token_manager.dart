import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class TokenManager {
  final _storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async {
    // Normalize token: some APIs return "Bearer <token>", store only the raw JWT
    var normalized = token.trim();
    if (normalized.toLowerCase().startsWith('bearer ')) {
      normalized = normalized.substring(7).trim();
    }
    await _storage.write(key: 'accessToken', value: normalized);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  /// Returns true if there is an access token and it is not expired (if token contains an 'exp' claim).
  Future<bool> hasValidAccessToken() async {
    final token = await getAccessToken();
    if (token == null) return false;
    try {
      final parts = token.split('.');
      if (parts.length < 2) return true; // cannot determine expiry -> assume valid
      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final dynamic parsed = jsonDecode(decoded);
      if (parsed is Map<String, dynamic>) {
        final json = parsed;
        if (json.containsKey('exp')) {
          final expVal = json['exp'];
          int? exp;
          if (expVal is int) exp = expVal;
          if (expVal is String) exp = int.tryParse(expVal);
          if (exp != null) {
            final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
            return DateTime.now().isBefore(expiry);
          }
        }
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Attempts to decode the stored JWT access token and extract a user id.
  /// It looks for common claim names: 'idUser', 'userId', 'sub', 'id'.
  Future<int?> getUserIdFromAccessToken() async {
    final token = await getAccessToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = parts[1];
      // base64 normalize
      var normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final dynamic parsed = jsonDecode(decoded);
      if (parsed is Map<String, dynamic>) {
        final Map<String, dynamic> json = parsed;
        final candidates = ['idUser', 'userId', 'sub', 'id', 'IdUser', 'user_id'];
        for (final k in candidates) {
          if (json.containsKey(k)) {
            final val = json[k];
            if (val is int) return val;
            if (val is String) return int.tryParse(val);
          }
        }
        // Some tokens nest the user object inside a 'user' or 'data' key
        final nestedKeys = ['user', 'data', 'payload'];
        for (final nk in nestedKeys) {
          if (json.containsKey(nk) && json[nk] is Map<String, dynamic>) {
            final inner = json[nk] as Map<String, dynamic>;
            for (final k in candidates) {
              if (inner.containsKey(k)) {
                final val = inner[k];
                if (val is int) return val;
                if (val is String) return int.tryParse(val);
              }
            }
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'accessToken');
  }

  // Recent accounts: store a small list of previously used emails for quick login
  Future<List<String>> getRecentAccounts() async {
    final raw = await _storage.read(key: 'recentAccounts');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> saveRecentAccount(String email, {int max = 5}) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;
    final list = await getRecentAccounts();
    // move to front
    list.removeWhere((e) => e.toLowerCase() == trimmed.toLowerCase());
    list.insert(0, trimmed);
    if (list.length > max) list.removeRange(max, list.length);
    await _storage.write(key: 'recentAccounts', value: jsonEncode(list));
  }
}
