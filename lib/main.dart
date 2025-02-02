import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/infrastructure/database/database.dart';
import 'package:portion_control/infrastructure/repositories/body_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/food_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/user_details_repository.dart';
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/app.dart';
import 'package:portion_control/ui/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
Future<void> main() async {
  // Ensure that the Flutter engine is initialized, to avoid errors with
  // `SharedPreferences` dependencies initialization.
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AppDatabase appDatabase = AppDatabase();

  final Map<String, WidgetBuilder> routeMap = <String, WidgetBuilder>{
    AppRoute.home.path: (_) => BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            UserDetailsRepository(prefs),
            BodyWeightRepository(appDatabase),
            const FoodWeightRepository(),
          )..add(const LoadEntries()),
          child: const HomePage(),
        ),
  };
  runApp(
    App(
      routeMap: routeMap,
    ),
  );
}
