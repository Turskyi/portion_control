import 'package:flutter/widgets.dart';

extension ResponsiveChecks on BuildContext {
  /// The width of the screen.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The height of the screen.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  double get shortestSide => MediaQuery.sizeOf(this).shortestSide;

  /// Threshold for defining an "extra small" screen, e.g., for a watch.
  /// Based on the size of a Pixel Watch 2 (192.0 logical pixels).
  static const double _extraSmallScreenThreshold = 200.0;
  static const double _narrowScreenThreshold = 500.0;

  /// Returns `true` if the screen width is less than or equal to
  /// the [_extraSmallScreenThreshold].
  bool get isExtraSmallScreen => shortestSide <= _extraSmallScreenThreshold;

  bool get isNarrowScreen => screenWidth <= _narrowScreenThreshold;

  double get maxWidth => screenWidth > 600 ? 600 : double.infinity;
}
