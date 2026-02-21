import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/app.dart';
import 'package:portion_control/application_services/blocs/daily_food_log_history/daily_food_log_history_bloc.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/application_services/blocs/onboarding/onboarding_bloc.dart';
import 'package:portion_control/application_services/blocs/settings/settings_bloc.dart';
import 'package:portion_control/application_services/blocs/stats/stats_bloc.dart';
import 'package:portion_control/di/dependencies.dart';
import 'package:portion_control/di/dependencies_scope.dart';
import 'package:portion_control/di/injector.dart' as di;
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/router/routes.dart' as router;
import 'package:portion_control/ui/feedback/feedback_form.dart';

import 'application_services/blocs/yesterday_entries_bloc/yesterday_entries_bloc.dart';
import 'domain/services/repositories/i_settings_repository.dart';

/// The [main] is the ultimate detail — the lowest-level policy.
/// It is the initial entry point of the system.
/// Nothing, other than the operating system, depends on it.
/// Here you should [di.injectDependencies].
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

  // `injectDependencies` now returns a ready-to-use `Dependencies`
  // which includes an awaited `SharedPreferences` instance.
  final Dependencies dependencies = await di.injectDependencies();

  final ISettingsRepository settingsRepository =
      dependencies.settingsRepository;

  final SettingsBloc settingsBloc = dependencies.settingsBloc;

  final YesterdayEntriesBloc yesterdayEntriesBloc =
      dependencies.yesterdayEntriesBloc;

  final HomeBloc homeBloc = dependencies.homeBloc;

  final MenuBloc menuBloc = dependencies.menuBloc
    ..add(const LoadingInitialMenuStateEvent());

  final OnboardingBloc onboardingBloc = dependencies.onboardingBloc;

  final DailyFoodLogHistoryBloc dailyFoodLogHistoryBloc =
      dependencies.dailyFoodLogHistoryBloc;

  final StatsBloc statsBloc = dependencies.statsBloc;

  final Language language = settingsRepository.getLanguage();

  // Resolve and apply initial app language using the dedicated use case.
  await dependencies.initializeAppLanguageUseCase.call(fallback: language);

  final LocalizationDelegate localizationDelegate =
      dependencies.localizationDelegate;

  final Map<String, WidgetBuilder> routeMap = router.getRouteMap(
    settingsBloc: settingsBloc,
    homeBloc: homeBloc,
    yesterdayEntriesBloc: yesterdayEntriesBloc,
    menuBloc: menuBloc,
    onboardingBloc: onboardingBloc,
    dailyFoodLogHistoryBloc: dailyFoodLogHistoryBloc,
    statsBloc: statsBloc,
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
            value: menuBloc,
            child: App(routeMap: routeMap),
          ),
        ),
      ),
    ),
  );
}
