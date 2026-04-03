import 'dart:io';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remote;
  ProductsRepositoryImpl(this.remote);

  @override
  Future<List<Product>> getAll({bool activeOnly = false}) async {
    final models = await remote.getAll(activeOnly: activeOnly);
    return models;
  }

  @override
  Future<Product?> getById(int id) async {
    return await remote.getById(id);
  }

  @override
  Future<List<Product>> getAdminProducts(int adminId) async {
    final models = await remote.getAdminProducts(adminId);
    return models;
  }

  @override
  Future<int> create(CreateProductRequest request) async {
    final file = request.localImagePath != null ? File(request.localImagePath!) : null;
    return await remote.create(
      name: request.name,
      description: request.description,
      price: request.price,
      qty: request.qty,
      discount: request.discount,
      type: request.type,
      brand: request.brand,
      countryOfOrigin: request.countryOfOrigin,
      categoryId: request.categoryId,
      sellerId: request.sellerId,
      mainImageFile: file,
      mainImageBytes: request.imageBytes,
      mainImageFilename: request.imageFilename,
    );
  }

  @override
  Future<void> update(UpdateProductRequest request) async {
    final file = request.localImagePath != null ? File(request.localImagePath!) : null;
    return await remote.update(
      request.id,
      name: request.name,
      description: request.description,
      price: request.price,
      qty: request.qty,
      discount: request.discount,
      type: request.type,
      brand: request.brand,
      countryOfOrigin: request.countryOfOrigin,
      categoryId: request.categoryId,
      mainImageFile: file,
      mainImageBytes: request.imageBytes,
      mainImageFilename: request.imageFilename,
    );
  }

  @override
  Future<void> toggleActive(int id) async {
    return await remote.toggleActive(id);
  }

  @override
  Future<void> delete(int id) async {
    return await remote.delete(id);
  }
}
