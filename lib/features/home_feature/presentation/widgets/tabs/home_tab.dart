import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/features/home_feature/presentation/screens/categories_screen.dart';
import 'package:grad_store_app/features/home_feature/presentation/screens/special_offers.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/banner_slider_widget.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/products_list.dart';
import 'package:grad_store_app/features/home_feature/presentation/screens/products_screen.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/flash_offers_section.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/sellers_store_section.dart';
import 'package:grad_store_app/features/slider/presentation/widgets/main_slider_widget.dart';

import '../../../../../core/widgets/app_title_widget.dart';
import '../categories_list.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ── السلايدر الرئيسي (في قمة الواجهة) ─────────────────────
          const SizedBox(height: Dimens.padding),
          const MainSliderWidget(),
          
          // ── البانر الإعلاني (عروض خاصة) ──────────────────────
          AppTitleWidget(
            onPressed: () => appPush(context, SpecialOffers()),
            title: 'عروض خاصة',
          ),
          BannerSliderWidget(),

          const SizedBox(height: 8),

          // ── قسم العروض المؤقتة السريعة ───────────────────────────
          const FlashOffersSection(),

          // ── فاصل بصري أنيق ───────────────────────────────────────
          _SectionDivider(),

          // ── قسم الفئات ───────────────────────────────────────────
          AppTitleWidget(
            onPressed: () => appPush(context, CategoriesScreen()),
            title: 'الفئات',
          ),
          CategoriesList(),

          const SizedBox(height: 8),

          // ── قسم متاجر البائعين ────────────────────────────────────
          const SellersStoreSection(),

          // ── فاصل بصري ────────────────────────────────────────────
          _SectionDivider(),

          // ── أحــدث المنتجات ─────────────────────────────────────
          const ProductsList(
            title: 'أحــدث المنتجات',
            listStrategy: ProductSortStrategy.latest,
          ),
          
          // ── فاصل بصري ────────────────────────────────────────────
          _SectionDivider(),

          // ── المنتجات الأعلى تقييماً ──────────────────────────────
          const ProductsList(
            title: 'المنتجات الأعلى تقييماً',
            listStrategy: ProductSortStrategy.topRated,
          ),

          // ── فاصل بصري ────────────────────────────────────────────
          _SectionDivider(),

          // ── المنتجات الأعلى مبيعاً ───────────────────────────────
          const ProductsList(
            title: 'المنتجات الأعلى مبيعاً',
            listStrategy: ProductSortStrategy.topSelling,
          ),

          SizedBox(height: Dimens.largePadding),
        ],
      ),
    );
  }
}

/// فاصل بصري خفيف بين الأقسام
class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
        ],
      ),
    );
  }
}

