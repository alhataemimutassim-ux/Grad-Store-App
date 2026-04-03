import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/check_theme_status.dart';

class BorderedContainer extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final double? borderRadius;

  const BorderedContainer({
    super.key,
    required this.child,
    this.borderColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      constraints: constraints,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color:
              borderColor ??
              (checkDarkMode(context)
                  ? context.theme.appColors.gray.withValues(alpha: 0.2)
                  : context.theme.appColors.gray),
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? Dimens.corners),
      ),
      child: child,
    );
  }
}
