import 'package:grad_store_app/features/cart_feature/data/models/product_model.dart';

import '../../../../../core/gen/assets.gen.dart';

class FakeProducts {
  static final List<ProductModel> products = [
    ProductModel(
      id: 0,
      name: 'جهاز لوحي',
      price: 99.99,
      imageUrl: Assets.images.category17.path,
      rate: 6.5,
      weight: 1.5,
    ),
    ProductModel(
      id: 1,
      name: 'يد روبوت منفرد',
      price: 69.99,
      imageUrl: Assets.images.category18.path,
      rate: 7.5,
      weight: 1.0,
    ),
    ProductModel(
      id: 2,
      name: 'حهاز مراقبة',
      price: 49.99,
      imageUrl: Assets.images.category9.path,
      rate: 6.5,
      weight: 1.5,
    ),
    ProductModel(
      id: 3,
      name: 'اردوينو - اونو',
      price: 39.99,
      imageUrl: Assets.images.category4.path,
      rate: 7.5,
      weight: 1.5,
    ),
    ProductModel(
      id: 4,
      name: 'يد روبوت منفرد',
      price: 40.00,
      imageUrl: Assets.images.category5.path,
      rate: 9.3,
      weight: 1.5,
    ),
    ProductModel(
      id: 5,
      name: 'مبرد هاتف' ,
      price: 50.00,
      imageUrl: Assets.images.category6.path,
      rate: 8.5,
      weight: 0.5,
    ),
    ProductModel(
      id: 6,
      name: 'جهاز مراقية',
      price: 39.99,
      imageUrl: Assets.images.category1.path,
      rate: 6.5,
      weight: 1.5,
    ),
    ProductModel(
      id: 7,
      name: 'سماعة رأس',
      price: 29.99,
      imageUrl: Assets.images.category2.path,
      rate: 6.5,
      weight: 1.5,
    ),
    ProductModel(
      id: 7,
      name: 'ثيودوليت',
      price: 29.99,
      imageUrl: Assets.images.category3.path,
      rate: 6.5,
      weight: 1.5,
    ),
  ];
}
