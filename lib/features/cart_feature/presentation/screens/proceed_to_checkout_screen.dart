import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/core/widgets/app_divider.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/app_svg_viewer.dart';
import 'package:grad_store_app/core/widgets/bordered_container.dart';
import 'package:grad_store_app/core/widgets/general_app_bar.dart';
import 'package:grad_store_app/features/cart_feature/presentation/screens/change_address_screen.dart';
import 'package:grad_store_app/features/cart_feature/presentation/screens/payment_methods_screen.dart';
import 'package:grad_store_app/features/cart_feature/presentation/widgets/orders_list_for_checkout.dart';
import 'package:grad_store_app/features/cart_feature/presentation/widgets/payment_details_item.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_button.dart';

import 'package:provider/provider.dart';
import 'package:grad_store_app/features/cart/presentation/state/cart_provider.dart';
import 'package:grad_store_app/features/cart/presentation/state/checkout_provider.dart';

class ProceedToCheckoutScreen extends StatelessWidget {
  const ProceedToCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTypography = context.theme.appTypography;
    final appColors = context.theme.appColors;
    final cartProvider = context.watch<CartProvider>();
    final checkoutProvider = context.watch<CheckoutProvider>();
    
    final subtotal = cartProvider.totalAmount;
    final deliveryFee = subtotal > 0 ? 10.0 : 0.0;
    final total = subtotal + deliveryFee;

    return AppScaffold(
      appBar: GeneralAppBar(title: 'المتابعة الئ الدفع'),
      body: SingleChildScrollView(
        child: Column(
          spacing: Dimens.largePadding,
          children: [
            SizedBox.shrink(),
            BorderedContainer(
              padding: EdgeInsets.symmetric(horizontal: Dimens.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Dimens.largePadding,
                    ),
                    child: Text(
                      'تفاصيل الدفع',
                      style: appTypography.bodyLarge .copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AppDivider(),
                  PaymentDetailsItem(
                    title: 'السعر الفرعي',
                    subtitle: '\$${subtotal.toStringAsFixed(2)}',
                  ),
                  PaymentDetailsItem(
                    title: 'التوصيل', 
                    subtitle: '\$${deliveryFee.toStringAsFixed(2)}'
                  ),
                  Text(
                    ' - - - - - - - -' * 10,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    style: TextStyle(color: appColors.gray2),
                  ),
                  PaymentDetailsItem(
                    title: 'التكلفة الإجمالية', 
                    subtitle: '\$${total.toStringAsFixed(2)}'
                  ),
                ],
              ),
            ),
            BorderedContainer(
              padding: EdgeInsets.symmetric(horizontal: Dimens.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimens.padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'عنوان الوجهه',
                          style: appTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        BorderedContainer(
                          borderColor: appColors.primary,
                          borderRadius: Dimens.smallCorners,
                          child: InkWell(
                            onTap: () {
                              appPush(context, ChangeAddressScreen());
                            },
                            borderRadius: BorderRadius.circular(
                              Dimens.smallCorners,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(Dimens.padding),
                              child: Text(
                                ' تغيير العنوان',
                                style: TextStyle(color: appColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimens.largePadding),
                  AppDivider(),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: Dimens.smallPadding,
                    ),
                    leading: AppSvgViewer(
                      Assets.icons.location,
                      color: appColors.primary,
                    ),
                    title: Text(
                      checkoutProvider.address.isEmpty || checkoutProvider.address == 'العنوان الافتراضي - قيد التطوير'
                          ? 'لم يتم تحديد عنوان، الرجاء إضافة عنوان!'
                          : checkoutProvider.address,
                      style: appTypography.titleSmall.copyWith(
                        color: (checkoutProvider.address.isEmpty || checkoutProvider.address == 'العنوان الافتراضي - قيد التطوير')
                          ? appColors.error
                          : appColors.gray4,
                      ),
                    ),
                    subtitle: (checkoutProvider.phone.isNotEmpty && checkoutProvider.phone != '0500000000') ? Text(
                      checkoutProvider.phone,
                      style: appTypography.bodySmall.copyWith(color: appColors.gray4),
                    ) : null,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'قائمة الطلبات',
                    style: appTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: Dimens.largePadding),
                  AppDivider(),
                  OrdersListForCheckout(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: Dimens.largePadding,
          right: Dimens.largePadding,
          bottom: Dimens.padding,
        ),
        child: AppButton(
          onPressed: () {
            if (checkoutProvider.address.isEmpty || checkoutProvider.address == 'العنوان الافتراضي - قيد التطوير' ||
                checkoutProvider.phone.isEmpty || checkoutProvider.phone == '0500000000') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الرجاء إضافة عنوان التوصيل ورقم الهاتف أولاً')),
              );
              return;
            }
            appPush(context, PaymentMethodsScreen());
          },
          title: 'متابعة الدفع',
          textStyle: appTypography.bodyLarge,
          borderRadius: Dimens.corners,
          margin: EdgeInsets.symmetric(vertical: Dimens.largePadding),
        ),
      ),
    );
  }
}
