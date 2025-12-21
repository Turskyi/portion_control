import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/domain/models/day_food_log.dart';
import 'package:portion_control/domain/models/food_weight.dart';

class DayLogCard extends StatelessWidget {
  const DayLogCard({required this.day, super.key});

  final DayFoodLog day;

  @override
  Widget build(BuildContext context) {
    final bool isOverLimit = day.totalConsumed > day.dailyLimit;
    final bool hasEntries = day.entries.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // The `withOpacity` method is being deprecated.
        // It's better to use `withAlpha` if your Flutter version supports it
        // well, or stick to this if you need to support older versions.
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                day.formattedDate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (hasEntries)
                Text(
                  translate(
                    isOverLimit
                        ? 'daily_food_log_history.over_limit'
                        : 'daily_food_log_history.within_limit',
                  ),
                  style: TextStyle(
                    color: isOverLimit ? Colors.red : Colors.green,
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
            Text(
              translate(
                'daily_food_log_history.daily_limit',
                args: <String, Object?>{'value': day.dailyLimit},
              ),
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
              style: TextStyle(color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }

  static final List<String> _mealOrder = <String>[
    'breakfast',
    'second_breakfast',
    'lunch',
    'snack',
    'dinner',
  ];

  String _getMealName({
    required int index,
    required List<FoodWeight> entries,
  }) {
    String t(String key) => translate('meal_type.$key');

    if (entries.length == 5) {
      // Clamp index to available meal slots.
      final int safeIndex = index.clamp(0, _mealOrder.length - 1);
      return t(_mealOrder[safeIndex]);
    } else if (entries.length == 4) {
      if (index == 0) {
        return t('breakfast');
      } else if (index == 1) {
        return t('second_breakfast');
      } else if (index == 2) {
        return t('lunch');
      } else {
        return t('dinner');
      }
    } else if (entries.length == 3) {
      if (index == 0) {
        return t('breakfast');
      } else if (index == 1) {
        return t('lunch');
      } else {
        return t('dinner');
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
        if (position == 0) return t('breakfast');
        if (position == 1) return t('lunch');
        return t('dinner');
      } else if (index == fourthLargestIndex) {
        return t('second_breakfast');
      } else {
        return t('snack');
      }
    } else {
      // Fallback based on time of day.
      String getType(int hour) {
        if (hour < 12) {
          return 'breakfast';
        } else if (hour < 17) {
          return 'lunch';
        } else {
          return 'dinner';
        }
      }

      final String currentType = getType(entries[index].dateTime.hour);

      if (entries.length == 2) {
        final int otherIndex = index == 0 ? 1 : 0;
        final String otherType = getType(entries[otherIndex].dateTime.hour);

        if (currentType == otherType) {
          if (currentType == 'breakfast') {
            return index == 0 ? t('breakfast') : t('lunch');
          } else {
            return index == 0 ? t(currentType) : t('dinner');
          }
        }
      }
      return t(currentType);
    }
  }
}
