import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_text_button.dart';

import '../gen/assets.gen.dart';
import '../theme/dimens.dart';

class AppTitleWidget extends StatelessWidget {
  const AppTitleWidget({
    super.key,
    required this.title,
    this.thumbnailPath,
    required this.onPressed,
  });

  final String title;
  final String? thumbnailPath;
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: Dimens.largePadding,
            children: [
              if (thumbnailPath != null)
                Image.asset(thumbnailPath!, width: 34, height: 34),
              Text(
                title,
                style: context.theme.appTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppTextButton(
            onPressed: onPressed,
            title: 'عرض الكل',
            iconPath: Assets.icons.arrowRight1,
          ),
        ],
      ),
    );
  }
}
