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

    // Get up to 3 unique weight values, starting from the most recent.
    final Set<String> seen = <String>{};
    final List<double> distinctWeights = <double>[];

    for (final BodyWeight entry in bodyWeightEntries.reversed) {
      final String formatted = entry.weight.toStringAsFixed(1);
      if (seen.add(formatted)) {
        distinctWeights.add(entry.weight);
      }
      if (distinctWeights.length == 3) {
        break;
      }
    }

    // Sort numerically so the highest is at the top.
    distinctWeights.sort();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: distinctWeights.reversed.map((double weight) {
        return Text(
          weight.toStringAsFixed(1),
          style: labelStyle,
        );
      }).toList(),
    );
  }
}
