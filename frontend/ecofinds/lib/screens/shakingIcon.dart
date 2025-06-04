import 'package:flutter/material.dart';
class ShakingIcon extends StatefulWidget {
  final Icon icon;
  final Duration duration;

  const ShakingIcon({super.key, required this.icon, this.duration = const Duration(milliseconds: 800)});

  @override
  State<ShakingIcon> createState() => _ShakingIconState();
}

class _ShakingIconState extends State<ShakingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween(begin: -4.0, end: 4.0).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnimation.value, 0),
          child: widget.icon,
        );
      },
    );
  }
}