import '../../domain/entities/product_image.dart';
import '../../domain/repositories/product_images_repository.dart';
import '../datasources/product_images_remote_datasource.dart';
import '../models/product_image_model.dart';

class ProductImagesRepositoryImpl implements ProductImagesRepository {
  final ProductImagesRemoteDataSource remote;

  ProductImagesRepositoryImpl(this.remote);

  @override
  Future<List<ProductImage>> getAll() async {
    final List<ProductImageModel> models = await remote.getAll();
    return models
        .map(
          (m) => ProductImage(
            id: m.id,
            productId: m.productId,
            image: m.image,
            createdAt: m.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<List<ProductImage>> getByProductId(int productId) async {
    final List<ProductImageModel> models = await remote.getByProductId(
      productId,
    );
    return models
        .map(
          (m) => ProductImage(
            id: m.id,
            productId: m.productId,
            image: m.image,
            createdAt: m.createdAt,
          ),
        )
        .toList();
  }
}
