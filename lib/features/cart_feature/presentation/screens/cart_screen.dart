import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/core/widgets/app_button.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/general_app_bar.dart';
import 'package:grad_store_app/features/cart/presentation/state/cart_provider.dart';
import 'package:grad_store_app/features/cart_feature/presentation/screens/proceed_to_checkout_screen.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/widgets/app_svg_viewer.dart';
import '../widgets/cart_list_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchAll(silent: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTypography = context.theme.appTypography;
    final appColors = context.theme.appColors;
    return AppScaffold(
      padding: EdgeInsets.zero,
      appBar: GeneralAppBar(title: 'السلة', showBackIcon: false),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.status == CartStatus.loading || provider.status == CartStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.status == CartStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('حدث خطأ: ${provider.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => provider.fetchAll(silent: false),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          } else if (provider.status == CartStatus.loaded) {
            if (provider.items.isEmpty) {
              return Center(
                child: Column(
                  spacing: Dimens.largePadding,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppSvgViewer(
                      Assets.icons.shoppingCart,
                      width: 50,
                      color: appColors.gray4,
                    ),
                    Text(
                      'السلة فارغة',
                      style: appTypography.bodyLarge.copyWith(
                        color: appColors.gray4,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Expanded(child: CartListWidget(items: provider.items, cache: provider.productCache)),
                if (provider.loadingProducts)
                   const LinearProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.largePadding,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: Dimens.largePadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المجموع', style: appTypography.bodyLarge),
                          Text(
                            '\$${provider.totalAmount.toStringAsFixed(2)}',
                            style: appTypography.bodyLarge.copyWith(
                              color: appColors.primary,
                            ),
                          ),
                        ],
                      ),
                      AppButton(
                        title: 'تابع عملية الشراء',
                        onPressed: () {
                          appPush(context, const ProceedToCheckoutScreen());
                        },
                        textStyle: appTypography.bodyLarge,
                        borderRadius: Dimens.corners,
                        margin: const EdgeInsets.symmetric(
                          vertical: Dimens.largePadding,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
