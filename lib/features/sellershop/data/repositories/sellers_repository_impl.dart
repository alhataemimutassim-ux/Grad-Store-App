import '../../domain/entities/seller.dart';
import '../datasources/sellers_remote_datasource.dart';
import '../../domain/repositories/sellers_repository.dart';

class SellersRepositoryImpl implements SellersRepository {
  final SellersRemoteDataSource remote;

  SellersRepositoryImpl(this.remote);

  @override
  Future<List<Seller>> getAllSellers() async {
    final models = await remote.getAllSellers();
    return models;
  }

  @override
  Future<Seller?> getSellerById(int id) async {
    final model = await remote.getSellerById(id);
    return model;
  }
}
