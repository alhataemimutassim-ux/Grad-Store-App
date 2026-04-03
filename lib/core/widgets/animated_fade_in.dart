import 'package:flutter/material.dart';

class AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offsetY;

  const AnimatedFadeIn({super.key, required this.child, this.duration = const Duration(milliseconds: 450), this.offsetY = 8.0});

  @override
  State<AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<AnimatedFadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  late final Animation<Offset> _offset = Tween<Offset>(begin: Offset(0, widget.offsetY / 100), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
