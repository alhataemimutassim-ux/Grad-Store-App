import 'dart:typed_data';
import '../entities/product.dart';

abstract class ProductsRepository {
  Future<List<Product>> getAll({bool activeOnly = false});
  Future<Product?> getById(int id);
  Future<List<Product>> getAdminProducts(int adminId);
  Future<int> create(CreateProductRequest request);
  Future<void> update(UpdateProductRequest request);
  Future<void> toggleActive(int id);
  Future<void> delete(int id);
}

class CreateProductRequest {
  final String name;
  final String? description;
  final double price;
  final int qty;
  final double discount;
  final String? type;
  final String? brand;
  final String? countryOfOrigin;
  final int categoryId;
  final int sellerId;
  final String? localImagePath;
  final Uint8List? imageBytes;
  final String? imageFilename;

  CreateProductRequest({
    required this.name,
    this.description,
    required this.price,
    required this.qty,
    required this.discount,
    this.type,
    this.brand,
    this.countryOfOrigin,
    required this.categoryId,
    required this.sellerId,
    this.localImagePath,
    this.imageBytes,
    this.imageFilename,
  });
}

class UpdateProductRequest {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int qty;
  final double discount;
  final String? type;
  final String? brand;
  final String? countryOfOrigin;
  final int categoryId;
  final String? localImagePath;
  final Uint8List? imageBytes;
  final String? imageFilename;

  UpdateProductRequest({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.qty,
    required this.discount,
    this.type,
    this.brand,
    this.countryOfOrigin,
    required this.categoryId,
    this.localImagePath,
    this.imageBytes,
    this.imageFilename,
  });
}
