import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/app_search_bar.dart';
import 'package:grad_store_app/core/widgets/app_svg_viewer.dart';
import 'package:grad_store_app/features/products/presentation/state/products_provider.dart';

import '../../../../core/gen/assets.gen.dart';
import 'package:grad_store_app/features/products/presentation/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear search query initially when opening screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().searchProducts('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<ProductsProvider>().searchProducts(query);
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.read<ProductsProvider>().addRecentSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    final typography = context.theme.appTypography;

    return AppScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: colors.primary,
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Hero(
                  tag: 'search_bar_hero',
                  child: Material(
                    type: MaterialType.transparency,
                    child: AppSearchBar(
                      autofocus: true,
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: _onSearchSubmitted,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                                setState(() {}); // To update suffix icon
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<ProductsProvider>(
        builder: (context, provider, child) {
          final query = provider.searchQuery.trim();
          
          if (query.isEmpty) {
            return _buildRecentSearches(context, provider);
          }

          final results = provider.searchResults;

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppSvgViewer(Assets.icons.searchNormal1, color: colors.gray2, width: 80, height: 80),
                  const SizedBox(height: Dimens.padding),
                  Text('لا توجد نتائج مطابقة لبحثك', style: typography.bodyLarge.copyWith(color: colors.gray)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(Dimens.padding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 210,
              crossAxisSpacing: Dimens.largePadding,
              mainAxisSpacing: Dimens.largePadding,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return ProductCard(product: results[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context, ProductsProvider provider) {
    final recent = provider.recentSearches;
    if (recent.isEmpty) {
      return Center(
        child: Text('اكتب شيئاً للبحث...', style: context.theme.appTypography.bodyLarge.copyWith(color: context.theme.appColors.gray2)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(Dimens.padding),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('عمليات البحث الأخيرة', style: context.theme.appTypography.titleSmall),
            TextButton(
              onPressed: () => provider.clearRecentSearches(),
              child: const Text('مسح السجل'),
            ),
          ],
        ),
        const SizedBox(height: Dimens.smallPadding),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recent.map((query) {
            return ActionChip(
              label: Text(query),
              backgroundColor: context.theme.appColors.gray.withValues(alpha: 0.1),
              onPressed: () {
                _searchController.text = query;
                _onSearchChanged(query);
                _onSearchSubmitted(query);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
