import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/daily_food_log_history/daily_food_log_history_bloc.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class DailyFoodLogHistoryPage extends StatelessWidget {
  const DailyFoodLogHistoryPage({super.key});

  @override
  Widget build(BuildContext _) {
    return GradientBackgroundScaffold(
      appBar: BlurredAppBar(
        title: translate('daily_food_log_history.title'),
      ),
      body: BlocBuilder<DailyFoodLogHistoryBloc, DailyFoodLogHistoryState>(
        builder: (BuildContext _, DailyFoodLogHistoryState state) {
          if (state is DailyFoodLogHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DailyFoodLogHistoryLoaded) {
            return ListView.builder(
              itemCount: state.foodLogs.length,
              itemBuilder: (BuildContext _, int index) {
                final FoodWeight foodLog = state.foodLogs[index];
                return ListTile(
                  title: Text(foodLog.date.toString()),
                  subtitle: Text(foodLog.weight.toString()),
                );
              },
            );
          } else if (state is DailyFoodLogHistoryError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text(translate('coming_soon')));
          }
        },
      ),
    );
  }
}
