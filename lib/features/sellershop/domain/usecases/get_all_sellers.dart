import '../../domain/repositories/sellers_repository.dart';

class GetAllSellers {
  final SellersRepository repository;

  GetAllSellers(this.repository);

  Future<List> call() async {
    return await repository.getAllSellers();
  }
}
