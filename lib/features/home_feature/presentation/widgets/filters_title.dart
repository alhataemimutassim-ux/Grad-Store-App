import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';

class FiltersTitle extends StatelessWidget {
  const FiltersTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.largePadding),
      child: Text(
        title,
        style: context.theme.appTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
