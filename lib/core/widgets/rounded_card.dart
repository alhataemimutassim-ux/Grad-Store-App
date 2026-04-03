import 'package:flutter/material.dart';

/// بطاقة دائرية قابلة لإعادة الاستخدام مع ظل وخيارات تفاعل
class RoundedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  // Optional size constraints for consistent card sizing
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;

  const RoundedCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: child,
      ),
    );

    Widget wrapped = card;
    if (minWidth != null || maxWidth != null || minHeight != null || maxHeight != null) {
      wrapped = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? 0,
          maxWidth: maxWidth ?? double.infinity,
          minHeight: minHeight ?? 0,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: card,
      );
    }

    if (onTap != null) {
      return InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap, child: wrapped);
    }
    return wrapped;
  }
}
