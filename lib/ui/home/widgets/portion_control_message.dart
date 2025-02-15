import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/home/widgets/meal_confirmation_card.dart';

class PortionControlMessage extends StatelessWidget {
  const PortionControlMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? titleMediumStyle = textTheme.titleMedium;
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final bool isWeightAboveHealthy = state.isWeightAboveHealthy;
        final bool isWeightBelowHealthy = state.isWeightBelowHealthy;
        final bool isWeightDecreasing = state.isWeightDecreasing;
        final bool isWeightIncreasing = state.isWeightIncreasing;
        final double portionControl = state.adjustedPortion;
        final double yesterdayTotal = state.yesterdayConsumedTotal;
        if (state.hasNoPortionControl) {
          return Text(
            '🍽️ No portion control today!\n'
            '📝 Log everything you eat to track how it affects your weight.',
            style: titleMediumStyle,
          );
        } else if (state.isWeightIncreasingOrSame && isWeightAboveHealthy) {
          if (state.isMealsConfirmedForToday &&
              portionControl > constants.safeMinimumFoodIntakeG) {
            if (portionControl != constants.maxDailyFoodLimit) {
              return Text(
                '⚖️ Portion Control for today: '
                '${state.formattedPortionControl} g 🍽️',
                style: titleMediumStyle,
              );
            }
          } else if (!state.isMealsConfirmedForToday) {
            return MealConfirmationCard(yesterdayTotal: yesterdayTotal);
          }
        } else if (isWeightDecreasing && isWeightAboveHealthy) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: <Widget>[
              Text(
                '📉 Your weight is decreasing! 🎉\n'
                'Enjoy your meals without strict Portion Control, but keep '
                'logging to track your progress. 🍽️',
                style: titleMediumStyle,
              ),
              if (yesterdayTotal > constants.safeMinimumFoodIntakeG &&
                  yesterdayTotal < constants.maxDailyFoodLimit)
                Text(
                  '📊 Yesterday: $yesterdayTotal g'
                  '${state.previousPortionControlInfo}\n'
                  'Use this as a reference today!',
                  // Slightly smaller than titleMediumStyle.
                  style: textTheme.bodyMedium,
                ),
            ],
          );
        } else if (isWeightIncreasing && isWeightBelowHealthy) {
          return Text(
            '📈 Your weight is increasing, which is good! 💪 '
            'Ensure you eat nutritious meals to reach a healthy weight. 🥗🍞',
            style: titleMediumStyle,
          );
        } else if (state.isWeightDecreasingOrSame && isWeightBelowHealthy) {
          if (state.isMealsConfirmedForToday &&
              portionControl > constants.safeMinimumFoodIntakeG) {
            if (portionControl != constants.maxDailyFoodLimit &&
                portionControl != constants.safeMinimumFoodIntakeG) {
              return Text(
                '⚠️ Warning: Your weight is dropping below the healthy range! '
                '❗\nConsider increasing your food intake. 🍔🍚\n🍽️ Minimum '
                'intake for today: '
                '${state.formattedPortionControl} g ⚖️',
                style: titleMediumStyle,
              );
            }
          } else if (!state.isMealsConfirmedForToday) {
            return MealConfirmationCard(yesterdayTotal: yesterdayTotal);
          } else {
            return Text(
              '⚠️ Warning: Your weight is dropping below the healthy range! ❗ '
              'Consider increasing your food intake. 🍔🍚',
              style: titleMediumStyle,
            );
          }
        }
// Default empty widget if no condition matches.
        return const SizedBox.shrink();
      },
    );
  }
}
