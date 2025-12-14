import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class DailyFoodLogHistoryPage extends StatelessWidget {
  const DailyFoodLogHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundScaffold(
      appBar: BlurredAppBar(
        title: translate('daily_food_log_history.title'),
      ),
      body: Center(
        child: Text(translate('coming_soon')),
      ),
    );
  }
}
