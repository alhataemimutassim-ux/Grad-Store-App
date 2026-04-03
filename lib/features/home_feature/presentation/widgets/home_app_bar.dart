import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/sized_context.dart';
import 'package:grad_store_app/core/widgets/app_icon_buttons.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/features/favorites_feature/presentation/favorites_page.dart';
import 'package:grad_store_app/core/widgets/app_search_bar.dart';

import '../../../../core/gen/assets.gen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    final typography = context.theme.appTypography;
    return Column(
      children: [
        AppBar(
          backgroundColor: colors.primary,
          actions: [
            AppIconButton(
              iconPath: Assets.icons.searchFavorite,
              onPressed: () {
                appPush(context, const FavoritesPage());
              },
            ),
            SizedBox(width: 8),
            AppIconButton(iconPath: Assets.icons.notification),
          ],
          title: Row(
            spacing: Dimens.padding,
            children: [
              AppIconButton(iconPath: Assets.icons.location),
              Column(
                spacing: Dimens.padding,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الموقع',
                    style: typography.titleSmall.copyWith(
                      color: colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'صنعاء - القادسية',
                    style: typography.titleSmall.copyWith(color: colors.white),
                  ),
                ],
              ),
            ],
          ),
          leadingWidth: 85,
          titleSpacing: Dimens.padding,
          actionsPadding: EdgeInsets.symmetric(horizontal: Dimens.largePadding),
        ),
        Stack(
          children: [
            Container(
              height: 50,
              width: context.widthPx,
              decoration: BoxDecoration(
                color: context.theme.appColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(Dimens.extraLargePadding),
                  bottomRight: Radius.circular(Dimens.extraLargePadding),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 25,
                left: Dimens.largePadding,
                right: Dimens.largePadding,
              ),
              child: AppSearchBar(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height + 80);
}
