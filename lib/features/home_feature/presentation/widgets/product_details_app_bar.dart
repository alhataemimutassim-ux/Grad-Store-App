import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/core/widgets/app_bordered_icon_button.dart';

import '../../../../../features/favorites_feature/presentation/favorites_cubit.dart';
import '../../../../../features/cart_feature/data/models/product_model.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/theme/dimens.dart';

class ProductDetailsAppBar extends StatelessWidget {
  const ProductDetailsAppBar({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
        child: AppBorderedIconButton(
          iconPath: Assets.icons.arrowLeft,
          color: Colors.white,
          onPressed: () {
            appPop(context);
          },
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
          child: BlocBuilder<FavoritesCubit, List<ProductModel>>(
            builder: (context, state) {
              final isFav = state.any((p) => p.id == product.id);
              return AppBorderedIconButton(
                iconPath: Assets.icons.heart,
                color: isFav ? Colors.red : Colors.white,
                onPressed: () {
                  context.read<FavoritesCubit>().toggle(product);
                },
              );
            },
          ),
        ),
      ],
      leadingWidth: 90.0,
    );
  }
}
