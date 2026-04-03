import '../entities/product_image.dart';

abstract class ProductImagesRepository {
  Future<List<ProductImage>> getAll();
  Future<List<ProductImage>> getByProductId(int productId);
}
