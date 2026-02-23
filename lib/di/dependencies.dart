import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/daily_food_log_history/daily_food_log_history_bloc.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/application_services/blocs/onboarding/onboarding_bloc.dart';
import 'package:portion_control/application_services/blocs/settings/settings_bloc.dart';
import 'package:portion_control/application_services/blocs/stats/stats_bloc.dart';
import 'package:portion_control/application_services/blocs/yesterday_entries_bloc/yesterday_entries_bloc.dart';
import 'package:portion_control/application_services/interactors/clear_tracking_data_use_case.dart';
import 'package:portion_control/application_services/interactors/initialize_app_language_use_case.dart';
import 'package:portion_control/domain/services/interactors/i_clear_tracking_data_use_case.dart';
import 'package:portion_control/domain/services/interactors/save_language_use_case.dart';
import 'package:portion_control/domain/services/interactors/use_case.dart';
import 'package:portion_control/domain/services/repositories/i_body_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_food_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_preferences_repository.dart';
import 'package:portion_control/domain/services/repositories/i_settings_repository.dart';
import 'package:portion_control/domain/services/repositories/i_tracking_repository.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/infrastructure/repositories/body_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/food_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/settings_repository.dart';
import 'package:portion_control/infrastructure/repositories/tracking_repository.dart';
import 'package:portion_control/infrastructure/repositories/user_preferences_repository.dart';
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/services/home_widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dependencies container.
class Dependencies {
  const Dependencies(
    this._localDataSource,
    this.sharedPreferences,
    this.localizationDelegate,
  );

  final LocalDataSource _localDataSource;
  final SharedPreferences sharedPreferences;
  final LocalizationDelegate localizationDelegate;

  /// Expose the local data source for callers that need it.
  LocalDataSource get localDataSource => _localDataSource;

  UseCase<Future<bool>, String> get saveLanguageUseCase {
    return SaveLanguageUseCase(_localDataSource);
  }

  IUserPreferencesRepository get userPreferencesRepository {
    return UserPreferencesRepository(_localDataSource);
  }

  IBodyWeightRepository get bodyWeightRepository {
    return BodyWeightRepository(_localDataSource);
  }

  IFoodWeightRepository get foodWeightRepository {
    return FoodWeightRepository(_localDataSource);
  }

  ISettingsRepository get settingsRepository {
    return SettingsRepository(_localDataSource);
  }

  ITrackingRepository get trackingRepository {
    return TrackingRepository(_localDataSource);
  }

  IClearTrackingDataUseCase get clearTrackingDataUseCase {
    return ClearTrackingDataUseCase(trackingRepository);
  }

  HomeWidgetService get homeWidgetService {
    return const HomeWidgetServiceImpl();
  }

  SettingsBloc get settingsBloc {
    return SettingsBloc(settingsRepository);
  }

  YesterdayEntriesBloc get yesterdayEntriesBloc {
    return YesterdayEntriesBloc(foodWeightRepository);
  }

  HomeBloc get homeBloc {
    return HomeBloc(
      userPreferencesRepository,
      bodyWeightRepository,
      foodWeightRepository,
      clearTrackingDataUseCase,
      homeWidgetService,
    );
  }

  MenuBloc get menuBloc {
    return MenuBloc(
      settingsRepository,
      homeWidgetService,
      bodyWeightRepository,
      foodWeightRepository,
      userPreferencesRepository,
    );
  }

  OnboardingBloc get onboardingBloc {
    return OnboardingBloc(saveLanguageUseCase, localDataSource);
  }

  DailyFoodLogHistoryBloc get dailyFoodLogHistoryBloc {
    return DailyFoodLogHistoryBloc(foodWeightRepository);
  }

  StatsBloc get statsBloc {
    return StatsBloc(foodWeightRepository, bodyWeightRepository);
  }

  InitializeAppLanguageUseCase get initializeAppLanguageUseCase {
    return InitializeAppLanguageUseCase(_localDataSource, localizationDelegate);
  }

  String get initialRoute {
    if (kIsWeb) {
      return AppRoute.landing.path;
    } else {
      return _localDataSource.isOnboardingCompleted()
          ? AppRoute.home.path
          : AppRoute.onboarding.path;
    }
  }
}
