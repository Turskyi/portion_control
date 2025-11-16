import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:portion_control/di/dependencies.dart';
import 'package:portion_control/extensions/context_extension.dart';

/// {@template dependencies_scope}
/// A widget which is responsible for providing the dependencies.
/// {@endtemplate}
class DependenciesScope extends InheritedWidget {
  /// {@macro dependencies_scope}
  const DependenciesScope({
    required this.dependencies,
    required super.child,
    super.key,
  });

  /// The dependencies
  final Dependencies dependencies;

  /// Get the dependencies from the [context].
  static Dependencies of(BuildContext context) => context
      .findInheritedWidgetOrThrow<DependenciesScope>(
        listen: false,
      )
      .dependencies;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Dependencies>('dependencies', dependencies),
    );
  }

  @override
  bool updateShouldNotify(DependenciesScope oldWidget) => false;
}
