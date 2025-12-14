import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/recipes/widgets/day_card.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class WeightLossRecipesPage extends StatelessWidget {
  const WeightLossRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundScaffold(
      appBar: BlurredAppBar(
        title: translate('recipes_page.title'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          constants.kHorizontalIndent,
          MediaQuery.paddingOf(context).top + 76,
          constants.kHorizontalIndent,
          80.0,
        ),
        children: <Widget>[
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                translate('recipes_page.disclaimer'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          DayCard(
            title: translate('recipes_page.week_1'),
            dayTitle: translate('recipes_page.day_1'),
            meals: <String>[
              translate('recipes_page.day_1_breakfast'),
              translate('recipes_page.day_1_second_breakfast'),
              translate('recipes_page.day_1_lunch'),
              translate('recipes_page.day_1_snack'),
              translate('recipes_page.day_1_dinner'),
            ],
            total: translate('recipes_page.day_1_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_2'),
            meals: <String>[
              translate('recipes_page.day_2_breakfast'),
              translate('recipes_page.day_2_second_breakfast'),
              translate('recipes_page.day_2_lunch'),
              translate('recipes_page.day_2_snack'),
              translate('recipes_page.day_2_dinner'),
            ],
            total: translate('recipes_page.day_2_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_3'),
            meals: <String>[
              translate('recipes_page.day_3_diet'),
            ],
            total: translate('recipes_page.day_3_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_4'),
            meals: <String>[
              translate('recipes_page.day_4_breakfast'),
              translate('recipes_page.day_4_second_breakfast'),
              translate('recipes_page.day_4_lunch'),
              translate('recipes_page.day_4_snack'),
              translate('recipes_page.day_4_dinner'),
            ],
            total: translate('recipes_page.day_4_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_5'),
            meals: <String>[
              translate('recipes_page.day_5_breakfast'),
              translate('recipes_page.day_5_second_breakfast'),
              translate('recipes_page.day_5_lunch'),
              translate('recipes_page.day_5_snack'),
              translate('recipes_page.day_5_dinner'),
            ],
            total: translate('recipes_page.day_5_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_6'),
            meals: <String>[
              translate('recipes_page.day_6_breakfast'),
              translate('recipes_page.day_6_second_breakfast'),
              translate('recipes_page.day_6_lunch'),
              translate('recipes_page.day_6_snack'),
              translate('recipes_page.day_6_dinner'),
            ],
            total: translate('recipes_page.day_6_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_7'),
            meals: <String>[
              translate('recipes_page.day_7_breakfast'),
              translate('recipes_page.day_7_second_breakfast'),
              translate('recipes_page.day_7_lunch'),
              translate('recipes_page.day_7_snack'),
              translate('recipes_page.day_7_dinner'),
            ],
            total: translate('recipes_page.day_7_total'),
          ),
          DayCard(
            title: translate('recipes_page.notes_title'),
            meals: <String>[
              translate('recipes_page.notes_sweets'),
              translate('recipes_page.notes_salad'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            title: translate('recipes_page.week_2'),
            dayTitle: translate('recipes_page.day_8'),
            meals: <String>[
              translate('recipes_page.day_8_breakfast'),
              translate('recipes_page.day_8_second_breakfast'),
              translate('recipes_page.day_8_lunch'),
              translate('recipes_page.day_8_snack'),
              translate('recipes_page.day_8_dinner'),
            ],
            total: translate('recipes_page.day_8_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_9'),
            meals: <String>[
              translate('recipes_page.day_9_diet'),
            ],
            total: translate('recipes_page.day_9_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_10'),
            meals: <String>[
              translate('recipes_page.day_10_breakfast'),
              translate('recipes_page.day_10_second_breakfast'),
              translate('recipes_page.day_10_lunch'),
              translate('recipes_page.day_10_snack'),
              translate('recipes_page.day_10_dinner'),
            ],
            total: translate('recipes_page.day_10_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_11'),
            meals: <String>[
              translate('recipes_page.day_11_breakfast'),
              translate('recipes_page.day_11_second_breakfast'),
              translate('recipes_page.day_11_lunch'),
              translate('recipes_page.day_11_snack'),
              translate('recipes_page.day_11_dinner'),
            ],
            total: translate('recipes_page.day_11_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_12'),
            meals: <String>[
              translate('recipes_page.day_12_breakfast'),
              translate('recipes_page.day_12_second_breakfast'),
              translate('recipes_page.day_12_lunch'),
              translate('recipes_page.day_12_snack'),
              translate('recipes_page.day_12_dinner'),
            ],
            total: translate('recipes_page.day_12_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_13'),
            meals: <String>[
              translate('recipes_page.day_13_breakfast'),
              translate('recipes_page.day_13_second_breakfast'),
              translate('recipes_page.day_13_lunch'),
              translate('recipes_page.day_13_snack'),
              translate('recipes_page.day_13_dinner'),
            ],
            total: translate('recipes_page.day_13_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_14'),
            meals: <String>[
              translate('recipes_page.day_14_breakfast'),
              translate('recipes_page.day_14_second_breakfast'),
              translate('recipes_page.day_14_lunch'),
              translate('recipes_page.day_14_snack'),
              translate('recipes_page.day_14_dinner'),
            ],
            total: translate('recipes_page.day_14_total'),
          ),
          DayCard(
            title: translate('recipes_page.notes_week_2_title'),
            meals: <String>[
              translate('recipes_page.notes_week_2_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            title: translate('recipes_page.week_3'),
            dayTitle: translate('recipes_page.day_15'),
            meals: <String>[
              translate('recipes_page.day_15_breakfast'),
              translate('recipes_page.day_15_second_breakfast'),
              translate('recipes_page.day_15_lunch'),
              translate('recipes_page.day_15_snack'),
              translate('recipes_page.day_15_dinner'),
            ],
            total: translate('recipes_page.day_15_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_16'),
            meals: <String>[
              translate('recipes_page.day_16_breakfast'),
              translate('recipes_page.day_16_second_breakfast'),
              translate('recipes_page.day_16_lunch'),
              translate('recipes_page.day_16_snack'),
              translate('recipes_page.day_16_dinner'),
            ],
            total: translate('recipes_page.day_16_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_17'),
            meals: <String>[
              translate('recipes_page.day_17_breakfast'),
              translate('recipes_page.day_17_second_breakfast'),
              translate('recipes_page.day_17_lunch'),
              translate('recipes_page.day_17_snack'),
              translate('recipes_page.day_17_dinner'),
            ],
            total: translate('recipes_page.day_17_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_18'),
            meals: <String>[
              translate('recipes_page.day_18_breakfast'),
              translate('recipes_page.day_18_second_breakfast'),
              translate('recipes_page.day_18_lunch'),
              translate('recipes_page.day_18_snack'),
              translate('recipes_page.day_18_dinner'),
            ],
            total: translate('recipes_page.day_18_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_19'),
            meals: <String>[
              translate('recipes_page.day_19_breakfast'),
              translate('recipes_page.day_19_second_breakfast'),
              translate('recipes_page.day_19_lunch'),
              translate('recipes_page.day_19_snack'),
              translate('recipes_page.day_19_dinner'),
            ],
            total: translate('recipes_page.day_19_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_20'),
            meals: <String>[
              translate('recipes_page.day_20_breakfast'),
              translate('recipes_page.day_20_second_breakfast'),
              translate('recipes_page.day_20_lunch'),
              translate('recipes_page.day_20_snack'),
              translate('recipes_page.day_20_dinner'),
            ],
            total: translate('recipes_page.day_20_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_21'),
            meals: <String>[
              translate('recipes_page.day_21_breakfast'),
              translate('recipes_page.day_21_second_breakfast'),
              translate('recipes_page.day_21_lunch'),
              translate('recipes_page.day_21_snack'),
              translate('recipes_page.day_21_dinner'),
            ],
            total: translate('recipes_page.day_21_total'),
          ),
          const SizedBox(height: 16),
          DayCard(
            title: translate('recipes_page.week_4'),
            dayTitle: translate('recipes_page.day_22'),
            meals: <String>[
              translate('recipes_page.day_22_breakfast'),
              translate('recipes_page.day_22_second_breakfast'),
              translate('recipes_page.day_22_lunch'),
              translate('recipes_page.day_22_snack'),
              translate('recipes_page.day_22_dinner'),
            ],
            total: translate('recipes_page.day_22_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_23'),
            meals: <String>[
              translate('recipes_page.day_23_diet'),
            ],
            total: translate('recipes_page.day_23_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_24'),
            meals: <String>[
              translate('recipes_page.day_24_breakfast'),
              translate('recipes_page.day_24_second_breakfast'),
              translate('recipes_page.day_24_lunch'),
              translate('recipes_page.day_24_snack'),
              translate('recipes_page.day_24_dinner'),
            ],
            total: translate('recipes_page.day_24_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_25'),
            meals: <String>[
              translate('recipes_page.day_25_breakfast'),
              translate('recipes_page.day_25_second_breakfast'),
              translate('recipes_page.day_25_lunch'),
              translate('recipes_page.day_25_snack'),
              translate('recipes_page.day_25_dinner'),
            ],
            total: translate('recipes_page.day_25_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_26'),
            meals: <String>[
              translate('recipes_page.day_26_breakfast'),
              translate('recipes_page.day_26_second_breakfast'),
              translate('recipes_page.day_26_lunch'),
              translate('recipes_page.day_26_snack'),
              translate('recipes_page.day_26_dinner'),
            ],
            total: translate('recipes_page.day_26_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_27'),
            meals: <String>[
              translate('recipes_page.day_27_breakfast'),
              translate('recipes_page.day_27_second_breakfast'),
              translate('recipes_page.day_27_lunch'),
              translate('recipes_page.day_27_snack'),
              translate('recipes_page.day_27_dinner'),
            ],
            total: translate('recipes_page.day_27_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_28'),
            meals: <String>[
              translate('recipes_page.day_28_breakfast'),
              translate('recipes_page.day_28_second_breakfast'),
              translate('recipes_page.day_28_lunch'),
              translate('recipes_page.day_28_snack'),
              translate('recipes_page.day_28_dinner'),
            ],
            total: translate('recipes_page.day_28_total'),
          ),
          DayCard(
            title: translate('recipes_page.notes_week_4_title'),
            meals: <String>[
              translate('recipes_page.notes_week_4_sweets'),
            ],
          ),
        ],
      ),
    );
  }
}
