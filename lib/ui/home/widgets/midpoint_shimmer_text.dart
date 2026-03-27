import 'package:flutter/material.dart';

class MidpointShimmerText extends StatefulWidget {
  const MidpointShimmerText({
    required this.text,
    this.style,
    this.cycleDuration = const Duration(seconds: 2),
    this.shimmerDuration = const Duration(milliseconds: 500),
    this.respectReducedMotion = true,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final Duration cycleDuration;
  final Duration shimmerDuration;
  final bool respectReducedMotion;

  @override
  State<MidpointShimmerText> createState() => _MidpointShimmerTextState();
}

class _MidpointShimmerTextState extends State<MidpointShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.cycleDuration,
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant MidpointShimmerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cycleDuration != widget.cycleDuration) {
      _controller
        ..duration = widget.cycleDuration
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData? mediaQuery = MediaQuery.maybeOf(context);
    final bool animationsDisabled =
        !TickerMode.of(context) ||
        (widget.respectReducedMotion &&
            (mediaQuery?.disableAnimations ?? false));

    final TextStyle resolvedStyle =
        widget.style ??
        Theme.of(context).textTheme.titleMedium ??
        const TextStyle();

    final Widget text = Text(
      widget.text,
      style: resolvedStyle.copyWith(fontWeight: FontWeight.bold),
    );
    if (animationsDisabled) {
      return text;
    }

    final double activeFraction =
        widget.shimmerDuration.inMicroseconds /
        widget.cycleDuration.inMicroseconds;
    if (activeFraction <= 0 || activeFraction.isNaN) {
      return text;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: text,
      builder: (BuildContext context, Widget? child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        if (_controller.value > activeFraction) {
          return child;
        }

        final double t = (_controller.value / activeFraction).clamp(0.0, 1.0);

        final ThemeData theme = Theme.of(context);
        final Color baseColor =
            resolvedStyle.color ?? theme.colorScheme.onSurface;
        final Color accentA =
            Color.lerp(baseColor, theme.colorScheme.primary, 0.98) ?? baseColor;
        final Color accentB =
            Color.lerp(baseColor, theme.colorScheme.tertiary, 1.0) ?? accentA;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            final double startX = -2.0 + (4 * t);
            final double endX = startX + 1.0;
            return LinearGradient(
              begin: Alignment(startX, 0),
              end: Alignment(endX, 0),
              colors: <Color>[
                baseColor,
                accentA,
                accentB,
                accentA,
                baseColor,
              ],
              stops: const <double>[0.2, 0.42, 0.5, 0.58, 0.8],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}
