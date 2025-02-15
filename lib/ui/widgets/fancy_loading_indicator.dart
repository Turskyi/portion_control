import 'package:flutter/material.dart';

class FancyLoadingIndicator extends StatefulWidget {
  const FancyLoadingIndicator({super.key});

  @override
  State<FancyLoadingIndicator> createState() => _FancyLoadingIndicatorState();
}

class _FancyLoadingIndicatorState extends State<FancyLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color primaryColor = colorScheme.primary;
    final Color backgroundColor = colorScheme.background;
    _colorTween = _controller.drive(
      ColorTween(
        // Background color from theme.
        begin: backgroundColor,
        // Primary color from theme.
        end: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CircularProgressIndicator(
          valueColor: _colorTween,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
