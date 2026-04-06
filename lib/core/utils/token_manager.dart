import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenManager {
  final _storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async {
    var normalized = token.trim();
    if (normalized.toLowerCase().startsWith('bearer ')) {
      normalized = normalized.substring(7).trim();
    }
    await _storage.write(key: 'accessToken', value: normalized);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refreshToken', value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  /// Returns true if there is an access token and it is not expired.
  Future<bool> hasValidAccessToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;
    try {
      return !JwtDecoder.isExpired(token);
    } catch (_) {
      // If we can't decode it or if it doesn't have an expiry, assume valid for fallback
      return true;
    }
  }

  /// Attempts to decode the stored JWT access token and extract a user id.
  Future<int?> getUserIdFromAccessToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      return TokenManager.parseUserIdFromToken(token);
    } catch (_) {
      return null;
    }
  }

  /// Attempts to decode the stored JWT and extract the role id.
  Future<int?> getRoleIdFromAccessToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      return TokenManager.parseRoleIdFromToken(token);
    } catch (_) {
      return null;
    }
  }

  /// Static helper to parse a JWT string and extract a user id.
  /// Useful for testing without FlutterSecureStorage.
  static int? parseUserIdFromToken(String token) {
    try {
      Map<String, dynamic> json;
      try {
        json = JwtDecoder.decode(token);
      } catch (_) {
        // Fallback: manually decode the payload part (base64url)
        final parts = token.split('.');
        if (parts.length < 2) return null;
        final payload = parts[1];
        var normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
        while (normalized.length % 4 != 0) normalized += '=';
        final decoded = utf8.decode(base64.decode(normalized));
        final parsed = jsonDecode(decoded);
        if (parsed is Map<String, dynamic>) {
          json = parsed;
        } else {
          return null;
        }
      }

      final candidates = [
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
        'idUser', 'userId', 'sub', 'id', 'IdUser', 'user_id', 'NameIdentifier', 'uid'
      ];
      for (final k in candidates) {
        if (json.containsKey(k)) {
          final val = json[k];
          if (val is int) return val;
          if (val is String) return int.tryParse(val);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Static helper to parse a JWT string and extract a canonical role id.
  /// Maps common role names to numeric ids (seller:1, student/user:2, admin:3).
  static int? parseRoleIdFromToken(String token) {
    try {
      Map<String, dynamic> json;
      try {
        json = JwtDecoder.decode(token);
      } catch (_) {
        final parts = token.split('.');
        if (parts.length < 2) return null;
        final payload = parts[1];
        var normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
        while (normalized.length % 4 != 0) normalized += '=';
        final decoded = utf8.decode(base64.decode(normalized));
        final parsed = jsonDecode(decoded);
        if (parsed is Map<String, dynamic>) {
          json = parsed;
        } else {
          return null;
        }
      }

      final candidates = [
        // .NET Identity ClaimTypes.Role
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
        'roleId', 'role_id', 'RoleId', 'Role'
      ];

      for (final k in candidates) {
        if (json.containsKey(k)) {
          final val = json[k];
          if (val is int) return val;
          if (val is String) {
            // Could be a number parsed to string "1", "2", "3"
            final parsedNum = int.tryParse(val);
            if (parsedNum != null) return parsedNum;
            // Otherwise, mapping common role names to ints (case-insensitive):
            final strVal = val.toLowerCase();
            if (strVal == 'seller') return 1;
            if (strVal == 'student' || strVal == 'user') return 2;
            if (strVal == 'admin' || strVal == 'administrator') return 3;
          }
          if (val is List && val.isNotEmpty) {
            final first = val.first;
            if (first is String) {
              final strVal = first.toLowerCase();
              if (strVal == 'seller') return 1;
              if (strVal == 'student' || strVal == 'user') return 2;
              if (strVal == 'admin' || strVal == 'administrator') return 3;
            }
            if (first is int) return first;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
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
