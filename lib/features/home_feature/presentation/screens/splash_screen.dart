import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/core/utils/check_device_size.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/login_a_page.dart';

import 'package:provider/provider.dart';
import '../../../../core/gen/assets.gen.dart';
import 'package:grad_store_app/features/categories/presentation/state/categories_provider.dart';
import 'package:grad_store_app/features/products/presentation/state/products_provider.dart';
import 'package:grad_store_app/features/offers/presentation/state/offers_provider.dart';
import 'package:grad_store_app/features/cart/presentation/state/cart_provider.dart';
import 'package:grad_store_app/features/orders/presentation/state/orders_provider.dart';
import 'package:grad_store_app/features/studentprofile/presentation/state/student_profile_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesProvider>().fetchAll();
      context.read<ProductsProvider>().fetchAll();
      context.read<OffersProvider>().fetchPublicOffers();
      context.read<CartProvider>().fetchAll();
      context.read<OrdersProvider>().fetchMyOrders();
      context.read<StudentProfileProvider>().fetchProfile();
    });
    Timer(const Duration(milliseconds: 1500), () {
      appPushReplacement(context, const LoginaPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    return AppScaffold(
      backgroundColor: colors.brownExtraLight,
      padding: EdgeInsets.zero,
      safeAreaTop: false,
      body: SingleChildScrollView(
        child: Column(
          spacing: Dimens.largePadding,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Assets.images.splashHeader.image(),
            Assets.images.logo.image(
              width: checkVerySmallDeviceSize(context) ? 290 : 390,
            ),
            SizedBox(height: Dimens.largePadding),
            Assets.images.cake.image(
              width: checkVerySmallDeviceSize(context) ? 205 : 305,
            ),
          ],
        ),
      ),
    );
  }
}
