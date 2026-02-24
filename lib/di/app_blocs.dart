import 'package:portion_control/application_services/blocs/daily_food_log_history/daily_food_log_history_bloc.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/application_services/blocs/onboarding/onboarding_bloc.dart';
import 'package:portion_control/application_services/blocs/settings/settings_bloc.dart';
import 'package:portion_control/application_services/blocs/stats/stats_bloc.dart';
import 'package:portion_control/application_services/blocs/yesterday_entries_bloc/yesterday_entries_bloc.dart';

/// A container for the BLoC instances that are shared across routes.
/// This ensures that stateful BLoCs (like MenuBloc) are consistent
/// throughout the application's lifecycle.
class AppBlocs {
  const AppBlocs({
    required this.menuBloc,
    required this.homeBloc,
    required this.settingsBloc,
    required this.onboardingBloc,
    required this.dailyFoodLogHistoryBloc,
    required this.statsBloc,
    required this.yesterdayEntriesBloc,
  });

  final MenuBloc menuBloc;
  final HomeBloc homeBloc;
  final SettingsBloc settingsBloc;
  final OnboardingBloc onboardingBloc;
  final DailyFoodLogHistoryBloc dailyFoodLogHistoryBloc;
  final StatsBloc statsBloc;
  final YesterdayEntriesBloc yesterdayEntriesBloc;
}
