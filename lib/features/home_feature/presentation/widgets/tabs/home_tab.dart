import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/features/home_feature/presentation/screens/categories_screen.dart';
import 'package:grad_store_app/features/home_feature/presentation/screens/special_offers.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/banner_slider_widget.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/products_list.dart';

import '../../../../../core/widgets/app_title_widget.dart';
import '../categories_list.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppTitleWidget(
            onPressed: () {
              appPush(context, SpecialOffers());
            },
            title: 'عروض خاصة',
          ),
          BannerSliderWidget(),
          AppTitleWidget(
            onPressed: () {
              appPush(context, CategoriesScreen());
            },
            title: 'الفئات',
          ),
          CategoriesList(),
          ProductsList(),
          SizedBox(height: Dimens.largePadding),
        ],
      ),
    );
  }
}
