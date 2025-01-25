import 'package:flutter/material.dart';

class GradientBackgroundScaffold extends StatelessWidget {
  const GradientBackgroundScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          // Gradient radius.
          radius: 1.5,
          colors: <Color>[
            // Theme-defined background color.
            colorScheme.background,
            // Theme-defined secondary color.
            colorScheme.secondary,
          ],
          stops: const <double>[0.2, 1.0],
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: appBar,
        drawer: drawer,
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
