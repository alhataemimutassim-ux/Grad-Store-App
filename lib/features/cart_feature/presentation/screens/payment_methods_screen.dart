import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/check_theme_status.dart';
import 'package:grad_store_app/core/widgets/app_divider.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/general_app_bar.dart';
import 'package:grad_store_app/features/cart_feature/presentation/widgets/payment_item_widget.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_button.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTypography = context.theme.appTypography;
    return AppScaffold(
      appBar: GeneralAppBar(title: 'طرق الدفع'),
      body: SingleChildScrollView(
        child: Column(
          spacing: Dimens.largePadding,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaymentItemWidget(
              onTap: () {},
              title: 'محفضة',
              iconPath: Assets.icons.money3,
            ),
            PaymentItemWidget(
              onTap: () {},
              title: 'جيب',
              iconPath: Assets.icons.wallet,
            ),
            SizedBox.shrink(),
            Text('اضافة بطاقة ائتمان', style: appTypography.bodyLarge),
            PaymentItemWidget(
              onTap: () {},
              title: 'اضاقة بطاقة',
              iconPath: Assets.icons.card,
              showRadio: false,
            ),
            SizedBox.shrink(),
            Text('المزيد من خيارات الدفع', style: appTypography.bodyLarge),
            Column(
              children: [
                PaymentItemWidget(
                  onTap: () {},
                  title: 'PayPal',
                  logoPath:
                      checkDarkMode(context) ? null : Assets.icons.paypalLogo,
                  showBorder: false,
                ),
                AppDivider(),
                PaymentItemWidget(
                  onTap: () {},
                  title: 'Apple Pay',
                  logoPath:
                      checkDarkMode(context) ? null : Assets.icons.appleLogo,
                  showBorder: false,
                ),
                AppDivider(),
                PaymentItemWidget(
                  onTap: () {},
                  title: 'Google Pay',
                  logoPath:
                      checkDarkMode(context) ? null : Assets.icons.googleLogo,
                  showBorder: false,
                ),
              ],
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
          onPressed: () {},
          title: 'تأكيد الدفع',
          textStyle: appTypography.bodyLarge,
          borderRadius: Dimens.corners,
          margin: EdgeInsets.symmetric(vertical: Dimens.largePadding),
        ),
      ),
    );
  }
}
