import '../repositories/support_repository.dart';

class SendSupportMessage {
  final SupportRepository repository;
  SendSupportMessage(this.repository);

  Future<void> execute({required String title, required String message}) =>
      repository.sendMessage(title: title, message: message);
}
