import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/domain/enums/meal_type.dart';
import 'package:portion_control/domain/models/day_food_log.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/widgets/safety_limits_dialog.dart';

class DayLogCard extends StatelessWidget {
  const DayLogCard({required this.day, super.key});

  final DayFoodLog day;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isOverLimit = day.totalConsumed > day.dailyLimit;
    final bool hasEntries = day.entries.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    day.formattedDate,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (day.isWeightIncreasing == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.trending_up,
                        color: colorScheme.error,
                        size: 18,
                      ),
                    )
                  else if (day.isWeightDecreasing == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.trending_down,
                        color: colorScheme.tertiary,
                        size: 18,
                      ),
                    ),
                ],
              ),
              if (hasEntries)
                Text(
                  translate(
                    isOverLimit
                        ? 'daily_food_log_history.over_limit'
                        : 'daily_food_log_history.within_limit',
                  ),
                  style: TextStyle(
                    color: isOverLimit
                        ? colorScheme.error
                        : colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Summary
          if (hasEntries) ...<Widget>[
            Text(
              translate(
                'daily_food_log_history.total_consumed',
                args: <String, Object?>{'value': day.totalConsumed},
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  translate(
                    'daily_food_log_history.daily_limit',
                    args: <String, Object?>{'value': day.dailyLimit},
                  ),
                ),
                if (day.dailyLimit == constants.kMaxDailyFoodLimit ||
                    day.dailyLimit == constants.kSafeMinimumFoodIntakeG ||
                    day.dailyLimit == constants.kAbsoluteMinimumFoodIntakeG)
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) =>
                            const SafetyLimitsDialog(),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Entries
            ...day.entries.asMap().entries.map(
              (MapEntry<int, FoodWeight> entry) {
                final int index = entry.key;
                final FoodWeight value = entry.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _getMealName(
                        index: index,
                        entries: day.entries,
                      ),
                    ),
                    Text(
                      translate(
                        'measurement.grams_value',
                        args: <String, Object?>{'value': value.weight},
                      ),
                    ),
                  ],
                );
              },
            ),
          ] else
            Text(
              translate('daily_food_log_history.no_meals_logged'),
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  static final List<MealType> _mealOrder = <MealType>[
    MealType.breakfast,
    MealType.secondBreakfast,
    MealType.lunch,
    MealType.snack,
    MealType.dinner,
  ];

  String _getMealName({
    required int index,
    required List<FoodWeight> entries,
  }) {
    String t(MealType type) => translate('meal_type.${type.translationKey}');

    if (entries.length == 5) {
      // Clamp index to available meal slots.
      final int safeIndex = index.clamp(0, _mealOrder.length - 1);
      return t(_mealOrder[safeIndex]);
    } else if (entries.length == 4) {
      // Sort indices by weight (descending).
      final List<int> sortedIndices =
          List<int>.generate(entries.length, (int i) => i)..sort(
            (int a, int b) => entries[b].weight.compareTo(entries[a].weight),
          );

      // Three largest meals become Breakfast, Lunch, Dinner (chronological).
      final List<int> mainMealIndices = sortedIndices.take(3).toList()..sort();

      if (mainMealIndices.contains(index)) {
        final int position = mainMealIndices.indexOf(index);
        if (position == 0) return t(MealType.breakfast);
        if (position == 1) return t(MealType.lunch);
        return t(MealType.dinner);
      }

      // The remaining meal is Snack or Second Breakfast based on time.
      final int hour = entries[index].dateTime.hour;
      return hour < 12 ? t(MealType.secondBreakfast) : t(MealType.snack);
    } else if (entries.length == 3) {
      if (index == 0) {
        return t(MealType.breakfast);
      } else if (index == 1) {
        return t(MealType.lunch);
      } else {
        return t(MealType.dinner);
      }
    } else if (entries.length > 5) {
      // Get indices sorted by weight (descending).
      final List<int> sortedIndices =
          List<int>.generate(
            entries.length,
            (int i) => i,
          )..sort(
            (int a, int b) => entries[b].weight.compareTo(entries[a].weight),
          );

      // Top 3 largest meals (by weight) become Breakfast, Lunch, Dinner.
      // We sort their indices to assign them chronologically.
      final List<int> topThreeIndices = sortedIndices.take(3).toList()..sort();
      final int fourthLargestIndex = sortedIndices[3];

      if (topThreeIndices.contains(index)) {
        final int position = topThreeIndices.indexOf(index);
        if (position == 0) return t(MealType.breakfast);
        if (position == 1) return t(MealType.lunch);
        return t(MealType.dinner);
      } else if (index == fourthLargestIndex) {
        return t(MealType.secondBreakfast);
      } else {
        return t(MealType.snack);
      }
    } else {
      // Fallback based on time of day.
      MealType getType(int hour) {
        if (hour < 12) {
          return MealType.breakfast;
        } else if (hour < 17) {
          return MealType.lunch;
        } else {
          return MealType.dinner;
        }
      }

      final MealType currentType = getType(entries[index].dateTime.hour);

      if (entries.length == 2) {
        final int otherIndex = index == 0 ? 1 : 0;
        final MealType otherType = getType(entries[otherIndex].dateTime.hour);

        if (currentType == otherType) {
          if (currentType == MealType.breakfast) {
            return index == 0 ? t(MealType.breakfast) : t(MealType.lunch);
          } else if (currentType == MealType.dinner) {
            if (entries[index].weight > entries[otherIndex].weight) {
              return t(MealType.dinner);
            }
            if (entries[otherIndex].weight > entries[index].weight) {
              return t(MealType.snack);
            }
            return index == 0 ? t(MealType.dinner) : t(MealType.snack);
          } else {
            return index == 0 ? t(currentType) : t(MealType.dinner);
          }
        }
      }
      return t(currentType);
    }
  }
}
