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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color primaryColor = colorScheme.primary;
    final Color surfaceColor = colorScheme.surface;

    final Color glowBegin = primaryColor.withValues(alpha: 0.4);
    final Color glowEnd = primaryColor.withValues(alpha: 0.9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? logoChildWidget) {
        final Color? currentColor = Color.lerp(
          glowBegin,
          glowEnd,
          _controller.value,
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: surfaceColor, width: 3),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: currentColor ?? primaryColor,
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
              border: Border.all(color: surfaceColor),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
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
