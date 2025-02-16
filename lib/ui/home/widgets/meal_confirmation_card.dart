import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/yesterday_entries_bloc/yesterday_entries_bloc.dart';

class MealConfirmationCard extends StatelessWidget {
  const MealConfirmationCard({
    required this.yesterdayTotal,
    super.key,
  });

  final double yesterdayTotal;

  String get formattedYesterdayConsumedTotal =>
      yesterdayTotal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? titleMediumStyle = textTheme.titleMedium;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 12,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Display yesterday's total consumed amount.
            if (yesterdayTotal > 0)
              Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    ' 🍽️ Yesterday, you consumed (logged) ',
                    style: titleMediumStyle,
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => context
                        .read<YesterdayEntriesBloc>()
                        .add(const LoadYesterdayEntries()),
                    child: Text(
                      '$formattedYesterdayConsumedTotal g',
                      style: titleMediumStyle?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () => context
                        .read<YesterdayEntriesBloc>()
                        .add(const LoadYesterdayEntries()),
                    tooltip: 'View yesterday\'s entries',
                  ),
                ],
              )
            else
              Text(
                'You didn’t log any meals yesterday. Don’t forget to '
                'track your food! ⏳',
                style: titleMediumStyle,
                textAlign: TextAlign.center,
              ),

            Text(
              'Did you log every meal you ate yesterday? 📋',
              style: titleMediumStyle,
              textAlign: TextAlign.center,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () =>
                      context.read<HomeBloc>().add(const ConfirmMealsLogged()),
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
