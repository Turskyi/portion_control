import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/app.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/di/app_blocs.dart';
import 'package:portion_control/di/dependencies.dart';
import 'package:portion_control/di/dependencies_scope.dart';
import 'package:portion_control/di/injector.dart' as di;
import 'package:portion_control/router/routes.dart' as router;
import 'package:portion_control/ui/feedback/feedback_form.dart';

/// The [main] is the ultimate detail - the lowest-level policy.
/// It is the initial entry point of the system.
/// Nothing, other than the operating system, depends on it.
/// Here you should [di.injectDependencies].
/// The [main] is a dirty low-level module in the outermost circle of the onion
/// architecture.
/// Think of [main] as a plugin to the [App] - a plugin that sets
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

  // `injectDependencies` now returns a ready-to-use `Dependencies`
  // which includes an awaited `SharedPreferences` instance.
  final Dependencies dependencies = await di.injectDependencies();

  // Initialize and capture BLoC instances once to ensure state consistency
  // across the application. This is especially important for the MenuBloc,
  // which needs an initial event.
  final AppBlocs blocs = AppBlocs(
    menuBloc: dependencies.menuBloc..add(const LoadingInitialMenuStateEvent()),
    homeBloc: dependencies.homeBloc,
    settingsBloc: dependencies.settingsBloc,
    onboardingBloc: dependencies.onboardingBloc,
    dailyFoodLogHistoryBloc: dependencies.dailyFoodLogHistoryBloc,
    statsBloc: dependencies.statsBloc,
    yesterdayEntriesBloc: dependencies.yesterdayEntriesBloc,
  );

  // Resolve and apply initial app language using the dedicated use case.
  await dependencies.initializeAppLanguageUseCase.call();

  final LocalizationDelegate localizationDelegate =
      dependencies.localizationDelegate;

  final Map<String, WidgetBuilder> routeMap = router.getRouteMap(
    blocs: blocs,
  );

  runApp(
    LocalizedApp(
      localizationDelegate,
      BetterFeedback(
        feedbackBuilder:
            (
              BuildContext _,
              OnSubmit onSubmit,
              ScrollController? scrollController,
            ) {
              return FeedbackForm(
                onSubmit: onSubmit,
                scrollController: scrollController,
              );
            },
        child: DependenciesScope(
          dependencies: dependencies,
          // We wrap the `App` with `BlocProvider<MenuBloc>.value` here to make
          // the `MenuBloc` available via context throughout the app, including
          // for the `MaterialApp`'s theme selection.
          child: BlocProvider<MenuBloc>.value(
            value: blocs.menuBloc,
            child: App(routeMap: routeMap),
          ),
        ),
      ),
    ),
  );
}
