import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:portion_control/domain/models/day_food_log.dart';

class WeeklyIntakeChart extends StatelessWidget {
  const WeeklyIntakeChart({required this.lastSevenDaysIntake, super.key});

  final List<DayFoodLog> lastSevenDaysIntake;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // The data is sorted descending, reverse it for the chart.
    final List<DayFoodLog> chartData = lastSevenDaysIntake.reversed.toList();

    final List<FlSpot> spots = chartData.asMap().entries.map((
      MapEntry<int, DayFoodLog> entry,
    ) {
      return FlSpot(entry.key.toDouble(), entry.value.totalConsumed);
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 28, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              translate('stats.weekly_intake_trend'),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 500,
                    getDrawingHorizontalLine: (double _) {
                      return FlLine(
                        color: colorScheme.onSurface.withAlpha(50),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int index = value.toInt();
                          if (index < 0 || index >= chartData.length) {
                            return const SizedBox.shrink();
                          }
                          final DateTime date = chartData[index].date;
                          return SideTitleWidget(
                            meta: meta,
                            space: 8.0,
                            child: Text(
                              DateFormat.MMMd(
                                Localizations.localeOf(context).languageCode,
                              ).format(date),
                              style: textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48, // Increased for wider labels
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value == meta.max || value == meta.min) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            space: 8.0,
                            child: Text(
                              '${value.toInt()}',
                              style: textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => colorScheme.secondaryContainer,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final int spotIndex = touchedSpot.spotIndex;
                          final DayFoodLog dayLog = chartData[spotIndex];

                          return LineTooltipItem(
                            '${dayLog.totalConsumed.toStringAsFixed(0)} '
                            '${translate("unit.gram")}\n',
                            TextStyle(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: DateFormat.yMd(
                                  Localizations.localeOf(context).languageCode,
                                ).format(dayLog.date),
                                style: TextStyle(
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: <Color>[
                            colorScheme.primary.withAlpha(77), // 0.3 opacity
                            colorScheme.primary.withAlpha(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
