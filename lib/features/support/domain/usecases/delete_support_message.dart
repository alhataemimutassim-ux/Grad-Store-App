import '../repositories/support_repository.dart';

class DeleteSupportMessage {
  final SupportRepository repository;
  DeleteSupportMessage(this.repository);

  Future<void> execute(int id) => repository.deleteMessage(id);
}
