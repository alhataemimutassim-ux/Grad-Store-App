import '../../domain/entities/offer.dart';
import '../repositories/offers_repository.dart';

class GetPublicOffers {
  final OffersRepository repository;
  GetPublicOffers(this.repository);

  Future<List<Offer>> execute() {
    return repository.getPublicOffers();
  }
}
