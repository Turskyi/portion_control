import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocListener, BlocProvider, MultiBlocProvider;
import 'package:nested/nested.dart' show SingleChildWidget;
import 'package:portion_control/application_services/blocs/home/home_bloc.dart'
    show HomeBloc, LoadEntries;
import 'package:portion_control/application_services/blocs/yesterday_entries_bloc/yesterday_entries_bloc.dart'
    show
        YesterdayEntriesBloc,
        YesterdayEntriesError,
        YesterdayEntriesLoaded,
        YesterdayEntriesLoading,
        YesterdayEntriesState;
import 'package:portion_control/application_services/interactors/clear_tracking_data_use_case.dart'
    show ClearTrackingDataUseCase;
import 'package:portion_control/domain/models/food_weight.dart' show FoodWeight;
import 'package:portion_control/infrastructure/database/database.dart'
    show AppDatabase;
import 'package:portion_control/infrastructure/repositories/body_weight_repository.dart'
    show BodyWeightRepository;
import 'package:portion_control/infrastructure/repositories/food_weight_repository.dart'
    show FoodWeightRepository;
import 'package:portion_control/infrastructure/repositories/settings_repository.dart';
import 'package:portion_control/infrastructure/repositories/tracking_repository.dart'
    show TrackingRepository;
import 'package:portion_control/infrastructure/repositories/user_preferences_repository.dart'
    show UserPreferencesRepository;
import 'package:portion_control/ui/home/home_page.dart';
import 'package:portion_control/ui/home/widgets/yesterday_food_entries_dialog.dart'
    show YesterdayFoodEntriesDialog;
import 'package:portion_control/ui/widgets/fancy_loading_indicator.dart'
    show FancyLoadingIndicator;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import '../../application_services/blocs/menu/menu_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    required this.prefs,
    required this.appDatabase,
    super.key,
  });

  final SharedPreferences prefs;
  final AppDatabase appDatabase;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
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
        BlocProvider<MenuBloc>(
          create: (_) => MenuBloc(SettingsRepository(prefs))
            ..add(const LoadingInitialMenuStateEvent()),
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
            // Close the loading dialog.
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
    );
  }

  Future<void> showYesterdayEntriesDialog({
    required BuildContext context,
    required List<FoodWeight> foodEntries,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => YesterdayFoodEntriesDialog(foodEntries: foodEntries),
    );
  }
}
