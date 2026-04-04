import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/core/widgets/app_bordered_icon_button.dart';

import 'package:grad_store_app/features/wishlist/presentation/state/wishlist_provider.dart';
import 'package:grad_store_app/features/products/domain/entities/product.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/theme/dimens.dart';

class ProductDetailsAppBar extends StatelessWidget {
  const ProductDetailsAppBar({super.key, required this.product});

  final Product product;

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
          child: Consumer<WishlistProvider>(
            builder: (context, provider, child) {
              final isFav = provider.isInWishlist(product.id);
              return AppBorderedIconButton(
                iconPath: Assets.icons.heart,
                color: isFav ? Colors.red : Colors.white,
                onPressed: () {
                  provider.toggle(product.id);
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
