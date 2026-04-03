import '../entities/product_image.dart';
import '../repositories/product_images_repository.dart';

class GetAllProductImages {
  final ProductImagesRepository repository;

  GetAllProductImages(this.repository);

  Future<List<ProductImage>> execute() async {
    return await repository.getAll();
  }
}
