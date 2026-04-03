import 'package:flutter/material.dart';
import '../../domain/entities/seller.dart';
import '../../domain/usecases/get_all_sellers.dart';

enum SellersStatus { initial, loading, loaded, error }

class SellersProvider extends ChangeNotifier {
  final GetAllSellers getAllSellers;

  SellersStatus status = SellersStatus.initial;
  List<Seller> items = [];
  String? errorMessage;

  SellersProvider({required this.getAllSellers});

  Future<void> fetchAll() async {
    status = SellersStatus.loading;
    notifyListeners();
    try {
      final res = await getAllSellers.call();
      items = List<Seller>.from(res);
      status = SellersStatus.loaded;
    } catch (e) {
      status = SellersStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }
}
