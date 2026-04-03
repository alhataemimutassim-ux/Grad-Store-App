import '../../domain/entities/refresh_token.dart';

class RefreshTokenModel extends RefreshToken {
  RefreshTokenModel({
    required super.token,
    required super.expires,
  });

  factory RefreshTokenModel.fromJson(Map<String, dynamic> json) {
    return RefreshTokenModel(
      token: json['token'] ?? '',
      expires: DateTime.parse(json['expires'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires': expires.toIso8601String(),
    };
  }
}