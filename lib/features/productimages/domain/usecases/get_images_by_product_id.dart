import '../entities/product_image.dart';
import '../repositories/product_images_repository.dart';

class GetImagesByProductId {
  final ProductImagesRepository repository;

  GetImagesByProductId(this.repository);

  Future<List<ProductImage>> execute(int productId) async {
    return await repository.getByProductId(productId);
  }
}
