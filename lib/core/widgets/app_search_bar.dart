import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/shaded_container.dart';

import '../gen/assets.gen.dart';
import '../theme/dimens.dart';
import 'app_svg_viewer.dart';

class AppSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final bool autofocus;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final String hintText;

  const AppSearchBar({
    super.key,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.autofocus = false,
    this.controller,
    this.suffixIcon,
    this.hintText = 'ابحث عن مستلزماتك',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    return ShadedContainer(
      height: 50,
      child: Center(
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
          autofocus: autofocus,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          onTap: onTap,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            hintText: hintText,
            hintStyle: TextStyle(color: colors.gray2, fontSize: 13),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.mediumPadding,
              ),
              child: AppSvgViewer(Assets.icons.searchNormal1),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 24),
            suffixIcon: suffixIcon,
            suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 24),
          ),
        ),
      ),
    );
  }
}
