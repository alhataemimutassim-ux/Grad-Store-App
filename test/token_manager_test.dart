import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grad_store_app/core/utils/token_manager.dart';

String _base64UrlEncode(String input) => base64Url.encode(utf8.encode(input)).replaceAll('=', '');

String makeJwt(Map<String, dynamic> payload) {
  final header = {'alg': 'none', 'typ': 'JWT'};
  final h = _base64UrlEncode(json.encode(header));
  final p = _base64UrlEncode(json.encode(payload));
  return h + '.' + p + '.'; // empty signature
}

void main() {
  test('parses Seller role and user id', () {
    final jwt = makeJwt({
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role': 'Seller',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier': '10'
    });

    expect(TokenManager.parseRoleIdFromToken(jwt), 1);
    expect(TokenManager.parseUserIdFromToken(jwt), 10);
  });

  test('parses Student role (case-insensitive) and user id', () {
    final jwt = makeJwt({
      'Role': 'student',
      'idUser': 25
    });

    expect(TokenManager.parseRoleIdFromToken(jwt), 2);
    expect(TokenManager.parseUserIdFromToken(jwt), 25);
  });

  test('parses Admin role and numeric role string', () {
    final jwt1 = makeJwt({'Role': 'Admin', 'sub': '7'});
    final jwt2 = makeJwt({'Role': '2', 'sub': '9'});

    expect(TokenManager.parseRoleIdFromToken(jwt1), 3);
    expect(TokenManager.parseRoleIdFromToken(jwt2), 2);
    expect(TokenManager.parseUserIdFromToken(jwt1), 7);
    expect(TokenManager.parseUserIdFromToken(jwt2), 9);
  });
}
