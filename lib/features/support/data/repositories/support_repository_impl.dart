import '../../domain/entities/support_message.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_datasource.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource remoteDataSource;

  SupportRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> sendMessage({required String title, required String message}) async {
    await remoteDataSource.sendMessage(title: title, message: message);
  }

  @override
  Future<List<SupportMessage>> getAllMessages() async {
    return await remoteDataSource.getAllMessages();
  }

  @override
  Future<void> deleteMessage(int id) async {
    await remoteDataSource.deleteMessage(id);
  }
}
