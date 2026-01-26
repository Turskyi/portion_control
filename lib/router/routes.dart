import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';
import 'package:portion_control/application_services/blocs/daily_food_log_history/daily_food_log_history_bloc.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/application_services/blocs/onboarding/onboarding_bloc.dart';
import 'package:portion_control/application_services/blocs/settings/settings_bloc.dart';
import 'package:portion_control/application_services/blocs/stats/stats_bloc.dart';
import 'package:portion_control/application_services/blocs/yesterday_entries_bloc/yesterday_entries_bloc.dart';
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/about/about_page.dart';
import 'package:portion_control/ui/daily_food_log_history/daily_food_log_history_page.dart';
import 'package:portion_control/ui/educational/educational_content_page.dart';
import 'package:portion_control/ui/home/home_page.dart';
import 'package:portion_control/ui/landing/landing_page.dart';
import 'package:portion_control/ui/onboarding/onboarding_screen.dart';
import 'package:portion_control/ui/privacy/privacy_policy_page.dart';
import 'package:portion_control/ui/recipes/weight_loss_recipes_page.dart';
import 'package:portion_control/ui/stats/stats_page.dart';
import 'package:portion_control/ui/support/support_page.dart';

Map<String, WidgetBuilder> getRouteMap({
  required SettingsBloc settingsBloc,
  required HomeBloc homeBloc,
  required YesterdayEntriesBloc yesterdayEntriesBloc,
  required MenuBloc menuBloc,
  required OnboardingBloc onboardingBloc,
  required DailyFoodLogHistoryBloc dailyFoodLogHistoryBloc,
  required StatsBloc statsBloc,
}) {
  return <String, WidgetBuilder>{
    AppRoute.landing.path: (BuildContext _) {
      return BlocProvider<SettingsBloc>(
        create: (BuildContext _) => settingsBloc,
        child: const LandingPage(),
      );
    },
    AppRoute.home.path: (BuildContext _) {
      return MultiBlocProvider(
        providers: <SingleChildWidget>[
          BlocProvider<HomeBloc>(
            create: (BuildContext _) => homeBloc..add(const LoadEntries()),
          ),
          BlocProvider<YesterdayEntriesBloc>(
            create: (BuildContext _) => yesterdayEntriesBloc,
          ),
          BlocProvider<MenuBloc>.value(
            value: menuBloc,
          ),
          BlocProvider<SettingsBloc>(
            create: (BuildContext _) => settingsBloc,
          ),
        ],
        child: const HomePage(),
      );
    },
    AppRoute.onboarding.path: (BuildContext _) {
      return BlocProvider<OnboardingBloc>(
        create: (BuildContext _) => onboardingBloc,
        child: const OnboardingScreen(),
      );
    },
    AppRoute.privacyPolity.path: (BuildContext _) => const PrivacyPolicyPage(),
    AppRoute.about.path: (BuildContext _) => const AboutPage(),
    AppRoute.support.path: (BuildContext _) => const SupportPage(),
    AppRoute.recipes.path: (BuildContext _) => const WeightLossRecipesPage(),
    AppRoute.educationalContent.path: (BuildContext _) {
      return const EducationalContentPage();
    },
    AppRoute.dailyFoodLogHistory.path: (BuildContext _) {
      return BlocProvider<DailyFoodLogHistoryBloc>(
        create: (BuildContext _) {
          return dailyFoodLogHistoryBloc..add(LoadDailyFoodLogHistoryEvent());
        },
        child: const DailyFoodLogHistoryPage(),
      );
    },
    AppRoute.stats.path: (BuildContext _) {
      return BlocProvider<StatsBloc>(
        create: (BuildContext _) => statsBloc..add(const LoadStatsEvent()),
        child: const StatsPage(),
      );
    },
  };
}
