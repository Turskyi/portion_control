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
        final bool isWeightAboveHealthy = state.isWeightAboveHealthy;
        final bool isWeightBelowHealthy = state.isWeightBelowHealthy;
        final bool isWeightDecreasing = state.isWeightDecreasing;
        final bool isWeightIncreasing = state.isWeightIncreasing;
        if (state.hasNoPortionControl) {
          return Text(
            '🍽️ No portion control today!\n'
            '📝 Log everything you eat to track how it affects your weight.',
            style: titleMediumStyle,
          );
        } else if (state.isWeightIncreasingOrSame && isWeightAboveHealthy) {
          if (state.isMealsConfirmedForToday) {
            return Text(
              '⚖️ Portion Control for today: ${state.portionControl} g 🍽️',
              style: titleMediumStyle,
            );
          } else {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Did you log every meal you ate yesterday? 📋',
                      style: titleMediumStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () => context
                              .read<HomeBloc>()
                              .add(const ConfirmMealsLogged()),
                          child: const Text('Yes ✅'),
                        ),
                        OutlinedButton(
                          onPressed: () => _showIncompleteDataDialog(context),
                          child: const Text('No ❌'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        } else if (isWeightDecreasing && isWeightAboveHealthy) {
          return Text(
            '📉 Your weight is decreasing! 🎉\nYou can enjoy your meals '
            'without strict Portion Control, but keep logging your food to '
            'track your progress. 🍽️',
            style: titleMediumStyle,
          );
        } else if (isWeightIncreasing && isWeightBelowHealthy) {
          return Text(
            '📈 Your weight is increasing, which is good! 💪 '
            'Ensure you eat nutritious meals to reach a healthy weight. 🥗🍞',
            style: titleMediumStyle,
          );
        } else if (isWeightDecreasing && isWeightBelowHealthy) {
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

  Future<void> _showIncompleteDataDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incomplete Data Warning'),
          content: const Text(
            '⚠️ To provide accurate portion control, we rely on complete meal '
            'tracking. Since some entries might be missing, we will reset food '
            'logs for yesterday. This ensures future recommendations are based '
            'on reliable data. 🔄',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<HomeBloc>().add(const ResetFoodEntries());
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
