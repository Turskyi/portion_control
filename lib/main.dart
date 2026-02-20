import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:portion_control/app.dart';
import 'package:portion_control/application_services/blocs/daily_food_log_history/daily_food_log_history_bloc.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/application_services/blocs/onboarding/onboarding_bloc.dart';
import 'package:portion_control/application_services/blocs/settings/settings_bloc.dart';
import 'package:portion_control/application_services/blocs/stats/stats_bloc.dart';
import 'package:portion_control/application_services/interactors/clear_tracking_data_use_case.dart';
import 'package:portion_control/di/dependencies.dart';
import 'package:portion_control/di/dependencies_scope.dart';
import 'package:portion_control/di/injector.dart' as di;
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/services/interactors/i_clear_tracking_data_use_case.dart';
import 'package:portion_control/domain/services/interactors/save_language_use_case.dart';
import 'package:portion_control/domain/services/interactors/use_case.dart';
import 'package:portion_control/domain/services/repositories/i_body_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_food_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_preferences_repository.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/database.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/infrastructure/repositories/body_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/food_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/settings_repository.dart';
import 'package:portion_control/infrastructure/repositories/user_preferences_repository.dart';
import 'package:portion_control/localization/localization_delegate_getter.dart'
    as localization;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/router/routes.dart' as router;
import 'package:portion_control/services/home_widget_service.dart';
import 'package:portion_control/ui/feedback/feedback_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application_services/blocs/yesterday_entries_bloc/yesterday_entries_bloc.dart';
import 'domain/services/repositories/i_settings_repository.dart';
import 'domain/services/repositories/i_tracking_repository.dart';
import 'infrastructure/repositories/tracking_repository.dart';

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

  //TODO: make `injectDependencies` to return Dependencies class, move
  // `await SharedPreferences.getInstance();` inside the `injectDependencies`
  // and get an instance of "SharedPreferences" out of it.
  await di.injectDependencies();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final AppDatabase appDatabase = AppDatabase();

  final LocalDataSource localDataSource = LocalDataSource(prefs, appDatabase);

  final Dependencies dependencies = Dependencies(localDataSource);

  final IUserPreferencesRepository userPreferencesRepository =
      UserPreferencesRepository(
        localDataSource,
      );

  final IBodyWeightRepository bodyWeightRepository = BodyWeightRepository(
    localDataSource,
  );

  final ISettingsRepository settingsRepository = SettingsRepository(
    localDataSource,
  );

  final IFoodWeightRepository foodWeightRepository = FoodWeightRepository(
    localDataSource,
  );

  final ITrackingRepository trackingRepository = TrackingRepository(
    localDataSource,
  );

  final IClearTrackingDataUseCase clearTrackingDataUseCase =
      ClearTrackingDataUseCase(
        trackingRepository,
      );

  final UseCase<Future<bool>, String> saveLanguageUseCase = SaveLanguageUseCase(
    localDataSource,
  );

  final HomeWidgetService homeWidgetService = const HomeWidgetServiceImpl();

  final SettingsBloc settingsBloc = SettingsBloc(settingsRepository);

  final YesterdayEntriesBloc yesterdayEntriesBloc = YesterdayEntriesBloc(
    foodWeightRepository,
  );

  final HomeBloc homeBloc = HomeBloc(
    userPreferencesRepository,
    bodyWeightRepository,
    foodWeightRepository,
    clearTrackingDataUseCase,
    homeWidgetService,
  );

  final MenuBloc menuBloc = MenuBloc(
    settingsRepository,
    homeWidgetService,
    bodyWeightRepository,
    foodWeightRepository,
    userPreferencesRepository,
  )..add(const LoadingInitialMenuStateEvent());

  final OnboardingBloc onboardingBloc = OnboardingBloc(
    saveLanguageUseCase,
    localDataSource,
  );

  final DailyFoodLogHistoryBloc dailyFoodLogHistoryBloc =
      DailyFoodLogHistoryBloc(
        foodWeightRepository,
      );

  final StatsBloc statsBloc = StatsBloc(
    foodWeightRepository,
    bodyWeightRepository,
  );

  Language initialLanguage = settingsRepository.getLanguage();

  if (kIsWeb) {
    // Retrieves the host name (e.g., "localhost" or "uk.portioncontrol.ca").
    initialLanguage = await _resolveInitialLanguageFromUrl(
      initialLanguage: initialLanguage,
      localDataSource: localDataSource,
    );
  }

  final LocalizationDelegate localizationDelegate = await localization
      .getLocalizationDelegate(localDataSource);

  final Language currentLanguage = Language.fromIsoLanguageCode(
    localizationDelegate.currentLocale.languageCode,
  );

  if (initialLanguage != currentLanguage) {
    _applyInitialLocale(
      initialLanguage: initialLanguage,
      localizationDelegate: localizationDelegate,
    );
  }

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

Future<Language> _resolveInitialLanguageFromUrl({
  required Language initialLanguage,
  required LocalDataSource localDataSource,
}) async {
  // Retrieves the host name (e.g., "localhost" or "uk.portioncontrol.ca").
  final String host = Uri.base.host;

  // Retrieves the fragment (e.g., "/en" or "/uk").
  final String fragment = Uri.base.fragment;

  for (final Language language in Language.values) {
    final String currentLanguageCode = language.isoLanguageCode;
    if (host.startsWith('$currentLanguageCode.') ||
        fragment.contains('${AppRoute.home.path}$currentLanguageCode')) {
      try {
        Intl.defaultLocale = currentLanguageCode;
      } catch (e, stackTrace) {
        debugPrint(
          'Failed to set Intl.defaultLocale to "$currentLanguageCode".\n'
          'Error: $e\n'
          'StackTrace: $stackTrace\n'
          'Proceeding with previously set default locale or system default.',
        );
      }
      initialLanguage = language;
      // We save it so the rest of the app (like recommendations) uses this
      // language.
      await localDataSource.saveLanguageIsoCode(currentLanguageCode);
      break;
    }
  }
  return initialLanguage;
}

void _applyInitialLocale({
  required Language initialLanguage,
  required LocalizationDelegate localizationDelegate,
}) {
  final Locale locale = localeFromString(initialLanguage.isoLanguageCode);

  localizationDelegate.changeLocale(locale);

  // Notify listeners that the locale has changed so they can update.
  localizationDelegate.onLocaleChanged?.call(locale);
}
