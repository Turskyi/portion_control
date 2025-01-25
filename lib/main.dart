import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/infrastructure/database/database.dart';
import 'package:portion_control/infrastructure/repositories/body_weight_repository.dart';
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/app.dart';
import 'package:portion_control/ui/home_page.dart';

/// The [main] is the ultimate detail — the lowest-level policy.
/// It is the initial entry point of the system.
/// Nothing, other than the operating system, depends on it.
/// The [main] is a dirty low-level module in the outermost circle of the onion
/// architecture.
/// Think of [main] as a plugin to the [App] — a plugin that sets
/// up the initial conditions and configurations, gathers all the outside
/// resources, and then hands control over to the high-level policy of the
/// [App].
/// When [main] is released, it has utterly no effect on any of the other
/// components in the system. They don’t know about [main], and they don’t care
/// when it changes.
void main() {
  final Map<String, WidgetBuilder> routeMap = <String, WidgetBuilder>{
    AppRoute.home.path: (_) => BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            BodyWeightRepository(AppDatabase()),
          )..add(const LoadBodyWeightEntries()),
          child: const HomePage(),
        ),
  };
  runApp(
    App(
      routeMap: routeMap,
    ),
  );
}
