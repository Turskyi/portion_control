import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
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
        // Prepare translated suffixes once.
        final String gramsSuffix = translate('food_entry.grams_suffix');
        final String moreTodaySuffix = translate(
          'food_entry.more_today_suffix',
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            // Existing food entries.
            ...foodEntries.map((FoodWeight entry) {
              return FoodWeightEntryRow(
                value: '${entry.weight}',
                time: entry.time,
                isEditState:
                    state is FoodWeightUpdateState &&
                    state.foodEntryId == entry.id,
                onEdit: () {
                  context.read<HomeBloc>().add(EditFoodEntry(entry.id));
                },
                onDelete: () {
                  context.read<HomeBloc>().add(DeleteFoodEntry(entry.id));
                },
                onSave: (String value) {
                  context.read<HomeBloc>().add(
                    UpdateFoodWeight(foodEntryId: entry.id, foodWeight: value),
                  );
                },
              );
            }),
            if ((totalConsumedToday < constants.kMaxDailyFoodLimit &&
                    (!shouldAskForMealConfirmation ||
                        state.hasNoPortionControl) &&
                    totalConsumedToday < portionControl) ||
                (isWeightBelowHealthy && isWeightDecreasingOrSame))
              // Input field for new food entry.
              FoodWeightEntryRow(
                isEditState: true,
                onSave: (String value) async {
                  await _handleFoodEntrySubmission(
                    context: context,
                    hasFoodEntriesYesterday: state.hasFoodEntriesYesterday,
                    value: value,
                    totalConsumedToday: totalConsumedToday,
                    portionControl: portionControl,
                  );
                },
              )
            else if (totalConsumedToday >= constants.kMaxDailyFoodLimit)
              Text(translate('food_entry.challenge_warning')),

            if (!shouldAskForMealConfirmation ||
                state.hasNoPortionControl) ...<Widget>[
              Text(
                '${translate('food_entry.total_consumed_today_prefix')}'
                '${state.formattedTotalConsumedToday}$gramsSuffix',
                style: textTheme.titleMedium,
              ),
              if (state.hasNoFoodEntriesYesterday)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () => _navigateToDailyFoodLogHistory(context),
                  child: Text(
                    translate(
                      'food_entry.you_did_not_put_any_food_entries_yesterday',
                    ),
                    style: textTheme.titleMedium,
                  ),
                )
              else
                Text(
                  '${translate('food_entry.total_consumed_yesterday_prefix')}'
                  '${state.formattedTotalConsumedYesterday}$gramsSuffix',
                  style: textTheme.titleMedium,
                ),
              if (state.hasNoFoodEntriesYesterday)
                const SizedBox.shrink()
              else if (isWeightBelowHealthy &&
                  isWeightDecreasingOrSame &&
                  totalConsumedToday < portionControl &&
                  portionControl != constants.kMaxDailyFoodLimit &&
                  portionControl != constants.kSafeMinimumFoodIntakeG)
                Text(
                  '${translate('food_entry.must_eat_at_least_prefix')}'
                  '${state.formattedRemainingFood}$gramsSuffix'
                  '$moreTodaySuffix',
                  style: textTheme.bodyMedium,
                )
              else if (totalConsumedToday < portionControl &&
                  portionControl != constants.kMaxDailyFoodLimit)
                Text(
                  '${translate('food_entry.can_eat_prefix')}'
                  '${state.formattedRemainingFood}'
                  '$gramsSuffix$moreTodaySuffix',
                  style: textTheme.bodyMedium,
                ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _handleFoodEntrySubmission({
    required BuildContext context,
    required bool hasFoodEntriesYesterday,
    required String value,
    required double totalConsumedToday,
    required double portionControl,
  }) async {
    HapticFeedback.lightImpact();
    if (hasFoodEntriesYesterday) {
      final String normalized = value.replaceAll(',', '.');
      final double? parsedValue = double.tryParse(normalized);
      if (parsedValue != null) {
        final double newTotal = totalConsumedToday + parsedValue;
        if (portionControl < newTotal) {
          final String formattedPortion = portionControl
              .toStringAsFixed(1)
              .replaceAll(RegExp(r'\.0$'), '');
          final bool confirmed =
              await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text(translate('food_entry.are_you_sure_title')),
                    content: Text(
                      translate(
                        'food_entry.weight_increase_warning',
                        args: <String, String>{'portion': formattedPortion},
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(
                          dialogContext,
                        ).pop(false),
                        child: Text(translate('no')),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        child: Text(translate('yes')),
                      ),
                    ],
                  );
                },
              ) ??
              false;

          if (confirmed && context.mounted) {
            context.read<HomeBloc>().add(AddFoodEntry(value));
          }
        } else {
          context.read<HomeBloc>().add(AddFoodEntry(value));
        }
      }
    } else {
      context.read<HomeBloc>().add(AddFoodEntry(value));
    }
  }

  void _navigateToDailyFoodLogHistory(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoute.dailyFoodLogHistory.path,
    );
  }
}
