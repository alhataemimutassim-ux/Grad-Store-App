import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_divider.dart';
import 'package:grad_store_app/core/widgets/app_svg_viewer.dart';
import 'package:grad_store_app/core/widgets/rate_widget.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';
import 'package:grad_store_app/features/cart/domain/entities/cart_item.dart';
import 'package:grad_store_app/features/cart/presentation/state/cart_provider.dart';
import 'package:grad_store_app/features/products/data/models/product_model.dart';
import '../../../../core/gen/assets.gen.dart';
import 'cart_actions.dart';

class CartListWidget extends StatelessWidget {
  const CartListWidget({super.key, required this.items, required this.cache});

  final List<CartItem> items;
  final Map<int, ProductModel> cache;

  @override
  Widget build(BuildContext context) {
    final appTypography = context.theme.appTypography;
    final appColors = context.theme.appColors;
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (final context, final index) {
        final item = items[index];
        final product = cache[item.productId];
        if (product == null) {
          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        }
        
        return Dismissible(
          key: Key(item.id.toString()),
          background: Container(
            color: appColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: AppSvgViewer(
              Assets.icons.trash,
              width: 28,
              height: 28,
              color: appColors.white,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (final direction) {
            context.read<CartProvider>().remove(item.id);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.largePadding,
              vertical: Dimens.veryLargePadding,
            ),
            child: Row(
              spacing: Dimens.largePadding,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox.shrink(),
                SizedBox(
                  height: 95,
                  width: 95,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.corners),
                    child: product.mainImage != null && product.mainImage!.isNotEmpty
                        ? Image.network(
                            product.mainImage!.startsWith('http') 
                                ? product.mainImage! 
                                : '${ApiConstants.baseUrl}${product.mainImage}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                          )
                        : Container(color: Colors.grey[300]),
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: Dimens.largePadding,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: appTypography.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          RateWidget(
                            rate: '5.0', // Fallback as product API may defer reviews
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              spacing: Dimens.largePadding,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الكمية',
                                  style: appTypography.labelMedium.copyWith(
                                    color: appColors.gray4,
                                  ),
                                ),
                                Text(
                                  '\$ ${product.price}',
                                  style: appTypography.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          CartActions(item: item),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (final context, final index) {
        return const AppDivider();
      },
    );
  }
}
