import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';

import 'package:grad_store_app/core/widgets/shaded_container.dart';
import 'package:grad_store_app/core/widgets/rate_widget.dart';
import 'package:grad_store_app/core/widgets/app_icon_buttons.dart';
import 'package:grad_store_app/core/widgets/animated_fade_in.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';
import 'package:grad_store_app/core/gen/assets.gen.dart';
import 'package:grad_store_app/core/utils/auth_guard.dart';

import 'package:grad_store_app/features/products/domain/entities/product.dart';
import 'package:grad_store_app/features/home_feature/presentation/screens/product_details_screen.dart';
import 'package:grad_store_app/features/cart/presentation/state/cart_provider.dart';
import 'package:grad_store_app/features/wishlist/presentation/state/wishlist_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors = context.theme.appColors;
    
    return AnimatedFadeIn(
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            onTap!();
          } else {
            appPush(context, ProductDetailsScreen(productId: product.id));
          }
        },
        child: ShadedContainer(
          child: Column(
            spacing: Dimens.padding,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimens.padding),
                child: SizedBox(
                  height: 114,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.corners),
                        child: product.mainImage != null && product.mainImage!.isNotEmpty
                            ? Image.network(
                                product.mainImage!.startsWith('http') 
                                    ? product.mainImage! 
                                    : '${ApiConstants.imageBaseUrl}${product.mainImage}',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                              )
                            : Container(color: Colors.grey[300]),
                      ),
                      
                      // Favorite Icon (Optional but nice)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Consumer<WishlistProvider>(builder: (ctx, wp, ch) {
                          final inWishlist = wp.isInWishlist(product.id);
                          return GestureDetector(
                            onTap: () async {
                              AuthGuard.checkAuth(context, onAuthenticated: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  final added = await wp.toggle(product.id);
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(added ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة'),
                                    ),
                                  );
                                } catch (e) {
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('فشل العملية بسبب خطأ في الشبكة')),
                                  );
                                }
                              });
                            },
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white.withValues(alpha: 0.8),
                              child: Icon(
                                inWishlist ? Icons.favorite : Icons.favorite_border, 
                                color: inWishlist ? Colors.red : Colors.grey,
                                size: 16,
                              ),
                            ),
                          );
                        }),
                      ),

                      // Discount Badge
                      if (product.discount > 0)
                        Positioned(
                          left: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent, 
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${product.discount.toStringAsFixed(0)}%', 
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.padding,
                ),
                child: Column(
                  spacing: Dimens.largePadding,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: Dimens.padding,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: context.theme.appTypography.titleSmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Builder(
                          builder: (ctx) {
                            double? avg;
                            try {
                              final p = product as dynamic;
                              avg = (p.averageRating == null) ? null : (p.averageRating as double?);
                            } catch (_) {
                              avg = null;
                            }
                            return RateWidget(
                              rate: (avg != null && avg > 0)
                                  ? avg.toStringAsFixed(1)
                                  : '0.0',
                            );
                          }
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${(product.discount > 0 ? (product.price * (1 - product.discount / 100)) : product.price).toStringAsFixed(2)} ر.س',
                            style: context.theme.appTypography.labelLarge
                                .copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: AppIconButton(
                            onPressed: () {
                              AuthGuard.checkAuth(context, onAuthenticated: () async {
                                try {
                                  await context.read<CartProvider>().addToCart(product.id, quantity: 1);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("${product.name} تم إضافته للسلة")),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('حدث خطأ أثناء الإضافة للسلة')),
                                    );
                                  }
                                }
                              });
                            },
                            iconPath: Assets.icons.shoppingCart,
                            backgroundColor: appColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
