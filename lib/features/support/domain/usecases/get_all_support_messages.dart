import '../entities/support_message.dart';
import '../repositories/support_repository.dart';

class GetAllSupportMessages {
  final SupportRepository repository;
  GetAllSupportMessages(this.repository);

  Future<List<SupportMessage>> execute() => repository.getAllMessages();
}
