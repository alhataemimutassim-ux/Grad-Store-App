import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/core/utils/sized_context.dart';
import 'package:grad_store_app/core/widgets/app_search_bar.dart';
import 'package:grad_store_app/core/widgets/app_svg_viewer.dart';
import 'package:grad_store_app/core/widgets/rate_widget.dart';
import 'package:grad_store_app/features/home_feature/presentation/screens/sort_and_filter_screen.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/widgets/app_icon_buttons.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/general_app_bar.dart';
import '../../../../core/widgets/shaded_container.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/features/products/presentation/state/products_provider.dart';
import 'package:grad_store_app/features/cart/presentation/state/cart_provider.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.theme.appColors;
    return AppScaffold(
      appBar: GeneralAppBar(
        title: 'المنتجات',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(
              left: Dimens.largePadding,
              right: Dimens.largePadding,
            ),
            child: AppSearchBar(),
          ),
        ),
        height: 128,
      ),
      body: Column(
        spacing: Dimens.largePadding,
        children: [
          SizedBox.shrink(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: Dimens.largePadding,
            children: [
              GestureDetector(
                onTap: () {
                  appPush(context, SortAndFilterScreen());
                },
                child: ShadedContainer(
                  padding: EdgeInsets.all(Dimens.largePadding),
                  borderRadius: 100,
                  child: Row(
                    spacing: Dimens.padding,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSvgViewer(Assets.icons.filterSearch, width: 16),
                      Text('تصفية'),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  appPush(context, SortAndFilterScreen());
                },
                child: ShadedContainer(
                  padding: EdgeInsets.all(Dimens.largePadding),
                  borderRadius: 100,
                  child: Row(
                    spacing: Dimens.padding,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSvgViewer(Assets.icons.sort, width: 16),
                      Text('فرز'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Consumer<ProductsProvider>(
              builder: (context, provider, child) {
                if (provider.status == ProductsStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.status == ProductsStatus.error) {
                  return Center(child: Text('Error: ${provider.error}'));
                } else if (provider.items.isEmpty) {
                  return const Center(child: Text('لا توجد منتجات.'));
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: Dimens.largePadding,
                    crossAxisSpacing: Dimens.largePadding,
                    mainAxisExtent: 210,
                  ),
                  shrinkWrap: true,
                  itemCount: provider.items.length,
                  itemBuilder: (final context, final index) {
                    final item = provider.items[index];
                    return GestureDetector(
                      onTap: () {
                         appPush(context, ProductDetailsScreen(productId: item.id));
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
                                width: context.widthPx,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimens.corners),
                                  child: item.mainImage != null && item.mainImage!.isNotEmpty
                                      ? Image.network(
                                          item.mainImage!.startsWith('http') 
                                              ? item.mainImage! 
                                              : '${ApiConstants.baseUrl}${item.mainImage}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                                        )
                                      : Container(color: Colors.grey[300]),
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
                                          item.name,
                                          style: context.theme.appTypography.titleSmall,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                     RateWidget(
                                        rate: (item.averageRating != null && item.averageRating! > 0)
                                            ? item.averageRating!.toStringAsFixed(1)
                                            : '0.0',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${item.price.toStringAsFixed(2)} ر.س',
                                        style: context.theme.appTypography.labelLarge
                                            .copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: AppIconButton(
                                          onPressed: () {
                                            context.read<CartProvider>().addToCart(item.id, quantity: 1);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("${item.name} تم إضافته للسلة")),
                                            );
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
