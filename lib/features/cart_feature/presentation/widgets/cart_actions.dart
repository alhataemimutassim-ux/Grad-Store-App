import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/check_theme_status.dart';

import 'package:grad_store_app/features/cart/domain/entities/cart_item.dart';
import 'package:grad_store_app/features/cart/presentation/state/cart_provider.dart';

class CartActions extends StatelessWidget {
  const CartActions({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final appColors = context.theme.appColors;
    final appTypography = context.theme.appTypography;
    final cartProvider = context.read<CartProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Dimens.largePadding,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: appColors.gray2,
            borderRadius: BorderRadius.circular(4),
          ),
          child: InkWell(
            onTap: () async {
              try {
                if (item.quantity > 1) {
                  await cartProvider.changeQuantity(item.id, item.quantity - 1);
                } else {
                  await cartProvider.remove(item.id);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('حدث خطأ أثناء تحديث الكمية')),
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: Icon(
              Icons.remove,
              size: 16,
              color: checkDarkMode(context) ? appColors.black : appColors.white,
            ),
          ),
        ),
        Text(item.quantity.toString(), style: appTypography.bodyLarge),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: appColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: InkWell(
            onTap: () async {
              try {
                await cartProvider.changeQuantity(item.id, item.quantity + 1);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('حدث خطأ أثناء تحديث الكمية')),
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: Icon(Icons.add, size: 16, color: appColors.white),
          ),
        ),
      ],
    );
  }
}
