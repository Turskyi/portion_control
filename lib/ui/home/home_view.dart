import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocListener, BlocProvider, MultiBlocProvider;
import 'package:nested/nested.dart' show SingleChildWidget;
import 'package:portion_control/application_services/blocs/home/home_bloc.dart'
    show HomeBloc, LoadEntries;
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
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
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
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

class HomeView extends StatelessWidget {
  const HomeView({
    required this.localDataSource,
    super.key,
  });

  final LocalDataSource localDataSource;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<HomeBloc>(
          create: (BuildContext _) {
            return HomeBloc(
              UserPreferencesRepository(localDataSource),
              BodyWeightRepository(localDataSource),
              FoodWeightRepository(localDataSource),
              ClearTrackingDataUseCase(TrackingRepository(localDataSource)),
            )..add(const LoadEntries());
          },
        ),
        BlocProvider<YesterdayEntriesBloc>(
          create: (BuildContext _) {
            return YesterdayEntriesBloc(
              FoodWeightRepository(localDataSource),
            );
          },
        ),
        BlocProvider<MenuBloc>(
          create: (BuildContext _) {
            return MenuBloc(SettingsRepository(localDataSource))
              ..add(const LoadingInitialMenuStateEvent());
          },
        ),
      ],
      child: BlocListener<YesterdayEntriesBloc, YesterdayEntriesState>(
        listener: _yesterdayEntriesStateListener,
        child: HomePage(localDataSource: localDataSource),
      ),
    );
  }

  void _yesterdayEntriesStateListener(
    BuildContext context,
    YesterdayEntriesState state,
  ) {
    if (state is YesterdayEntriesLoading) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => const FancyLoadingIndicator(),
      );
    } else if (state is YesterdayEntriesLoaded) {
      // Close the loading dialog.
      Navigator.of(context).pop();
      _showYesterdayEntriesDialog(
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
  }

  Future<void> _showYesterdayEntriesDialog({
    required BuildContext context,
    required List<FoodWeight> foodEntries,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) {
        return YesterdayFoodEntriesDialog(foodEntries: foodEntries);
      },
    );
  }
}
