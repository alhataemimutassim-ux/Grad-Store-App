import 'package:flutter/material.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/usecases/get_all_product_images.dart';
import '../../domain/usecases/get_images_by_product_id.dart';

enum ProductImagesStatus { initial, loading, loaded, error }

class ProductImagesProvider with ChangeNotifier {
  final GetAllProductImages getAll;
  final GetImagesByProductId getByProductId;

  ProductImagesProvider({required this.getAll, required this.getByProductId});

  ProductImagesStatus _status = ProductImagesStatus.initial;
  ProductImagesStatus get status => _status;

  String _error = '';
  String get error => _error;

  // cache by productId
  final Map<int, List<ProductImage>> _byProduct = {};

  List<ProductImage> imagesFor(int productId) => _byProduct[productId] ?? [];

  Future<void> fetchForProduct(int productId) async {
    _status = ProductImagesStatus.loading;
    notifyListeners();
    try {
      final imgs = await getByProductId.execute(productId);
      _byProduct[productId] = imgs;
      _status = ProductImagesStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = ProductImagesStatus.error;
    }
    notifyListeners();
  }

  Future<void> fetchAll() async {
    _status = ProductImagesStatus.loading;
    notifyListeners();
    try {
      final imgs = await getAll.execute();
      _byProduct.clear();
      for (final img in imgs) {
        final pid = img.productId ?? 0;
        _byProduct.putIfAbsent(pid, () => []).add(img);
      }
      _status = ProductImagesStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = ProductImagesStatus.error;
    }
    notifyListeners();
  }
}
