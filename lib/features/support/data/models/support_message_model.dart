import '../../domain/entities/support_message.dart';

class SupportMessageModel extends SupportMessage {
  const SupportMessageModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.email,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.status,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'New',
    );
  }

  Map<String, dynamic> toSendJson() => {
    'title': title,
    'message': message,
  };
}
