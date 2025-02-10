import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/home/widgets/food_weight_entry_row.dart';

class FoodEntriesColumn extends StatelessWidget {
  const FoodEntriesColumn({required this.foodEntries, super.key});

  final List<FoodWeight> foodEntries;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final ThemeData themeData = Theme.of(context);
        final TextTheme textTheme = themeData.textTheme;
        return Column(
          spacing: 16,
          children: <Widget>[
            // Existing food entries.
            ...foodEntries.map((FoodWeight entry) {
              return FoodWeightEntryRow(
                value: '${entry.weight}',
                time: entry.time,
                isEditable: state is FoodWeightUpdateState &&
                    state.foodEntryId == entry.id,
                onEdit: () {
                  context.read<HomeBloc>().add(EditFoodEntry(entry.id));
                },
                onDelete: () {
                  context.read<HomeBloc>().add(DeleteFoodEntry(entry.id));
                },
                onSave: (String value) {
                  context.read<HomeBloc>().add(
                        UpdateFoodWeight(
                          foodEntryId: entry.id,
                          foodWeight: value,
                        ),
                      );
                },
              );
            }),
            if (state.totalConsumedToday < constants.maxDailyFoodLimit)
              if (state.shouldAskForMealConfirmation)
                const SizedBox()
              else
                FoodWeightEntryRow(
                  isEditable: true,
                  onSave: (String value) {
                    context.read<HomeBloc>().add(AddFoodEntry(value));
                  },
                )
            else
              const Text(
                'It seems like you’ve set a big challenge for '
                'yourself today. We’re not sure what your plans are, '
                'but we definitely suggest not overdoing it with '
                'that amount of food. 😅',
              ),
            if (state.shouldAskForMealConfirmation)
              const SizedBox()
            else
              Text(
                'Total consumed today: ${state.totalConsumedToday} g',
                style: textTheme.titleMedium,
              ),
            if (state.totalConsumedToday < state.portionControl)
              Text(
                'You can eat '
                '${state.portionControl - state.totalConsumedToday} g more '
                'today',
                style: textTheme.bodyMedium,
              ),
          ],
        );
      },
    );
  }
}
