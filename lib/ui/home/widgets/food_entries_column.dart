import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
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
        final double totalConsumedToday = state.totalConsumedToday;
        final double portionControl = state.adjustedPortion;
        final bool shouldAskForMealConfirmation =
            state.shouldAskForMealConfirmation;
        final bool isWeightBelowHealthy = state.isWeightBelowHealthy;
        final bool isWeightDecreasingOrSame = state.isWeightDecreasingOrSame;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            // Existing food entries.
            ...foodEntries.map((FoodWeight entry) {
              return FoodWeightEntryRow(
                value: '${entry.weight}',
                time: entry.time,
                isEditState: state is FoodWeightUpdateState &&
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
            if ((totalConsumedToday < constants.maxDailyFoodLimit &&
                    (!shouldAskForMealConfirmation ||
                        state.hasNoPortionControl) &&
                    totalConsumedToday < portionControl) ||
                (isWeightBelowHealthy && isWeightDecreasingOrSame))
              // Input field for new food entry.
              FoodWeightEntryRow(
                isEditState: true,
                onSave: (String value) {
                  context.read<HomeBloc>().add(AddFoodEntry(value));
                },
              )
            else if (totalConsumedToday >= constants.maxDailyFoodLimit)
              const Text(
                'It seems like you’ve set a big challenge for '
                'yourself today. We’re not sure what your plans are, '
                'but we definitely suggest not overdoing it with '
                'that amount of food. 😅',
              ),

            if (!shouldAskForMealConfirmation ||
                state.hasNoPortionControl) ...<Widget>[
              Text(
                'Total consumed today: '
                '${state.formattedTotalConsumedToday} g',
                style: textTheme.titleMedium,
              ),
              if (isWeightBelowHealthy &&
                  isWeightDecreasingOrSame &&
                  totalConsumedToday < portionControl &&
                  portionControl != constants.maxDailyFoodLimit &&
                  portionControl != constants.safeMinimumFoodIntakeG)
                Text(
                  '❗You must eat at least ${state.formattedRemainingFood} g '
                  'more today',
                  style: textTheme.bodyMedium,
                )
              else if (totalConsumedToday < portionControl &&
                  portionControl != constants.maxDailyFoodLimit)
                Text(
                  'You can eat ${state.formattedRemainingFood} g more today',
                  style: textTheme.bodyMedium,
                ),
            ],
          ],
        );
      },
    );
  }
}
