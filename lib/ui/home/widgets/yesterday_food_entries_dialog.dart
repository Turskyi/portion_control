import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/ui/home/widgets/food_weight_entry_row.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class YesterdayFoodEntriesDialog extends StatelessWidget {
  const YesterdayFoodEntriesDialog({required this.foodEntries, super.key});

  final List<FoodWeight> foodEntries;

  @override
  Widget build(BuildContext context) {
    // Calculate the total weight consumed yesterday.
    final String totalWeight = foodEntries
        .fold(0.0, (double sum, FoodWeight entry) => sum + entry.weight)
        .toStringAsFixed(1)
        .replaceAll(RegExp(r'\.0$'), '');

    final double horizontalIndent = 12.0;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Dialog.fullscreen(
      child: GradientBackgroundScaffold(
        appBar: BlurredAppBar(title: translate('yesterday_entries.title')),
        body: ListView.separated(
          separatorBuilder: (BuildContext _, int _) {
            return const SizedBox(height: 16);
          },
          padding: EdgeInsets.fromLTRB(
            horizontalIndent,
            MediaQuery.of(context).padding.top + kToolbarHeight + 18,
            horizontalIndent,
            80.0,
          ),
          itemCount: foodEntries.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index < foodEntries.length) {
              final FoodWeight entry = foodEntries[index];
              return FoodWeightEntryRow(
                value: '${entry.weight}',
                time: entry.time,
              );
            } else {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: colorScheme.background.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '${translate('yesterday_entries.total_consumed_prefix')} '
                  '$totalWeight${translate('yesterday_entries.grams_suffix')}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              );
            }
          },
        ),
        persistentFooterAlignment: AlignmentDirectional.center,
        persistentFooterButtons: <Widget>[
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(translate('button.close')),
          ),
        ],
      ),
    );
  }
}
