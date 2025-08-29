import 'package:flutter/material.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        if (constraints.maxWidth > constants.wideScreenThreshold) {
          return Center(
            child: SizedBox(
              width: constants.wideScreenContentWidth,
              child: child,
            ),
          );
        } else {
          return child;
        }
      },
    );
  }
}
