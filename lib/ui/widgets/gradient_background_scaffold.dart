import 'package:flutter/material.dart';

class GradientBackgroundScaffold extends StatelessWidget {
  const GradientBackgroundScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.persistentFooterButtons,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;

  /// The alignment of the [persistentFooterButtons] inside the [OverflowBar].
  ///
  /// Defaults to [AlignmentDirectional.centerEnd].
  final AlignmentDirectional persistentFooterAlignment;

  /// A set of buttons that are displayed at the bottom of the scaffold.
  ///
  /// Typically this is a list of [TextButton] widgets. These buttons are
  /// persistently visible, even if the [body] of the scaffold scrolls.
  ///
  /// These widgets will be wrapped in an [OverflowBar].
  ///
  /// The [persistentFooterButtons] are rendered above the
  /// [bottomNavigationBar] but below the [body].
  final List<Widget>? persistentFooterButtons;

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
        persistentFooterAlignment: persistentFooterAlignment,
        persistentFooterButtons: persistentFooterButtons,
      ),
    );
  }
}
