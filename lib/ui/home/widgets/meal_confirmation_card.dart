import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/yesterday_entries_bloc/yesterday_entries_bloc.dart';

class MealConfirmationCard extends StatelessWidget {
  const MealConfirmationCard({required this.yesterdayTotal, super.key});

  final double yesterdayTotal;

  String get formattedYesterdayConsumedTotal =>
      yesterdayTotal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
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
                    translate('meal_confirmation.yesterday_consumed_prefix'),
                    style: titleMediumStyle,
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => _loadYesterdayEntries(context),
                    child: Text(
                      '$formattedYesterdayConsumedTotal'
                      '${translate('meal_confirmation.grams_suffix')}',
                      style: titleMediumStyle?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () => _loadYesterdayEntries(context),
                    tooltip: translate(
                      'meal_confirmation.view_yesterday_tooltip',
                    ),
                  ),
                ],
              )
            else
              Text(
                translate('meal_confirmation.no_meals_logged_yesterday'),
                style: titleMediumStyle,
                textAlign: TextAlign.center,
              ),

            Text(
              translate('meal_confirmation.did_you_log_all_meals_yesterday'),
              style: titleMediumStyle,
              textAlign: TextAlign.center,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(const ConfirmMealsLogged());
                  },
                  child: Text('${translate('yes')} ✅'),
                ),
                OutlinedButton(
                  onPressed: () => _showIncompleteDataDialog(context),
                  child: Text('${translate('no')} ❌'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _loadYesterdayEntries(BuildContext context) {
    context.read<YesterdayEntriesBloc>().add(const LoadYesterdayEntries());
  }

  Future<void> _showIncompleteDataDialog(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            translate('meal_confirmation.incomplete_data_warning_title'),
          ),
          content: Text(
            translate('meal_confirmation.incomplete_data_warning_content'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                parentContext.read<HomeBloc>().add(const ResetFoodEntries());
              },
              child: Text(translate('button.ok')),
            ),
          ],
        );
      },
    );
  }
}
