class SupportMessage {
  final int id;
  final int userId;
  final String userName;
  final String email;
  final String title;
  final String message;
  final DateTime createdAt;
  final String status;

  const SupportMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.status,
  });
}
