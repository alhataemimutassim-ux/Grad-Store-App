class RefreshToken {
  final String token;
  final DateTime expires;

  RefreshToken({
    required this.token,
    required this.expires,
  });
}