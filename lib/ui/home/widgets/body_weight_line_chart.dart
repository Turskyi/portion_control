import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portion_control/domain/models/body_weight.dart';

class BodyWeightLineChart extends StatelessWidget {
  const BodyWeightLineChart({
    required this.bodyWeightEntries,
    super.key,
  });

  final List<BodyWeight> bodyWeightEntries;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final Color onTertiaryColor = colorScheme.onTertiary;
    return SizedBox(
      height: 60,
      child: LineChart(
        LineChartData(
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: bodyWeightEntries.asMap().entries.map(
                (MapEntry<int, BodyWeight> entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value.weight,
                  );
                },
              ).toList(),
              // Use theme color.
              color: colorScheme.primary,
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
              dotData: const FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 48,
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      style: TextStyle(
                        color: themeData.textTheme.labelLarge?.color,
                      ),
                      value.toStringAsFixed(
                        value.truncateToDouble() == value ? 0 : 1,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (_) {
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
            border: Border.all(
              color: onTertiaryColor,
              width: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
