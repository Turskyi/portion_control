import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/stats/stats_bloc.dart';
import 'package:portion_control/application_services/blocs/stats/stats_state.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/home/widgets/body_weight_line_chart.dart';
import 'package:portion_control/ui/stats/widgets/stat_card.dart';
import 'package:portion_control/ui/stats/widgets/weekly_intake_chart.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundScaffold(
      appBar: BlurredAppBar(
        title: translate('stats.title'),
      ),
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (BuildContext context, StatsState state) {
          if (state is StatsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StatsError) {
            return Center(child: Text(state.message));
          } else if (state is StatsLoaded) {
            final double screenWidth = MediaQuery.sizeOf(context).width;
            final bool isWide = screenWidth > constants.wideScreenThreshold;
            final double horizontalPadding = isWide
                ? (screenWidth - constants.wideScreenContentWidth) / 2
                : constants.kHorizontalIndent;
            final TextTheme textTheme = Theme.of(context).textTheme;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                MediaQuery.paddingOf(context).top + 24.0,
                horizontalPadding,
                80.0,
              ),
              child: Column(
                children: <Widget>[
                  if (state.lastTwoWeeksBodyWeightEntries.length > 1)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              translate('stats.body_weight_trend'),
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 24),
                            BodyWeightLineChart(
                              bodyWeightEntries:
                                  state.lastTwoWeeksBodyWeightEntries,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (state.lastSevenDaysIntake.length > 1)
                    WeeklyIntakeChart(
                      lastSevenDaysIntake: state.lastSevenDaysIntake,
                    ),
                  if (state.lastSevenDaysIntake.length > 1)
                    const SizedBox(height: 16),
                  StatCard(
                    title: translate('stats.average_daily_intake'),
                    value:
                        '${state.averageDailyIntake.toStringAsFixed(0)} '
                        '${translate('unit.gram')}',
                    icon: Icons.restaurant_menu,
                  ),
                  const SizedBox(height: 16),
                  StatCard(
                    title: translate('stats.weekly_weight_change'),
                    value:
                        '${state.weeklyWeightChange > 0 ? '+' : ''}${state.weeklyWeightChange.toStringAsFixed(1)} '
                        '${translate('home_page.kg_unit')}',
                    icon: state.weeklyWeightChange > 0
                        ? Icons.trending_up
                        : state.weeklyWeightChange < 0
                        ? Icons.trending_down
                        : Icons.trending_flat,
                  ),
                  const SizedBox(height: 16),
                  StatCard(
                    title: translate('stats.limit_exceeded_count'),
                    value: translatePlural(
                      'stats.days',
                      state.limitExceededCount,
                      args: <String, Object?>{
                        'count': state.limitExceededCount,
                      },
                    ),
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(translate('coming_soon')),
            );
          }
        },
      ),
    );
  }
}
