import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portion_control/domain/models/body_weight.dart';

class BodyWeightLineChart extends StatelessWidget {
  const BodyWeightLineChart({required this.bodyWeightEntries, super.key});

  final List<BodyWeight> bodyWeightEntries;

  @override
  Widget build(BuildContext context) {
    if (bodyWeightEntries.isEmpty) {
      return const SizedBox(height: 60);
    }

    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final Color onTertiaryColor = colorScheme.onTertiary;

    final List<FlSpot> bodyWeightSpots = bodyWeightEntries.asMap().entries.map((
      MapEntry<int, BodyWeight> entry,
    ) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    return SizedBox(
      height: 60,
      child: Row(
        children: <Widget>[
          // The chart takes up most of the space.
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: <LineChartBarData>[
                  LineChartBarData(
                    spots: bodyWeightSpots,
                    color: colorScheme.primary,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: false),
                    dotData: const FlDotData(show: true),
                  ),
                ],

                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (double _) {
                    return FlLine(
                      color: onTertiaryColor,
                      strokeWidth: 1,
                      // Dashed line pattern.
                      dashArray: <int>[5, 5],
                    );
                  },
                  getDrawingVerticalLine: (double value) {
                    return FlLine(
                      color: onTertiaryColor,
                      strokeWidth: 1,
                      // Dashed line pattern.
                      dashArray: <int>[10, 5],
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: onTertiaryColor, width: 0.4),
                ),
              ),
            ),
          ),
          // A fixed-width container for labels.
          Container(
            width: 48,
            padding: const EdgeInsets.only(left: 8.0),
            child: ChartLabels(bodyWeightEntries: bodyWeightEntries),
          ),
        ],
      ),
    );
  }
}

class ChartLabels extends StatelessWidget {
  const ChartLabels({
    required this.bodyWeightEntries,
    super.key,
  });

  final List<BodyWeight> bodyWeightEntries;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle? labelStyle = themeData.textTheme.labelLarge;

    // Take the last 3 entries, or fewer if not available.
    final List<BodyWeight> lastThreeEntries = bodyWeightEntries.length > 3
        ? bodyWeightEntries.sublist(bodyWeightEntries.length - 3)
        : bodyWeightEntries;

    // Sort the entries by weight to ensure they are displayed numerically.
    final List<BodyWeight> sortedEntries = lastThreeEntries.sortedBy<num>(
      (BodyWeight entry) => entry.weight,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedEntries.reversed.map((BodyWeight entry) {
        return Text(
          entry.weight.toStringAsFixed(1),
          style: labelStyle,
        );
      }).toList(),
    );
  }
}
