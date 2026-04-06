import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/core/widgets/app_title_widget.dart';
import 'package:grad_store_app/core/widgets/rate_widget.dart';
import 'package:grad_store_app/features/home_feature/presentation/screens/products_screen.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';
import 'package:grad_store_app/features/products/presentation/state/products_provider.dart';
import '../screens/product_details_screen.dart';

class ProductsList extends StatelessWidget {
  final String title;
  final ProductSortStrategy listStrategy;

  const ProductsList({
    super.key, 
    this.title = 'أحــدث المنتجات', 
    this.listStrategy = ProductSortStrategy.latest
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, provider, child) {
        if (provider.status == ProductsStatus.loading) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        var products = List.of(provider.items);

        if (listStrategy == ProductSortStrategy.topRated) {
          products.sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));
        } else if (listStrategy == ProductSortStrategy.topSelling) {
          products.sort((a, b) => (b.reviewsCount ?? 0).compareTo(a.reviewsCount ?? 0));
        }

        final displayProducts = products.take(6).toList();

        if (displayProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTitleWidget(
              title: title,
              onPressed: () {
                appPush(context, ProductsScreen(sortStrategy: listStrategy));
              },
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayProducts.length,
                shrinkWrap: true,
                itemBuilder: (final context, final index) {
                  final p = displayProducts[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: Dimens.largePadding),
                    child: InkWell(
                      onTap: () {
                        appPush(context, ProductDetailsScreen(productId: p.id));
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        height: 100,
                        width: 196,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            SizedBox(
                              height: 100,
                              width: 196,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: p.mainImage != null && p.mainImage!.isNotEmpty
                                  ? Image.network(
                                      p.mainImage!.startsWith('http') 
                                      ? p.mainImage! 
                                      : '${ApiConstants.baseUrl}${p.mainImage}',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                                    )
                                  : Container(color: Colors.grey[300]),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50,
                                  height: 24,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: Dimens.largePadding,
                                    vertical: Dimens.padding,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimens.smallCorners,
                                    ),
                                    color: context.theme.scaffoldBackgroundColor,
                                  ),
                                  child: RateWidget(
                                    rate: (p.averageRating != null && p.averageRating! > 0)
                                        ? p.averageRating!.toStringAsFixed(1)
                                        : '0.0',
                                  ),
                                ),
                                Container(
                                  width: 196,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        context.theme.appColors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        context.theme.appColors.black.withValues(
                                          alpha: 0.7,
                                        ),
                                        context.theme.appColors.black.withValues(
                                          alpha: 0.8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      p.name,
                                      style: context
                                          .theme
                                          .appTypography
                                          .titleSmall
                                          .copyWith(
                                            color: context.theme.appColors.white,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
