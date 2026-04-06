import '../entities/support_message.dart';

abstract class SupportRepository {
  Future<void> sendMessage({required String title, required String message});
  Future<List<SupportMessage>> getAllMessages();
  Future<void> deleteMessage(int id);
}
