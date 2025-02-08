import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';

class PortionControlMessage extends StatelessWidget {
  const PortionControlMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? titleMediumStyle = textTheme.titleMedium;
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        if (state.hasNoPortionControl) {
          return Text(
            '🍽️ No portion control today!\n'
            '📝 Log everything you eat to track how it affects your weight.',
            style: titleMediumStyle,
          );
        } else if (state.isWeightIncreasing && state.isWeightAboveHealthy) {
          return Text(
            '⚖️ Portion Control for today: ${state.portionControl} g 🍽️',
            style: titleMediumStyle,
          );
        } else if (state.isWeightDecreasing && state.isWeightAboveHealthy) {
          return Text(
            '📉 Your weight is decreasing! 🎉 You can eat freely without '
            'strict Portion Control. 🍽️',
            style: titleMediumStyle,
          );
        } else if (state.isWeightIncreasing && state.isWeightBelowHealthy) {
          return Text(
            '📈 Your weight is increasing, which is good! 💪 '
            'Ensure you eat nutritious meals to reach a healthy weight. 🥗🍞',
            style: titleMediumStyle,
          );
        } else if (state.isWeightDecreasing && state.isWeightBelowHealthy) {
          return Text(
            '⚠️ Warning: Your weight is dropping below the healthy range! ❗ '
            'Consider increasing your food intake. 🍔🍚',
            style: titleMediumStyle,
          );
        }
// Default empty widget if no condition matches.
        return const SizedBox.shrink();
      },
    );
  }
}
