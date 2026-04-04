import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_divider.dart';

import '../../../../core/theme/dimens.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/features/cart/presentation/state/cart_provider.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';

class OrdersListForCheckout extends StatelessWidget {
  const OrdersListForCheckout({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.theme.appColors;
    return Consumer<CartProvider>(
      builder: (context, provider, child) {
        final items = provider.items;
        if (items.isEmpty) return const SizedBox.shrink();

        return ListView.separated(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (final context, final index) {
            final item = items[index];
            final product = provider.productCache[item.productId];
            final productName = product?.name ?? 'منتج غير معروف';
            final img = product?.mainImage;
            final fullUrl = img != null && img.isNotEmpty 
                ? (img.startsWith('http') ? img : '${ApiConstants.baseUrl}$img')
                : null;
            final price = product != null ? (product.price - (product.price * product.discount / 100)) : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Dimens.veryLargePadding,
              ),
              child: Row(
                spacing: Dimens.largePadding,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 95,
                    width: 95,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.corners),
                      child: fullUrl != null 
                        ? Image.network(fullUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]))
                        : Container(color: Colors.grey[300]),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: Text(
                            productName,
                            style: context.theme.appTypography.bodyLarge.copyWith(
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              spacing: Dimens.largePadding,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الكمية: ${item.quantity} قطع',
                                  style: context.theme.appTypography.labelMedium
                                      .copyWith(color: appColors.gray4),
                                ),
                                Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: context.theme.appTypography.bodyLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (final context, final index) {
            return const AppDivider();
          },
        );
      },
    );
  }
}
