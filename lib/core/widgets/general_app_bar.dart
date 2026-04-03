import 'package:flutter/material.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';

import '../gen/assets.gen.dart';
import '../theme/dimens.dart';
import 'app_bordered_icon_button.dart';

class GeneralAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GeneralAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackIcon = true,
    this.bottom,
    this.height,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBackIcon;
  final PreferredSizeWidget? bottom;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: actions,
      title: Text(title),
      leading:
          showBackIcon
              ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.largePadding,
                ),
                child: AppBorderedIconButton(
                  iconPath: Assets.icons.arrowLeft,
                  onPressed: () {
                    appPop(context);
                  },
                ),
              )
              : null,
      leadingWidth: 90.0,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(height ?? AppBar().preferredSize.height + 16.0);
}
