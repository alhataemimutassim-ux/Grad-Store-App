import '../entities/offer.dart';

abstract class OffersRepository {
  Future<List<Offer>> getPublicOffers();
}
