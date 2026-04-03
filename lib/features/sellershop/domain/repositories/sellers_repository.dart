import '../entities/seller.dart';

abstract class SellersRepository {
  Future<List<Seller>> getAllSellers();
  Future<Seller?> getSellerById(int id);
}
