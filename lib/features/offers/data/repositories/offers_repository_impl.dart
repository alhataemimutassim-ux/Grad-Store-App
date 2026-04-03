import '../../domain/entities/offer.dart';
import '../datasources/offers_remote_datasource.dart';
import '../../domain/repositories/offers_repository.dart';

class OffersRepositoryImpl implements OffersRepository {
  final OffersRemoteDataSource remote;
  OffersRepositoryImpl(this.remote);

  @override
  Future<List<Offer>> getPublicOffers() async {
    final list = await remote.getPublicOffers();
    return list;
  }
}
