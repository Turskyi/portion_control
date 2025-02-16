import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nested/nested.dart';
import 'package:portion_control/app.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/yesterday_entries_bloc/yesterday_entries_bloc.dart';
import 'package:portion_control/application_services/interactors/clear_tracking_data_use_case.dart';
import 'package:portion_control/infrastructure/database/database.dart';
import 'package:portion_control/infrastructure/repositories/body_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/food_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/tracking_repository.dart';
import 'package:portion_control/infrastructure/repositories/user_preferences_repository.dart';
import 'package:portion_control/localization/localization_delelegate_getter.dart'
    as localization;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/feedback/feedback_form.dart';
import 'package:portion_control/ui/home/home_page.dart';
import 'package:portion_control/ui/home/widgets/yesterday_food_entries_dialog.dart';
import 'package:portion_control/ui/widgets/fancy_loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/models/food_weight.dart';

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

  final LocalizationDelegate localizationDelegate =
      await localization.getLocalizationDelegate();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AppDatabase appDatabase = AppDatabase();

  Future<void> showYesterdayEntriesDialog({
    required BuildContext context,
    required List<FoodWeight> foodEntries,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => YesterdayFoodEntriesDialog(foodEntries: foodEntries),
    );
  }

  final Map<String, WidgetBuilder> routeMap = <String, WidgetBuilder>{
    AppRoute.home.path: (_) => MultiBlocProvider(
          providers: <SingleChildWidget>[
            BlocProvider<HomeBloc>(
              create: (_) => HomeBloc(
                UserPreferencesRepository(prefs),
                BodyWeightRepository(appDatabase),
                FoodWeightRepository(appDatabase),
                ClearTrackingDataUseCase(TrackingRepository(appDatabase)),
              )..add(const LoadEntries()),
            ),
            BlocProvider<YesterdayEntriesBloc>(
              create: (_) => YesterdayEntriesBloc(
                FoodWeightRepository(appDatabase),
              ),
            ),
          ],
          child: BlocListener<YesterdayEntriesBloc, YesterdayEntriesState>(
            listener: (BuildContext context, YesterdayEntriesState state) {
              if (state is YesterdayEntriesLoading) {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const FancyLoadingIndicator(),
                );
              } else if (state is YesterdayEntriesLoaded) {
                // Close the loading dialog
                Navigator.of(context).pop();
                showYesterdayEntriesDialog(
                  context: context,
                  foodEntries: state.foodEntries,
                );
              } else if (state is YesterdayEntriesError) {
                // Close the loading dialog
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: const HomePage(),
          ),
        ),
  };

  runApp(
    LocalizedApp(
      localizationDelegate,
      BetterFeedback(
        feedbackBuilder: (
          _,
          OnSubmit onSubmit,
          ScrollController? scrollController,
        ) =>
            FeedbackForm(
          onSubmit: onSubmit,
          scrollController: scrollController,
        ),
        child: App(routeMap: routeMap),
      ),
    ),
  );
}
