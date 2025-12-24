import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/recipes/widgets/day_card.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

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
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      translate('recipes_page.disclaimer'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: translate('recipes_page.disclaimer_info_tooltip'),
                    onPressed: () => _showDisclaimerDialog(context),
                  ),
                ],
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
          const SizedBox(height: 16),
          DayCard(
            title: translate('recipes_page.week_5'),
            dayTitle: translate('recipes_page.day_29'),
            meals: <String>[
              translate('recipes_page.day_29_breakfast'),
              translate('recipes_page.day_29_second_breakfast'),
              translate('recipes_page.day_29_lunch'),
              translate('recipes_page.day_29_snack'),
              translate('recipes_page.day_29_dinner'),
            ],
            total: translate('recipes_page.day_29_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_30'),
            meals: <String>[
              translate('recipes_page.day_30_breakfast'),
              translate('recipes_page.day_30_second_breakfast'),
              translate('recipes_page.day_30_lunch'),
              translate('recipes_page.day_30_snack'),
              translate('recipes_page.day_30_dinner'),
            ],
            total: translate('recipes_page.day_30_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_31'),
            meals: <String>[
              translate('recipes_page.day_31_diet'),
            ],
            total: translate('recipes_page.day_31_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_32'),
            meals: <String>[
              translate('recipes_page.day_32_breakfast'),
              translate('recipes_page.day_32_second_breakfast'),
              translate('recipes_page.day_32_lunch'),
              translate('recipes_page.day_32_snack'),
              translate('recipes_page.day_32_dinner'),
            ],
            total: translate('recipes_page.day_32_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_33'),
            meals: <String>[
              translate('recipes_page.day_33_breakfast'),
              translate('recipes_page.day_33_second_breakfast'),
              translate('recipes_page.day_33_lunch'),
              translate('recipes_page.day_33_snack'),
              translate('recipes_page.day_33_dinner'),
            ],
            total: translate('recipes_page.day_33_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_34'),
            meals: <String>[
              translate('recipes_page.day_34_breakfast'),
              translate('recipes_page.day_34_second_breakfast'),
              translate('recipes_page.day_34_lunch'),
              translate('recipes_page.day_34_snack'),
              translate('recipes_page.day_34_dinner'),
            ],
            total: translate('recipes_page.day_34_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_35'),
            meals: <String>[
              translate('recipes_page.day_35_breakfast'),
              translate('recipes_page.day_35_second_breakfast'),
              translate('recipes_page.day_35_lunch'),
              translate('recipes_page.day_35_snack'),
              translate('recipes_page.day_35_dinner'),
            ],
            total: translate('recipes_page.day_35_total'),
          ),
          DayCard(
            title: translate('recipes_page.notes_week_5_title'),
            meals: <String>[
              translate('recipes_page.notes_week_5_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            title: translate('recipes_page.week_6'),
            dayTitle: translate('recipes_page.day_36'),
            meals: <String>[
              translate('recipes_page.day_36_breakfast'),
              translate('recipes_page.day_36_second_breakfast'),
              translate('recipes_page.day_36_lunch'),
              translate('recipes_page.day_36_snack'),
              translate('recipes_page.day_36_dinner'),
            ],
            total: translate('recipes_page.day_36_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_37'),
            meals: <String>[
              translate('recipes_page.day_37_breakfast'),
              translate('recipes_page.day_37_second_breakfast'),
              translate('recipes_page.day_37_lunch'),
              translate('recipes_page.day_37_snack'),
              translate('recipes_page.day_37_dinner'),
            ],
            total: translate('recipes_page.day_37_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_38'),
            meals: <String>[
              translate('recipes_page.day_38_diet'),
            ],
            total: translate('recipes_page.day_38_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_39'),
            meals: <String>[
              translate('recipes_page.day_39_breakfast'),
              translate('recipes_page.day_39_second_breakfast'),
              translate('recipes_page.day_39_lunch'),
              translate('recipes_page.day_39_snack'),
              translate('recipes_page.day_39_dinner'),
            ],
            total: translate('recipes_page.day_39_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_40'),
            meals: <String>[
              translate('recipes_page.day_40_breakfast'),
              translate('recipes_page.day_40_second_breakfast'),
              translate('recipes_page.day_40_lunch'),
              translate('recipes_page.day_40_snack'),
              translate('recipes_page.day_40_dinner'),
            ],
            total: translate('recipes_page.day_40_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_41'),
            meals: <String>[
              translate('recipes_page.day_41_breakfast'),
              translate('recipes_page.day_41_second_breakfast'),
              translate('recipes_page.day_41_lunch'),
              translate('recipes_page.day_41_snack'),
              translate('recipes_page.day_41_dinner'),
            ],
            total: translate('recipes_page.day_41_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_42'),
            meals: <String>[
              translate('recipes_page.day_42_breakfast'),
              translate('recipes_page.day_42_second_breakfast'),
              translate('recipes_page.day_42_lunch'),
              translate('recipes_page.day_42_snack'),
              translate('recipes_page.day_42_dinner'),
            ],
            total: translate('recipes_page.day_42_total'),
          ),
          DayCard(
            title: translate('recipes_page.notes_week_6_title'),
            meals: <String>[
              translate('recipes_page.notes_week_6_soups'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            title: translate('recipes_page.week_7'),
            dayTitle: translate('recipes_page.day_43'),
            meals: <String>[
              translate('recipes_page.day_43_breakfast'),
              translate('recipes_page.day_43_second_breakfast'),
              translate('recipes_page.day_43_lunch'),
              translate('recipes_page.day_43_snack'),
              translate('recipes_page.day_43_dinner'),
            ],
            total: translate('recipes_page.day_43_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_44'),
            meals: <String>[
              translate('recipes_page.day_44_breakfast'),
              translate('recipes_page.day_44_second_breakfast'),
              translate('recipes_page.day_44_lunch'),
              translate('recipes_page.day_44_snack'),
              translate('recipes_page.day_44_dinner'),
            ],
            total: translate('recipes_page.day_44_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_45'),
            meals: <String>[
              translate('recipes_page.day_45_breakfast'),
              translate('recipes_page.day_45_second_breakfast'),
              translate('recipes_page.day_45_lunch'),
              translate('recipes_page.day_45_snack'),
              translate('recipes_page.day_45_dinner'),
            ],
            total: translate('recipes_page.day_45_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_46'),
            meals: <String>[
              translate('recipes_page.day_46_breakfast'),
              translate('recipes_page.day_46_second_breakfast'),
              translate('recipes_page.day_46_lunch'),
              translate('recipes_page.day_46_snack'),
              translate('recipes_page.day_46_dinner'),
            ],
            total: translate('recipes_page.day_46_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_47'),
            meals: <String>[
              translate('recipes_page.day_47_breakfast'),
              translate('recipes_page.day_47_second_breakfast'),
              translate('recipes_page.day_47_lunch'),
              translate('recipes_page.day_47_snack'),
              translate('recipes_page.day_47_dinner'),
            ],
            total: translate('recipes_page.day_47_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_48'),
            meals: <String>[
              translate('recipes_page.day_48_diet'),
            ],
            total: translate('recipes_page.day_48_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_49'),
            meals: <String>[
              translate('recipes_page.day_49_breakfast'),
              translate('recipes_page.day_49_second_breakfast'),
              translate('recipes_page.day_49_lunch'),
              translate('recipes_page.day_49_snack'),
              translate('recipes_page.day_49_dinner'),
            ],
            total: translate('recipes_page.day_49_total'),
          ),
          DayCard(
            title: translate('recipes_page.notes_week_7_title'),
            meals: <String>[
              translate('recipes_page.notes_week_7_general'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            title: translate('recipes_page.week_8'),
            dayTitle: translate('recipes_page.day_50'),
            meals: <String>[
              translate('recipes_page.day_50_breakfast'),
              translate('recipes_page.day_50_second_breakfast'),
              translate('recipes_page.day_50_lunch'),
              translate('recipes_page.day_50_snack'),
              translate('recipes_page.day_50_dinner'),
            ],
            total: translate('recipes_page.day_50_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_51'),
            meals: <String>[
              translate('recipes_page.day_51_breakfast'),
              translate('recipes_page.day_51_second_breakfast'),
              translate('recipes_page.day_51_lunch'),
              translate('recipes_page.day_51_snack'),
              translate('recipes_page.day_51_dinner'),
            ],
            total: translate('recipes_page.day_51_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_52'),
            meals: <String>[
              translate('recipes_page.day_52_diet'),
            ],
            total: translate('recipes_page.day_52_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_53'),
            meals: <String>[
              translate('recipes_page.day_53_diet'),
            ],
            total: translate('recipes_page.day_53_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_54'),
            meals: <String>[
              translate('recipes_page.day_54_breakfast'),
              translate('recipes_page.day_54_second_breakfast'),
              translate('recipes_page.day_54_lunch'),
              translate('recipes_page.day_54_snack'),
              translate('recipes_page.day_54_dinner'),
            ],
            total: translate('recipes_page.day_54_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_55'),
            meals: <String>[
              translate('recipes_page.day_55_breakfast'),
              translate('recipes_page.day_55_second_breakfast'),
              translate('recipes_page.day_55_lunch'),
              translate('recipes_page.day_55_snack'),
              translate('recipes_page.day_55_dinner'),
            ],
            total: translate('recipes_page.day_55_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_56'),
            meals: <String>[
              translate('recipes_page.day_56_breakfast'),
              translate('recipes_page.day_56_second_breakfast'),
              translate('recipes_page.day_56_lunch'),
              translate('recipes_page.day_56_snack'),
              translate('recipes_page.day_56_dinner'),
            ],
            total: translate('recipes_page.day_56_total'),
          ),
          DayCard(
            title: translate('recipes_page.notes_week_8_title'),
            meals: <String>[
              translate('recipes_page.notes_week_8_general'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            title: translate('recipes_page.week_9'),
            dayTitle: translate('recipes_page.day_57'),
            meals: <String>[
              translate('recipes_page.day_57_breakfast'),
              translate('recipes_page.day_57_second_breakfast'),
              translate('recipes_page.day_57_lunch'),
              translate('recipes_page.day_57_snack'),
              translate('recipes_page.day_57_dinner'),
            ],
            total: translate('recipes_page.day_57_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_58'),
            meals: <String>[
              translate('recipes_page.day_58_breakfast'),
              translate('recipes_page.day_58_second_breakfast'),
              translate('recipes_page.day_58_lunch'),
              translate('recipes_page.day_58_snack'),
              translate('recipes_page.day_58_dinner'),
            ],
            total: translate('recipes_page.day_58_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_59'),
            meals: <String>[
              translate('recipes_page.day_59_diet'),
            ],
            total: translate('recipes_page.day_59_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_60'),
            meals: <String>[
              translate('recipes_page.day_60_breakfast'),
              translate('recipes_page.day_60_second_breakfast'),
              translate('recipes_page.day_60_lunch'),
              translate('recipes_page.day_60_snack'),
              translate('recipes_page.day_60_dinner'),
            ],
            total: translate('recipes_page.day_60_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_61'),
            meals: <String>[
              translate('recipes_page.day_61_breakfast'),
              translate('recipes_page.day_61_second_breakfast'),
              translate('recipes_page.day_61_lunch'),
              translate('recipes_page.day_61_snack'),
              translate('recipes_page.day_61_dinner'),
            ],
            total: translate('recipes_page.day_61_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_62'),
            meals: <String>[
              translate('recipes_page.day_62_breakfast'),
              translate('recipes_page.day_62_second_breakfast'),
              translate('recipes_page.day_62_lunch'),
              translate('recipes_page.day_62_snack'),
              translate('recipes_page.day_62_dinner'),
            ],
            total: translate('recipes_page.day_62_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_63'),
            meals: <String>[
              translate('recipes_page.day_63_breakfast'),
              translate('recipes_page.day_63_second_breakfast'),
              translate('recipes_page.day_63_lunch'),
              translate('recipes_page.day_63_snack'),
              translate('recipes_page.day_63_dinner'),
            ],
            total: translate('recipes_page.day_63_total'),
          ),
          DayCard(
            title: translate('recipes_page.notes_week_9_title'),
            meals: <String>[
              translate('recipes_page.notes_week_9_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            title: translate('recipes_page.week_10'),
            dayTitle: translate('recipes_page.day_64'),
            meals: <String>[
              translate('recipes_page.day_64_breakfast'),
              translate('recipes_page.day_64_second_breakfast'),
              translate('recipes_page.day_64_lunch'),
              translate('recipes_page.day_64_snack'),
              translate('recipes_page.day_64_dinner'),
            ],
            total: translate('recipes_page.day_64_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_65'),
            meals: <String>[
              translate('recipes_page.day_65_diet'),
            ],
            total: translate('recipes_page.day_65_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_66'),
            meals: <String>[
              translate('recipes_page.day_66_breakfast'),
              translate('recipes_page.day_66_second_breakfast'),
              translate('recipes_page.day_66_lunch'),
              translate('recipes_page.day_66_snack'),
              translate('recipes_page.day_66_dinner'),
            ],
            total: translate('recipes_page.day_66_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_67'),
            meals: <String>[
              translate('recipes_page.day_67_breakfast'),
              translate('recipes_page.day_67_second_breakfast'),
              translate('recipes_page.day_67_lunch'),
              translate('recipes_page.day_67_snack'),
              translate('recipes_page.day_67_dinner'),
            ],
            total: translate('recipes_page.day_67_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_68'),
            meals: <String>[
              translate('recipes_page.day_68_breakfast'),
              translate('recipes_page.day_68_second_breakfast'),
              translate('recipes_page.day_68_lunch'),
              translate('recipes_page.day_68_snack'),
              translate('recipes_page.day_68_dinner'),
            ],
            total: translate('recipes_page.day_68_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_69'),
            meals: <String>[
              translate('recipes_page.day_69_breakfast'),
              translate('recipes_page.day_69_second_breakfast'),
              translate('recipes_page.day_69_lunch'),
              translate('recipes_page.day_69_snack'),
              translate('recipes_page.day_69_dinner'),
            ],
            total: translate('recipes_page.day_69_total'),
          ),
          DayCard(
            dayTitle: translate('recipes_page.day_70'),
            meals: <String>[
              translate('recipes_page.day_70_breakfast'),
              translate('recipes_page.day_70_second_breakfast'),
              translate('recipes_page.day_70_lunch'),
              translate('recipes_page.day_70_snack'),
              translate('recipes_page.day_70_dinner'),
            ],
            total: translate('recipes_page.day_70_total'),
          ),
          DayCard(
            title: translate('recipes_page.notes_week_10_title'),
            meals: <String>[
              translate('recipes_page.notes_week_10_sweets'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showDisclaimerDialog(BuildContext context) {
    final Uri whoUri = Uri.parse(
      translate('health_sources.who_url'),
    );
    final Uri cdcUri = Uri.parse(
      translate('health_sources.cdc_url'),
    );
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            translate('recipes_page.disclaimer_full_title'),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium,
                    children: <InlineSpan>[
                      TextSpan(
                        text:
                            '${translate(
                              'recipes_page.disclaimer_full',
                            )} ',
                      ),
                      TextSpan(
                        text: translate('health_sources.who'),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                            whoUri,
                            mode: LaunchMode.externalApplication,
                          ),
                      ),
                      const TextSpan(text: ' · '),
                      TextSpan(
                        text: translate('health_sources.cdc'),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                            cdcUri,
                            mode: LaunchMode.externalApplication,
                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(
                MaterialLocalizations.of(
                  context,
                ).closeButtonLabel,
              ),
            ),
          ],
        );
      },
    );
  }
}
