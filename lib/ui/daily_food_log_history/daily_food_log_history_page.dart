import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/daily_food_log_history/daily_food_log_history_bloc.dart';
import 'package:portion_control/domain/models/day_food_log.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/daily_food_log_history/widgets/day_log_card.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class DailyFoodLogHistoryPage extends StatelessWidget {
  const DailyFoodLogHistoryPage({super.key});

  @override
  Widget build(BuildContext _) {
    return GradientBackgroundScaffold(
      appBar: BlurredAppBar(
        title: translate('daily_food_log_history.title'),
      ),
      body: BlocBuilder<DailyFoodLogHistoryBloc, DailyFoodLogHistoryState>(
        builder: (BuildContext context, DailyFoodLogHistoryState state) {
          if (state is DailyFoodLogHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DailyFoodLogHistoryLoaded) {
            final double screenWidth = MediaQuery.sizeOf(context).width;
            final bool isWide = screenWidth > constants.wideScreenThreshold;
            final double horizontalPadding = isWide
                ? (screenWidth - constants.wideScreenContentWidth) / 2
                : constants.kHorizontalIndent;
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                MediaQuery.paddingOf(context).top + 24.0,
                horizontalPadding,
                80.0,
              ),
              itemCount: state.days.length,
              separatorBuilder: (BuildContext _, int _) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (BuildContext _, int index) {
                final DayFoodLog day = state.days[index];
                return DayLogCard(day: day);
              },
            );
          } else if (state is DailyFoodLogHistoryError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text(translate('coming_soon')));
          }
        },
      ),
    );
  }
}
