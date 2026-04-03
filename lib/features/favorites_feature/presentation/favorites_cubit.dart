import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cart_feature/data/models/product_model.dart';

class FavoritesCubit extends Cubit<List<ProductModel>> {
  FavoritesCubit() : super([]);

  void add(ProductModel product) {
    if (!isFavorite(product)) {
      emit(List.from(state)..add(product));
    }
  }

  void remove(ProductModel product) {
    emit(List.from(state)..removeWhere((p) => p.id == product.id));
  }

  void toggle(ProductModel product) {
    if (isFavorite(product)) {
      remove(product);
    } else {
      add(product);
    }
  }

  bool isFavorite(ProductModel product) {
    return state.any((p) => p.id == product.id);
  }
}
