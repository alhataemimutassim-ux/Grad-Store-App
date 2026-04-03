import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_divider.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/filters_title.dart';

import '../../../../core/theme/dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/general_app_bar.dart';
import '../../data/data_source/local/sample_data.dart';
import '../widgets/sort_and_filter_list.dart';

class SortAndFilterScreen extends StatelessWidget {
  const SortAndFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTypography = context.theme.appTypography;
    return AppScaffold(
      appBar: GeneralAppBar(title: 'فرز & تصفيه'),
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        child: Column(
          spacing: Dimens.largePadding,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.shrink(),
            FiltersTitle(title: 'فرز'),
            SortAndFilterList(
              titles: [
                'اعلئ الدرجات',
                'الأقرب',
                'الأحدث',
                'الأرخص',
                'الأكثر',
                'الاصغر',
                'الأرخص',
                'الأرخص',
              ],
            ),
            AppDivider(
              indent: Dimens.largePadding,
              endIndent: Dimens.largePadding,
            ),
            FiltersTitle(title: 'فئات'),
            SortAndFilterList(titles: ['الجميع', ...titlesOfCategories]),
            AppDivider(
              indent: Dimens.largePadding,
              endIndent: Dimens.largePadding,
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
          title: 'تطبيق الفلتر',
          textStyle: appTypography.bodyLarge,
          borderRadius: Dimens.corners,
          margin: EdgeInsets.symmetric(vertical: Dimens.largePadding),
        ),
      ),
    );
  }
}
