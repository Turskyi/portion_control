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
                      value.getMealName(
                        index: index,
                        totalEntries: day.entries.length,
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
}
