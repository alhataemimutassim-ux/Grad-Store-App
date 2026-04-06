import 'package:flutter/material.dart';

import 'package:grad_store_app/core/utils/app_navigator.dart';

import 'package:grad_store_app/core/widgets/app_search_bar.dart';
import 'package:grad_store_app/core/widgets/app_svg_viewer.dart';

import 'package:grad_store_app/features/home_feature/presentation/screens/sort_and_filter_screen.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/theme/dimens.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/general_app_bar.dart';
import '../../../../core/widgets/shaded_container.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/features/products/presentation/state/products_provider.dart';
import 'package:grad_store_app/features/products/presentation/widgets/product_card.dart';


import 'search_screen.dart';

enum ProductSortStrategy { latest, topRated, topSelling }

class ProductsScreen extends StatelessWidget {
  final ProductSortStrategy sortStrategy;

  const ProductsScreen({super.key, this.sortStrategy = ProductSortStrategy.latest});

  @override
  Widget build(BuildContext context) {
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
            child: Hero(
              tag: 'search_bar_hero',
              child: Material(
                type: MaterialType.transparency,
                child: AppSearchBar(
                  readOnly: true,
                  onTap: () {
                    appPush(context, const SearchScreen());
                  },
                ),
              ),
            ),
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
                var items = List.of(provider.items);
                
                if (sortStrategy == ProductSortStrategy.topRated) {
                  items.sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));
                } else if (sortStrategy == ProductSortStrategy.topSelling) {
                  items.sort((a, b) => (b.reviewsCount ?? 0).compareTo(a.reviewsCount ?? 0));
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: Dimens.largePadding,
                    crossAxisSpacing: Dimens.largePadding,
                    mainAxisExtent: 210,
                  ),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (final context, final index) {
                    return ProductCard(product: items[index]);
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
