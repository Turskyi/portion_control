import 'package:flutter/material.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;

class GlowingAnimatedBox extends StatefulWidget {
  const GlowingAnimatedBox({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  State<GlowingAnimatedBox> createState() => _GlowingAnimatedBoxState();
}

class _GlowingAnimatedBoxState extends State<GlowingAnimatedBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _glowColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowColor = ColorTween(
      begin: Colors.pinkAccent.withOpacity(0.4),
      end: Colors.pinkAccent.withOpacity(0.9),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowColor,
      builder: (_, Widget? logoChildWidget) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _glowColor.value ?? Colors.pinkAccent,
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: logoChildWidget,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.white),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: InkWell(
              onTap: widget.onTap,
              child: Ink.image(
                image: const AssetImage('${constants.imagePath}logo.png'),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
