import 'package:flutter/material.dart';
import '../../domain/entities/offer.dart';
import '../../domain/usecases/get_public_offers.dart';

enum OffersStatus { initial, loading, loaded, error }

class OffersProvider with ChangeNotifier {
  final GetPublicOffers getPublicOffers;

  OffersProvider({required this.getPublicOffers});

  OffersStatus _status = OffersStatus.initial;
  OffersStatus get status => _status;

  String _error = '';
  String get error => _error;

  List<Offer> _items = [];
  List<Offer> get items => _items;

  Future<void> fetchPublicOffers() async {
    _status = OffersStatus.loading;
    notifyListeners();
    try {
      final list = await getPublicOffers.execute();
      _items = list;
      _status = OffersStatus.loaded;
    } catch (e) {
      _status = OffersStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }
}
