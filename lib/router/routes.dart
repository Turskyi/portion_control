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
import 'package:portion_control/di/dependencies.dart';
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
  required Dependencies dependencies,
}) {
  final SettingsBloc settingsBloc = dependencies.settingsBloc;
  final HomeBloc homeBloc = dependencies.homeBloc;
  final YesterdayEntriesBloc yesterdayEntriesBloc =
      dependencies.yesterdayEntriesBloc;
  final MenuBloc menuBloc = dependencies.menuBloc;
  final OnboardingBloc onboardingBloc = dependencies.onboardingBloc;
  final DailyFoodLogHistoryBloc dailyFoodLogHistoryBloc =
      dependencies.dailyFoodLogHistoryBloc;
  final StatsBloc statsBloc = dependencies.statsBloc;

  return <String, WidgetBuilder>{
    AppRoute.landing.path: (BuildContext _) {
      return BlocProvider<SettingsBloc>.value(
        value: settingsBloc,
        child: const LandingPage(),
      );
    },
    AppRoute.home.path: (BuildContext _) {
      homeBloc.add(const LoadEntries());
      return MultiBlocProvider(
        providers: <SingleChildWidget>[
          BlocProvider<HomeBloc>.value(
            value: homeBloc,
          ),
          BlocProvider<YesterdayEntriesBloc>.value(
            value: yesterdayEntriesBloc,
          ),
          BlocProvider<MenuBloc>.value(
            value: menuBloc,
          ),
          BlocProvider<SettingsBloc>.value(
            value: settingsBloc,
          ),
        ],
        child: const HomePage(),
      );
    },
    AppRoute.onboarding.path: (BuildContext _) {
      return BlocProvider<OnboardingBloc>.value(
        value: onboardingBloc,
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
      // Reset the bloc state by adding a load event
      dailyFoodLogHistoryBloc.add(LoadDailyFoodLogHistoryEvent());
      return BlocProvider<DailyFoodLogHistoryBloc>.value(
        value: dailyFoodLogHistoryBloc,
        child: const DailyFoodLogHistoryPage(),
      );
    },
    AppRoute.stats.path: (BuildContext _) {
      // Reset the bloc state by adding a load event
      statsBloc.add(const LoadStatsEvent());
      return BlocProvider<StatsBloc>.value(
        value: statsBloc,
        child: const StatsPage(),
      );
    },
  };
}
