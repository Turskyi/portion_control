import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/services/recipe_tried_state_service.dart';
import 'package:portion_control/ui/recipes/widgets/day_card.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class WeightLossRecipesPage extends StatefulWidget {
  const WeightLossRecipesPage({super.key});

  @override
  State<WeightLossRecipesPage> createState() => _WeightLossRecipesPageState();
}

class _WeightLossRecipesPageState extends State<WeightLossRecipesPage> {
  final RecipeTriedStateService _triedStateService = RecipeTriedStateService();
  final Map<String, bool> _triedStates = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _loadAllTriedStates();
  }

  Future<void> _loadAllTriedStates() async {
    // Load tried states for all recipe IDs
    // Recipe IDs are based on day_X format
    for (int i = 1; i <= 154; i++) {
      final String recipeId = 'day_$i';
      final bool tried = await _triedStateService.getTriedState(recipeId);
      if (mounted) {
        setState(() {
          _triedStates[recipeId] = tried;
        });
      }
    }
  }

  Future<void> _toggleTried(String recipeId) async {
    final bool newState = await _triedStateService.toggleTriedState(recipeId);
    if (mounted) {
      setState(() {
        _triedStates[recipeId] = newState;
      });
    }
  }

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
            recipeId: 'day_1',
            tried: _triedStates['day_1'] ?? false,
            onTriedChanged: () => _toggleTried('day_1'),

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
            recipeId: 'day_2',
            tried: _triedStates['day_2'] ?? false,
            onTriedChanged: () => _toggleTried('day_2'),

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
            recipeId: 'day_3',
            tried: _triedStates['day_3'] ?? false,
            onTriedChanged: () => _toggleTried('day_3'),

            dayTitle: translate('recipes_page.day_3'),
            meals: <String>[
              translate('recipes_page.day_3_diet'),
            ],
            total: translate('recipes_page.day_3_total'),
          ),
          DayCard(
            recipeId: 'day_4',
            tried: _triedStates['day_4'] ?? false,
            onTriedChanged: () => _toggleTried('day_4'),

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
            recipeId: 'day_5',
            tried: _triedStates['day_5'] ?? false,
            onTriedChanged: () => _toggleTried('day_5'),

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
            recipeId: 'day_6',
            tried: _triedStates['day_6'] ?? false,
            onTriedChanged: () => _toggleTried('day_6'),

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
            recipeId: 'day_7',
            tried: _triedStates['day_7'] ?? false,
            onTriedChanged: () => _toggleTried('day_7'),

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
            recipeId: 'notes_title',
            tried: _triedStates['notes_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_title'),

            title: translate('recipes_page.notes_title'),
            meals: <String>[
              translate('recipes_page.notes_sweets'),
              translate('recipes_page.notes_salad'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_8',
            tried: _triedStates['day_8'] ?? false,
            onTriedChanged: () => _toggleTried('day_8'),

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
            recipeId: 'day_9',
            tried: _triedStates['day_9'] ?? false,
            onTriedChanged: () => _toggleTried('day_9'),

            dayTitle: translate('recipes_page.day_9'),
            meals: <String>[
              translate('recipes_page.day_9_diet'),
            ],
            total: translate('recipes_page.day_9_total'),
          ),
          DayCard(
            recipeId: 'day_10',
            tried: _triedStates['day_10'] ?? false,
            onTriedChanged: () => _toggleTried('day_10'),

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
            recipeId: 'day_11',
            tried: _triedStates['day_11'] ?? false,
            onTriedChanged: () => _toggleTried('day_11'),

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
            recipeId: 'day_12',
            tried: _triedStates['day_12'] ?? false,
            onTriedChanged: () => _toggleTried('day_12'),

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
            recipeId: 'day_13',
            tried: _triedStates['day_13'] ?? false,
            onTriedChanged: () => _toggleTried('day_13'),

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
            recipeId: 'day_14',
            tried: _triedStates['day_14'] ?? false,
            onTriedChanged: () => _toggleTried('day_14'),

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
            recipeId: 'notes_week_2_title',
            tried: _triedStates['notes_week_2_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_2_title'),

            title: translate('recipes_page.notes_week_2_title'),
            meals: <String>[
              translate('recipes_page.notes_week_2_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_15',
            tried: _triedStates['day_15'] ?? false,
            onTriedChanged: () => _toggleTried('day_15'),

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
            recipeId: 'day_16',
            tried: _triedStates['day_16'] ?? false,
            onTriedChanged: () => _toggleTried('day_16'),

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
            recipeId: 'day_17',
            tried: _triedStates['day_17'] ?? false,
            onTriedChanged: () => _toggleTried('day_17'),

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
            recipeId: 'day_18',
            tried: _triedStates['day_18'] ?? false,
            onTriedChanged: () => _toggleTried('day_18'),

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
            recipeId: 'day_19',
            tried: _triedStates['day_19'] ?? false,
            onTriedChanged: () => _toggleTried('day_19'),

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
            recipeId: 'day_20',
            tried: _triedStates['day_20'] ?? false,
            onTriedChanged: () => _toggleTried('day_20'),

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
            recipeId: 'day_21',
            tried: _triedStates['day_21'] ?? false,
            onTriedChanged: () => _toggleTried('day_21'),

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
            recipeId: 'day_22',
            tried: _triedStates['day_22'] ?? false,
            onTriedChanged: () => _toggleTried('day_22'),

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
            recipeId: 'day_23',
            tried: _triedStates['day_23'] ?? false,
            onTriedChanged: () => _toggleTried('day_23'),

            dayTitle: translate('recipes_page.day_23'),
            meals: <String>[
              translate('recipes_page.day_23_diet'),
            ],
            total: translate('recipes_page.day_23_total'),
          ),
          DayCard(
            recipeId: 'day_24',
            tried: _triedStates['day_24'] ?? false,
            onTriedChanged: () => _toggleTried('day_24'),

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
            recipeId: 'day_25',
            tried: _triedStates['day_25'] ?? false,
            onTriedChanged: () => _toggleTried('day_25'),

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
            recipeId: 'day_26',
            tried: _triedStates['day_26'] ?? false,
            onTriedChanged: () => _toggleTried('day_26'),

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
            recipeId: 'day_27',
            tried: _triedStates['day_27'] ?? false,
            onTriedChanged: () => _toggleTried('day_27'),

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
            recipeId: 'day_28',
            tried: _triedStates['day_28'] ?? false,
            onTriedChanged: () => _toggleTried('day_28'),

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
            recipeId: 'notes_week_4_title',
            tried: _triedStates['notes_week_4_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_4_title'),

            title: translate('recipes_page.notes_week_4_title'),
            meals: <String>[
              translate('recipes_page.notes_week_4_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_29',
            tried: _triedStates['day_29'] ?? false,
            onTriedChanged: () => _toggleTried('day_29'),

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
            recipeId: 'day_30',
            tried: _triedStates['day_30'] ?? false,
            onTriedChanged: () => _toggleTried('day_30'),

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
            recipeId: 'day_31',
            tried: _triedStates['day_31'] ?? false,
            onTriedChanged: () => _toggleTried('day_31'),

            dayTitle: translate('recipes_page.day_31'),
            meals: <String>[
              translate('recipes_page.day_31_diet'),
            ],
            total: translate('recipes_page.day_31_total'),
          ),
          DayCard(
            recipeId: 'day_32',
            tried: _triedStates['day_32'] ?? false,
            onTriedChanged: () => _toggleTried('day_32'),

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
            recipeId: 'day_33',
            tried: _triedStates['day_33'] ?? false,
            onTriedChanged: () => _toggleTried('day_33'),

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
            recipeId: 'day_34',
            tried: _triedStates['day_34'] ?? false,
            onTriedChanged: () => _toggleTried('day_34'),

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
            recipeId: 'day_35',
            tried: _triedStates['day_35'] ?? false,
            onTriedChanged: () => _toggleTried('day_35'),

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
            recipeId: 'notes_week_5_title',
            tried: _triedStates['notes_week_5_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_5_title'),

            title: translate('recipes_page.notes_week_5_title'),
            meals: <String>[
              translate('recipes_page.notes_week_5_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_36',
            tried: _triedStates['day_36'] ?? false,
            onTriedChanged: () => _toggleTried('day_36'),

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
            recipeId: 'day_37',
            tried: _triedStates['day_37'] ?? false,
            onTriedChanged: () => _toggleTried('day_37'),

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
            recipeId: 'day_38',
            tried: _triedStates['day_38'] ?? false,
            onTriedChanged: () => _toggleTried('day_38'),

            dayTitle: translate('recipes_page.day_38'),
            meals: <String>[
              translate('recipes_page.day_38_diet'),
            ],
            total: translate('recipes_page.day_38_total'),
          ),
          DayCard(
            recipeId: 'day_39',
            tried: _triedStates['day_39'] ?? false,
            onTriedChanged: () => _toggleTried('day_39'),

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
            recipeId: 'day_40',
            tried: _triedStates['day_40'] ?? false,
            onTriedChanged: () => _toggleTried('day_40'),

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
            recipeId: 'day_41',
            tried: _triedStates['day_41'] ?? false,
            onTriedChanged: () => _toggleTried('day_41'),

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
            recipeId: 'day_42',
            tried: _triedStates['day_42'] ?? false,
            onTriedChanged: () => _toggleTried('day_42'),

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
            recipeId: 'notes_week_6_title',
            tried: _triedStates['notes_week_6_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_6_title'),

            title: translate('recipes_page.notes_week_6_title'),
            meals: <String>[
              translate('recipes_page.notes_week_6_soups'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_43',
            tried: _triedStates['day_43'] ?? false,
            onTriedChanged: () => _toggleTried('day_43'),

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
            recipeId: 'day_44',
            tried: _triedStates['day_44'] ?? false,
            onTriedChanged: () => _toggleTried('day_44'),

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
            recipeId: 'day_45',
            tried: _triedStates['day_45'] ?? false,
            onTriedChanged: () => _toggleTried('day_45'),

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
            recipeId: 'day_46',
            tried: _triedStates['day_46'] ?? false,
            onTriedChanged: () => _toggleTried('day_46'),

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
            recipeId: 'day_47',
            tried: _triedStates['day_47'] ?? false,
            onTriedChanged: () => _toggleTried('day_47'),

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
            recipeId: 'day_48',
            tried: _triedStates['day_48'] ?? false,
            onTriedChanged: () => _toggleTried('day_48'),

            dayTitle: translate('recipes_page.day_48'),
            meals: <String>[
              translate('recipes_page.day_48_diet'),
            ],
            total: translate('recipes_page.day_48_total'),
          ),
          DayCard(
            recipeId: 'day_49',
            tried: _triedStates['day_49'] ?? false,
            onTriedChanged: () => _toggleTried('day_49'),

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
            recipeId: 'notes_week_7_title',
            tried: _triedStates['notes_week_7_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_7_title'),

            title: translate('recipes_page.notes_week_7_title'),
            meals: <String>[
              translate('recipes_page.notes_week_7_general'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_50',
            tried: _triedStates['day_50'] ?? false,
            onTriedChanged: () => _toggleTried('day_50'),

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
            recipeId: 'day_51',
            tried: _triedStates['day_51'] ?? false,
            onTriedChanged: () => _toggleTried('day_51'),

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
            recipeId: 'day_52',
            tried: _triedStates['day_52'] ?? false,
            onTriedChanged: () => _toggleTried('day_52'),

            dayTitle: translate('recipes_page.day_52'),
            meals: <String>[
              translate('recipes_page.day_52_diet'),
            ],
            total: translate('recipes_page.day_52_total'),
          ),
          DayCard(
            recipeId: 'day_53',
            tried: _triedStates['day_53'] ?? false,
            onTriedChanged: () => _toggleTried('day_53'),

            dayTitle: translate('recipes_page.day_53'),
            meals: <String>[
              translate('recipes_page.day_53_diet'),
            ],
            total: translate('recipes_page.day_53_total'),
          ),
          DayCard(
            recipeId: 'day_54',
            tried: _triedStates['day_54'] ?? false,
            onTriedChanged: () => _toggleTried('day_54'),

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
            recipeId: 'day_55',
            tried: _triedStates['day_55'] ?? false,
            onTriedChanged: () => _toggleTried('day_55'),

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
            recipeId: 'day_56',
            tried: _triedStates['day_56'] ?? false,
            onTriedChanged: () => _toggleTried('day_56'),

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
            recipeId: 'notes_week_8_title',
            tried: _triedStates['notes_week_8_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_8_title'),

            title: translate('recipes_page.notes_week_8_title'),
            meals: <String>[
              translate('recipes_page.notes_week_8_general'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_57',
            tried: _triedStates['day_57'] ?? false,
            onTriedChanged: () => _toggleTried('day_57'),

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
            recipeId: 'day_58',
            tried: _triedStates['day_58'] ?? false,
            onTriedChanged: () => _toggleTried('day_58'),

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
            recipeId: 'day_59',
            tried: _triedStates['day_59'] ?? false,
            onTriedChanged: () => _toggleTried('day_59'),

            dayTitle: translate('recipes_page.day_59'),
            meals: <String>[
              translate('recipes_page.day_59_diet'),
            ],
            total: translate('recipes_page.day_59_total'),
          ),
          DayCard(
            recipeId: 'day_60',
            tried: _triedStates['day_60'] ?? false,
            onTriedChanged: () => _toggleTried('day_60'),

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
            recipeId: 'day_61',
            tried: _triedStates['day_61'] ?? false,
            onTriedChanged: () => _toggleTried('day_61'),

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
            recipeId: 'day_62',
            tried: _triedStates['day_62'] ?? false,
            onTriedChanged: () => _toggleTried('day_62'),

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
            recipeId: 'day_63',
            tried: _triedStates['day_63'] ?? false,
            onTriedChanged: () => _toggleTried('day_63'),

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
            recipeId: 'notes_week_9_title',
            tried: _triedStates['notes_week_9_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_9_title'),

            title: translate('recipes_page.notes_week_9_title'),
            meals: <String>[
              translate('recipes_page.notes_week_9_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_64',
            tried: _triedStates['day_64'] ?? false,
            onTriedChanged: () => _toggleTried('day_64'),

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
            recipeId: 'day_65',
            tried: _triedStates['day_65'] ?? false,
            onTriedChanged: () => _toggleTried('day_65'),

            dayTitle: translate('recipes_page.day_65'),
            meals: <String>[
              translate('recipes_page.day_65_diet'),
            ],
            total: translate('recipes_page.day_65_total'),
          ),
          DayCard(
            recipeId: 'day_66',
            tried: _triedStates['day_66'] ?? false,
            onTriedChanged: () => _toggleTried('day_66'),

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
            recipeId: 'day_67',
            tried: _triedStates['day_67'] ?? false,
            onTriedChanged: () => _toggleTried('day_67'),

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
            recipeId: 'day_68',
            tried: _triedStates['day_68'] ?? false,
            onTriedChanged: () => _toggleTried('day_68'),

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
            recipeId: 'day_69',
            tried: _triedStates['day_69'] ?? false,
            onTriedChanged: () => _toggleTried('day_69'),

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
            recipeId: 'day_70',
            tried: _triedStates['day_70'] ?? false,
            onTriedChanged: () => _toggleTried('day_70'),

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
            recipeId: 'notes_week_10_title',
            tried: _triedStates['notes_week_10_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_10_title'),

            title: translate('recipes_page.notes_week_10_title'),
            meals: <String>[
              translate('recipes_page.notes_week_10_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_71',
            tried: _triedStates['day_71'] ?? false,
            onTriedChanged: () => _toggleTried('day_71'),

            title: translate('recipes_page.week_11'),
            dayTitle: translate('recipes_page.day_71'),
            meals: <String>[
              translate('recipes_page.day_71_breakfast'),
              translate('recipes_page.day_71_second_breakfast'),
              translate('recipes_page.day_71_lunch'),
            ],
            total: translate('recipes_page.day_71_total'),
          ),
          DayCard(
            recipeId: 'day_72',
            tried: _triedStates['day_72'] ?? false,
            onTriedChanged: () => _toggleTried('day_72'),

            dayTitle: translate('recipes_page.day_72'),
            meals: <String>[
              translate('recipes_page.day_72_diet'),
            ],
            total: translate('recipes_page.day_72_total'),
          ),
          DayCard(
            recipeId: 'day_73',
            tried: _triedStates['day_73'] ?? false,
            onTriedChanged: () => _toggleTried('day_73'),

            dayTitle: translate('recipes_page.day_73'),
            meals: <String>[
              translate('recipes_page.day_73_breakfast'),
              translate('recipes_page.day_73_second_breakfast'),
              translate('recipes_page.day_73_lunch'),
              translate('recipes_page.day_73_snack'),
              translate('recipes_page.day_73_dinner'),
            ],
            total: translate('recipes_page.day_73_total'),
          ),
          DayCard(
            recipeId: 'day_74',
            tried: _triedStates['day_74'] ?? false,
            onTriedChanged: () => _toggleTried('day_74'),

            dayTitle: translate('recipes_page.day_74'),
            meals: <String>[
              translate('recipes_page.day_74_breakfast'),
              translate('recipes_page.day_74_second_breakfast'),
              translate('recipes_page.day_74_lunch'),
              translate('recipes_page.day_74_snack'),
              translate('recipes_page.day_74_dinner'),
            ],
            total: translate('recipes_page.day_74_total'),
          ),
          DayCard(
            recipeId: 'day_75',
            tried: _triedStates['day_75'] ?? false,
            onTriedChanged: () => _toggleTried('day_75'),

            dayTitle: translate('recipes_page.day_75'),
            meals: <String>[
              translate('recipes_page.day_75_breakfast'),
              translate('recipes_page.day_75_lunch'),
              translate('recipes_page.day_75_snack'),
              translate('recipes_page.day_75_dinner'),
            ],
            total: translate('recipes_page.day_75_total'),
          ),
          DayCard(
            recipeId: 'day_76',
            tried: _triedStates['day_76'] ?? false,
            onTriedChanged: () => _toggleTried('day_76'),

            dayTitle: translate('recipes_page.day_76'),
            meals: <String>[
              translate('recipes_page.day_76_breakfast'),
              translate('recipes_page.day_76_lunch'),
              translate('recipes_page.day_76_snack'),
              translate('recipes_page.day_76_dinner'),
            ],
            total: translate('recipes_page.day_76_total'),
          ),
          DayCard(
            recipeId: 'day_77',
            tried: _triedStates['day_77'] ?? false,
            onTriedChanged: () => _toggleTried('day_77'),

            dayTitle: translate('recipes_page.day_77'),
            meals: <String>[
              translate('recipes_page.day_77_breakfast'),
              translate('recipes_page.day_77_second_breakfast'),
              translate('recipes_page.day_77_lunch'),
              translate('recipes_page.day_77_snack'),
              translate('recipes_page.day_77_dinner'),
            ],
            total: translate('recipes_page.day_77_total'),
          ),
          DayCard(
            recipeId: 'notes_week_11_title',
            tried: _triedStates['notes_week_11_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_11_title'),

            title: translate('recipes_page.notes_week_11_title'),
            meals: <String>[
              translate('recipes_page.notes_week_11_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_78',
            tried: _triedStates['day_78'] ?? false,
            onTriedChanged: () => _toggleTried('day_78'),

            title: translate('recipes_page.week_12'),
            dayTitle: translate('recipes_page.day_78'),
            meals: <String>[
              translate('recipes_page.day_78_breakfast'),
              translate('recipes_page.day_78_second_breakfast'),
              translate('recipes_page.day_78_lunch'),
              translate('recipes_page.day_78_snack'),
              translate('recipes_page.day_78_dinner'),
            ],
            total: translate('recipes_page.day_78_total'),
          ),
          DayCard(
            recipeId: 'day_79',
            tried: _triedStates['day_79'] ?? false,
            onTriedChanged: () => _toggleTried('day_79'),

            dayTitle: translate('recipes_page.day_79'),
            meals: <String>[
              translate('recipes_page.day_79_diet'),
            ],
            total: translate('recipes_page.day_79_total'),
          ),
          DayCard(
            recipeId: 'day_80',
            tried: _triedStates['day_80'] ?? false,
            onTriedChanged: () => _toggleTried('day_80'),

            dayTitle: translate('recipes_page.day_80'),
            meals: <String>[
              translate('recipes_page.day_80_breakfast'),
              translate('recipes_page.day_80_second_breakfast'),
              translate('recipes_page.day_80_lunch'),
              translate('recipes_page.day_80_snack'),
              translate('recipes_page.day_80_dinner'),
            ],
            total: translate('recipes_page.day_80_total'),
          ),
          DayCard(
            recipeId: 'day_81',
            tried: _triedStates['day_81'] ?? false,
            onTriedChanged: () => _toggleTried('day_81'),

            dayTitle: translate('recipes_page.day_81'),
            meals: <String>[
              translate('recipes_page.day_81_breakfast'),
              translate('recipes_page.day_81_second_breakfast'),
              translate('recipes_page.day_81_lunch'),
              translate('recipes_page.day_81_snack'),
              translate('recipes_page.day_81_dinner'),
            ],
            total: translate('recipes_page.day_81_total'),
          ),
          DayCard(
            recipeId: 'day_82',
            tried: _triedStates['day_82'] ?? false,
            onTriedChanged: () => _toggleTried('day_82'),

            dayTitle: translate('recipes_page.day_82'),
            meals: <String>[
              translate('recipes_page.day_82_breakfast'),
              translate('recipes_page.day_82_second_breakfast'),
              translate('recipes_page.day_82_lunch'),
              translate('recipes_page.day_82_snack'),
              translate('recipes_page.day_82_dinner'),
            ],
            total: translate('recipes_page.day_82_total'),
          ),
          DayCard(
            recipeId: 'day_83',
            tried: _triedStates['day_83'] ?? false,
            onTriedChanged: () => _toggleTried('day_83'),

            dayTitle: translate('recipes_page.day_83'),
            meals: <String>[
              translate('recipes_page.day_83_breakfast'),
              translate('recipes_page.day_83_second_breakfast'),
              translate('recipes_page.day_83_lunch'),
              translate('recipes_page.day_83_snack'),
              translate('recipes_page.day_83_dinner'),
            ],
            total: translate('recipes_page.day_83_total'),
          ),
          DayCard(
            recipeId: 'day_84',
            tried: _triedStates['day_84'] ?? false,
            onTriedChanged: () => _toggleTried('day_84'),

            dayTitle: translate('recipes_page.day_84'),
            meals: <String>[
              translate('recipes_page.day_84_breakfast'),
              translate('recipes_page.day_84_second_breakfast'),
              translate('recipes_page.day_84_lunch'),
              translate('recipes_page.day_84_snack'),
              translate('recipes_page.day_84_dinner'),
            ],
            total: translate('recipes_page.day_84_total'),
          ),
          DayCard(
            recipeId: 'notes_week_12_title',
            tried: _triedStates['notes_week_12_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_12_title'),

            title: translate('recipes_page.notes_week_12_title'),
            meals: <String>[
              translate('recipes_page.notes_week_12_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_85',
            tried: _triedStates['day_85'] ?? false,
            onTriedChanged: () => _toggleTried('day_85'),

            title: translate('recipes_page.week_13'),
            dayTitle: translate('recipes_page.day_85'),
            meals: <String>[
              translate('recipes_page.day_85_breakfast'),
              translate('recipes_page.day_85_second_breakfast'),
              translate('recipes_page.day_85_lunch'),
              translate('recipes_page.day_85_snack'),
              translate('recipes_page.day_85_dinner'),
            ],
            total: translate('recipes_page.day_85_total'),
          ),
          DayCard(
            recipeId: 'day_86',
            tried: _triedStates['day_86'] ?? false,
            onTriedChanged: () => _toggleTried('day_86'),

            dayTitle: translate('recipes_page.day_86'),
            meals: <String>[
              translate('recipes_page.day_86_diet'),
            ],
            total: translate('recipes_page.day_86_total'),
          ),
          DayCard(
            recipeId: 'day_87',
            tried: _triedStates['day_87'] ?? false,
            onTriedChanged: () => _toggleTried('day_87'),

            dayTitle: translate('recipes_page.day_87'),
            meals: <String>[
              translate('recipes_page.day_87_breakfast'),
              translate('recipes_page.day_87_second_breakfast'),
              translate('recipes_page.day_87_lunch'),
              translate('recipes_page.day_87_snack'),
              translate('recipes_page.day_87_dinner'),
            ],
            total: translate('recipes_page.day_87_total'),
          ),
          DayCard(
            recipeId: 'day_88',
            tried: _triedStates['day_88'] ?? false,
            onTriedChanged: () => _toggleTried('day_88'),

            dayTitle: translate('recipes_page.day_88'),
            meals: <String>[
              translate('recipes_page.day_88_breakfast'),
              translate('recipes_page.day_88_second_breakfast'),
              translate('recipes_page.day_88_lunch'),
              translate('recipes_page.day_88_snack'),
              translate('recipes_page.day_88_dinner'),
            ],
            total: translate('recipes_page.day_88_total'),
          ),
          DayCard(
            recipeId: 'day_89',
            tried: _triedStates['day_89'] ?? false,
            onTriedChanged: () => _toggleTried('day_89'),

            dayTitle: translate('recipes_page.day_89'),
            meals: <String>[
              translate('recipes_page.day_89_breakfast'),
              translate('recipes_page.day_89_second_breakfast'),
              translate('recipes_page.day_89_lunch'),
              translate('recipes_page.day_89_snack'),
              translate('recipes_page.day_89_dinner'),
            ],
            total: translate('recipes_page.day_89_total'),
          ),
          DayCard(
            recipeId: 'day_90',
            tried: _triedStates['day_90'] ?? false,
            onTriedChanged: () => _toggleTried('day_90'),

            dayTitle: translate('recipes_page.day_90'),
            meals: <String>[
              translate('recipes_page.day_90_breakfast'),
              translate('recipes_page.day_90_second_breakfast'),
              translate('recipes_page.day_90_lunch'),
              translate('recipes_page.day_90_snack'),
              translate('recipes_page.day_90_dinner'),
            ],
            total: translate('recipes_page.day_90_total'),
          ),
          DayCard(
            recipeId: 'day_91',
            tried: _triedStates['day_91'] ?? false,
            onTriedChanged: () => _toggleTried('day_91'),

            dayTitle: translate('recipes_page.day_91'),
            meals: <String>[
              translate('recipes_page.day_91_breakfast'),
              translate('recipes_page.day_91_second_breakfast'),
              translate('recipes_page.day_91_lunch'),
              translate('recipes_page.day_91_snack'),
              translate('recipes_page.day_91_dinner'),
            ],
            total: translate('recipes_page.day_91_total'),
          ),
          DayCard(
            recipeId: 'notes_week_13_title',
            tried: _triedStates['notes_week_13_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_13_title'),

            title: translate('recipes_page.notes_week_13_title'),
            meals: <String>[
              translate('recipes_page.notes_week_13_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_92',
            tried: _triedStates['day_92'] ?? false,
            onTriedChanged: () => _toggleTried('day_92'),

            title: translate('recipes_page.week_14'),
            dayTitle: translate('recipes_page.day_92'),
            meals: <String>[
              translate('recipes_page.day_92_breakfast'),
              translate('recipes_page.day_92_second_breakfast'),
              translate('recipes_page.day_92_lunch'),
              translate('recipes_page.day_92_snack'),
              translate('recipes_page.day_92_dinner'),
            ],
            total: translate('recipes_page.day_92_total'),
          ),
          DayCard(
            recipeId: 'day_93',
            tried: _triedStates['day_93'] ?? false,
            onTriedChanged: () => _toggleTried('day_93'),

            dayTitle: translate('recipes_page.day_93'),
            meals: <String>[
              translate('recipes_page.day_93_diet'),
            ],
            total: translate('recipes_page.day_93_total'),
          ),
          DayCard(
            recipeId: 'day_94',
            tried: _triedStates['day_94'] ?? false,
            onTriedChanged: () => _toggleTried('day_94'),

            dayTitle: translate('recipes_page.day_94'),
            meals: <String>[
              translate('recipes_page.day_94_breakfast'),
              translate('recipes_page.day_94_second_breakfast'),
              translate('recipes_page.day_94_lunch'),
              translate('recipes_page.day_94_snack'),
              translate('recipes_page.day_94_dinner'),
            ],
            total: translate('recipes_page.day_94_total'),
          ),
          DayCard(
            recipeId: 'day_95',
            tried: _triedStates['day_95'] ?? false,
            onTriedChanged: () => _toggleTried('day_95'),

            dayTitle: translate('recipes_page.day_95'),
            meals: <String>[
              translate('recipes_page.day_95_breakfast'),
              translate('recipes_page.day_95_second_breakfast'),
              translate('recipes_page.day_95_lunch'),
              translate('recipes_page.day_95_snack'),
              translate('recipes_page.day_95_dinner'),
            ],
            total: translate('recipes_page.day_95_total'),
          ),
          DayCard(
            recipeId: 'day_96',
            tried: _triedStates['day_96'] ?? false,
            onTriedChanged: () => _toggleTried('day_96'),

            dayTitle: translate('recipes_page.day_96'),
            meals: <String>[
              translate('recipes_page.day_96_breakfast'),
              translate('recipes_page.day_96_lunch'),
              translate('recipes_page.day_96_snack'),
              translate('recipes_page.day_96_dinner'),
            ],
            total: translate('recipes_page.day_96_total'),
          ),
          DayCard(
            recipeId: 'day_97',
            tried: _triedStates['day_97'] ?? false,
            onTriedChanged: () => _toggleTried('day_97'),

            dayTitle: translate('recipes_page.day_97'),
            meals: <String>[
              translate('recipes_page.day_97_breakfast'),
              translate('recipes_page.day_97_lunch'),
              translate('recipes_page.day_97_snack'),
              translate('recipes_page.day_97_dinner'),
            ],
            total: translate('recipes_page.day_97_total'),
          ),
          DayCard(
            recipeId: 'day_98',
            tried: _triedStates['day_98'] ?? false,
            onTriedChanged: () => _toggleTried('day_98'),

            dayTitle: translate('recipes_page.day_98'),
            meals: <String>[
              translate('recipes_page.day_98_breakfast'),
              translate('recipes_page.day_98_second_breakfast'),
              translate('recipes_page.day_98_lunch'),
              translate('recipes_page.day_98_snack'),
              translate('recipes_page.day_98_dinner'),
            ],
            total: translate('recipes_page.day_98_total'),
          ),
          DayCard(
            recipeId: 'notes_week_14_title',
            tried: _triedStates['notes_week_14_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_14_title'),

            title: translate('recipes_page.notes_week_14_title'),
            meals: <String>[
              translate('recipes_page.notes_week_14_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_99',
            tried: _triedStates['day_99'] ?? false,
            onTriedChanged: () => _toggleTried('day_99'),

            title: translate('recipes_page.week_15'),
            dayTitle: translate('recipes_page.day_99'),
            meals: <String>[
              translate('recipes_page.day_99_breakfast'),
              translate('recipes_page.day_99_second_breakfast'),
              translate('recipes_page.day_99_lunch'),
              translate('recipes_page.day_99_snack'),
              translate('recipes_page.day_99_small_snack'),
            ],
            total: translate('recipes_page.day_99_total'),
          ),
          DayCard(
            recipeId: 'day_100',
            tried: _triedStates['day_100'] ?? false,
            onTriedChanged: () => _toggleTried('day_100'),

            dayTitle: translate('recipes_page.day_100'),
            meals: <String>[
              translate('recipes_page.day_100_breakfast'),
              translate('recipes_page.day_100_second_breakfast'),
              translate('recipes_page.day_100_lunch'),
              translate('recipes_page.day_100_snack'),
              translate('recipes_page.day_100_dinner'),
            ],
            total: translate('recipes_page.day_100_total'),
          ),
          DayCard(
            recipeId: 'day_101',
            tried: _triedStates['day_101'] ?? false,
            onTriedChanged: () => _toggleTried('day_101'),

            dayTitle: translate('recipes_page.day_101'),
            meals: <String>[
              translate('recipes_page.day_101_breakfast'),
              translate('recipes_page.day_101_second_breakfast'),
              translate('recipes_page.day_101_lunch'),
              translate('recipes_page.day_101_snack'),
              translate('recipes_page.day_101_dinner'),
            ],
            total: translate('recipes_page.day_101_total'),
          ),
          DayCard(
            recipeId: 'day_102',
            tried: _triedStates['day_102'] ?? false,
            onTriedChanged: () => _toggleTried('day_102'),

            dayTitle: translate('recipes_page.day_102'),
            meals: <String>[
              translate('recipes_page.day_102_diet'),
            ],
            total: translate('recipes_page.day_102_total'),
          ),
          DayCard(
            recipeId: 'day_103',
            tried: _triedStates['day_103'] ?? false,
            onTriedChanged: () => _toggleTried('day_103'),

            dayTitle: translate('recipes_page.day_103'),
            meals: <String>[
              translate('recipes_page.day_103_breakfast'),
              translate('recipes_page.day_103_lunch'),
              translate('recipes_page.day_103_snack'),
              translate('recipes_page.day_103_dinner'),
            ],
            total: translate('recipes_page.day_103_total'),
          ),
          DayCard(
            recipeId: 'day_104',
            tried: _triedStates['day_104'] ?? false,
            onTriedChanged: () => _toggleTried('day_104'),

            dayTitle: translate('recipes_page.day_104'),
            meals: <String>[
              translate('recipes_page.day_104_breakfast'),
              translate('recipes_page.day_104_lunch'),
              translate('recipes_page.day_104_snack'),
              translate('recipes_page.day_104_dinner'),
            ],
            total: translate('recipes_page.day_104_total'),
          ),
          DayCard(
            recipeId: 'day_105',
            tried: _triedStates['day_105'] ?? false,
            onTriedChanged: () => _toggleTried('day_105'),

            dayTitle: translate('recipes_page.day_105'),
            meals: <String>[
              translate('recipes_page.day_105_breakfast'),
              translate('recipes_page.day_105_second_breakfast'),
              translate('recipes_page.day_105_lunch'),
              translate('recipes_page.day_105_snack'),
              translate('recipes_page.day_105_dinner'),
            ],
            total: translate('recipes_page.day_105_total'),
          ),
          DayCard(
            recipeId: 'notes_week_15_title',
            tried: _triedStates['notes_week_15_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_15_title'),

            title: translate('recipes_page.notes_week_15_title'),
            meals: <String>[
              translate('recipes_page.notes_week_15_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_106',
            tried: _triedStates['day_106'] ?? false,
            onTriedChanged: () => _toggleTried('day_106'),

            title: translate('recipes_page.week_16'),
            dayTitle: translate('recipes_page.day_106'),
            meals: <String>[
              translate('recipes_page.day_106_breakfast'),
              translate('recipes_page.day_106_second_breakfast'),
              translate('recipes_page.day_106_lunch'),
              translate('recipes_page.day_106_snack'),
              translate('recipes_page.day_106_small_snack'),
              translate('recipes_page.day_106_dinner'),
            ],
            total: translate('recipes_page.day_106_total'),
          ),
          DayCard(
            recipeId: 'day_107',
            tried: _triedStates['day_107'] ?? false,
            onTriedChanged: () => _toggleTried('day_107'),

            dayTitle: translate('recipes_page.day_107'),
            meals: <String>[
              translate('recipes_page.day_107_breakfast'),
              translate('recipes_page.day_107_second_breakfast'),
              translate('recipes_page.day_107_lunch'),
              translate('recipes_page.day_107_snack'),
              translate('recipes_page.day_107_dinner'),
            ],
            total: translate('recipes_page.day_107_total'),
          ),
          DayCard(
            recipeId: 'day_108',
            tried: _triedStates['day_108'] ?? false,
            onTriedChanged: () => _toggleTried('day_108'),

            dayTitle: translate('recipes_page.day_108'),
            meals: <String>[
              translate('recipes_page.day_108_diet'),
            ],
            total: translate('recipes_page.day_108_total'),
          ),
          DayCard(
            recipeId: 'day_109',
            tried: _triedStates['day_109'] ?? false,
            onTriedChanged: () => _toggleTried('day_109'),

            dayTitle: translate('recipes_page.day_109'),
            meals: <String>[
              translate('recipes_page.day_109_breakfast'),
              translate('recipes_page.day_109_second_breakfast'),
              translate('recipes_page.day_109_lunch'),
              translate('recipes_page.day_109_snack'),
              translate('recipes_page.day_109_dinner'),
            ],
            total: translate('recipes_page.day_109_total'),
          ),
          DayCard(
            recipeId: 'day_110',
            tried: _triedStates['day_110'] ?? false,
            onTriedChanged: () => _toggleTried('day_110'),

            dayTitle: translate('recipes_page.day_110'),
            meals: <String>[
              translate('recipes_page.day_110_breakfast'),
              translate('recipes_page.day_110_lunch'),
              translate('recipes_page.day_110_snack'),
              translate('recipes_page.day_110_dinner'),
            ],
            total: translate('recipes_page.day_110_total'),
          ),
          DayCard(
            recipeId: 'day_111',
            tried: _triedStates['day_111'] ?? false,
            onTriedChanged: () => _toggleTried('day_111'),

            dayTitle: translate('recipes_page.day_111'),
            meals: <String>[
              translate('recipes_page.day_111_breakfast'),
              translate('recipes_page.day_111_lunch'),
              translate('recipes_page.day_111_snack'),
              translate('recipes_page.day_111_dinner'),
            ],
            total: translate('recipes_page.day_111_total'),
          ),
          DayCard(
            recipeId: 'day_112',
            tried: _triedStates['day_112'] ?? false,
            onTriedChanged: () => _toggleTried('day_112'),

            dayTitle: translate('recipes_page.day_112'),
            meals: <String>[
              translate('recipes_page.day_112_breakfast'),
              translate('recipes_page.day_112_second_breakfast'),
              translate('recipes_page.day_112_lunch'),
              translate('recipes_page.day_112_snack'),
              translate('recipes_page.day_112_dinner'),
            ],
            total: translate('recipes_page.day_112_total'),
          ),
          DayCard(
            recipeId: 'notes_week_16_title',
            tried: _triedStates['notes_week_16_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_16_title'),

            title: translate('recipes_page.notes_week_16_title'),
            meals: <String>[
              translate('recipes_page.notes_week_16_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_113',
            tried: _triedStates['day_113'] ?? false,
            onTriedChanged: () => _toggleTried('day_113'),

            title: translate('recipes_page.week_17'),
            dayTitle: translate('recipes_page.day_113'),
            meals: <String>[
              translate('recipes_page.day_113_breakfast'),
              translate('recipes_page.day_113_second_breakfast'),
              translate('recipes_page.day_113_lunch'),
              translate('recipes_page.day_113_snack'),
              translate('recipes_page.day_113_dinner'),
            ],
            total: translate('recipes_page.day_113_total'),
          ),
          DayCard(
            recipeId: 'day_114',
            tried: _triedStates['day_114'] ?? false,
            onTriedChanged: () => _toggleTried('day_114'),

            dayTitle: translate('recipes_page.day_114'),
            meals: <String>[
              translate('recipes_page.day_114_breakfast'),
              translate('recipes_page.day_114_second_breakfast'),
              translate('recipes_page.day_114_lunch'),
              translate('recipes_page.day_114_snack'),
              translate('recipes_page.day_114_dinner'),
            ],
            total: translate('recipes_page.day_114_total'),
          ),
          DayCard(
            recipeId: 'day_115',
            tried: _triedStates['day_115'] ?? false,
            onTriedChanged: () => _toggleTried('day_115'),

            dayTitle: translate('recipes_page.day_115'),
            meals: <String>[
              translate('recipes_page.day_115_diet'),
            ],
            total: translate('recipes_page.day_115_total'),
          ),
          DayCard(
            recipeId: 'day_116',
            tried: _triedStates['day_116'] ?? false,
            onTriedChanged: () => _toggleTried('day_116'),

            dayTitle: translate('recipes_page.day_116'),
            meals: <String>[
              translate('recipes_page.day_116_breakfast'),
              translate('recipes_page.day_116_second_breakfast'),
              translate('recipes_page.day_116_lunch'),
              translate('recipes_page.day_116_snack'),
              translate('recipes_page.day_116_dinner'),
            ],
            total: translate('recipes_page.day_116_total'),
          ),
          DayCard(
            recipeId: 'day_117',
            tried: _triedStates['day_117'] ?? false,
            onTriedChanged: () => _toggleTried('day_117'),

            dayTitle: translate('recipes_page.day_117'),
            meals: <String>[
              translate('recipes_page.day_117_breakfast'),
              translate('recipes_page.day_117_second_breakfast'),
              translate('recipes_page.day_117_lunch'),
              translate('recipes_page.day_117_snack'),
              translate('recipes_page.day_117_dinner'),
            ],
            total: translate('recipes_page.day_117_total'),
          ),
          DayCard(
            recipeId: 'day_118',
            tried: _triedStates['day_118'] ?? false,
            onTriedChanged: () => _toggleTried('day_118'),

            dayTitle: translate('recipes_page.day_118'),
            meals: <String>[
              translate('recipes_page.day_118_breakfast'),
              translate('recipes_page.day_118_second_breakfast'),
              translate('recipes_page.day_118_lunch'),
              translate('recipes_page.day_118_snack'),
              translate('recipes_page.day_118_dinner'),
            ],
            total: translate('recipes_page.day_118_total'),
          ),
          DayCard(
            recipeId: 'day_119',
            tried: _triedStates['day_119'] ?? false,
            onTriedChanged: () => _toggleTried('day_119'),

            dayTitle: translate('recipes_page.day_119'),
            meals: <String>[
              translate('recipes_page.day_119_breakfast'),
              translate('recipes_page.day_119_second_breakfast'),
              translate('recipes_page.day_119_lunch'),
              translate('recipes_page.day_119_snack'),
              translate('recipes_page.day_119_dinner'),
            ],
            total: translate('recipes_page.day_119_total'),
          ),
          DayCard(
            recipeId: 'notes_week_17_title',
            tried: _triedStates['notes_week_17_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_17_title'),

            title: translate('recipes_page.notes_week_17_title'),
            meals: <String>[
              translate('recipes_page.notes_week_17_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_120',
            tried: _triedStates['day_120'] ?? false,
            onTriedChanged: () => _toggleTried('day_120'),

            title: translate('recipes_page.week_18'),
            dayTitle: translate('recipes_page.day_120'),
            meals: <String>[
              translate('recipes_page.day_120_breakfast'),
              translate('recipes_page.day_120_second_breakfast'),
              translate('recipes_page.day_120_lunch'),
              translate('recipes_page.day_120_snack'),
              translate('recipes_page.day_120_dinner'),
            ],
            total: translate('recipes_page.day_120_total'),
          ),
          DayCard(
            recipeId: 'day_121',
            tried: _triedStates['day_121'] ?? false,
            onTriedChanged: () => _toggleTried('day_121'),

            dayTitle: translate('recipes_page.day_121'),
            meals: <String>[
              translate('recipes_page.day_121_breakfast'),
              translate('recipes_page.day_121_second_breakfast'),
              translate('recipes_page.day_121_lunch'),
              translate('recipes_page.day_121_snack'),
              translate('recipes_page.day_121_dinner'),
            ],
            total: translate('recipes_page.day_121_total'),
          ),
          DayCard(
            recipeId: 'day_122',
            tried: _triedStates['day_122'] ?? false,
            onTriedChanged: () => _toggleTried('day_122'),

            dayTitle: translate('recipes_page.day_122'),
            meals: <String>[
              translate('recipes_page.day_122_diet'),
            ],
            total: translate('recipes_page.day_122_total'),
          ),
          DayCard(
            recipeId: 'day_123',
            tried: _triedStates['day_123'] ?? false,
            onTriedChanged: () => _toggleTried('day_123'),

            dayTitle: translate('recipes_page.day_123'),
            meals: <String>[
              translate('recipes_page.day_123_breakfast'),
              translate('recipes_page.day_123_second_breakfast'),
              translate('recipes_page.day_123_lunch'),
              translate('recipes_page.day_123_snack'),
              translate('recipes_page.day_123_dinner'),
            ],
            total: translate('recipes_page.day_123_total'),
          ),
          DayCard(
            recipeId: 'day_124',
            tried: _triedStates['day_124'] ?? false,
            onTriedChanged: () => _toggleTried('day_124'),

            dayTitle: translate('recipes_page.day_124'),
            meals: <String>[
              translate('recipes_page.day_124_breakfast'),
              translate('recipes_page.day_124_second_breakfast'),
              translate('recipes_page.day_124_lunch'),
              translate('recipes_page.day_124_snack'),
              translate('recipes_page.day_124_dinner'),
            ],
            total: translate('recipes_page.day_124_total'),
          ),
          DayCard(
            recipeId: 'day_125',
            tried: _triedStates['day_125'] ?? false,
            onTriedChanged: () => _toggleTried('day_125'),

            dayTitle: translate('recipes_page.day_125'),
            meals: <String>[
              translate('recipes_page.day_125_breakfast'),
            ],
            total: translate('recipes_page.day_125_total'),
          ),
          DayCard(
            recipeId: 'day_126',
            tried: _triedStates['day_126'] ?? false,
            onTriedChanged: () => _toggleTried('day_126'),

            dayTitle: translate('recipes_page.day_126'),
            meals: <String>[
              translate('recipes_page.day_126_breakfast'),
              translate('recipes_page.day_126_second_breakfast'),
              translate('recipes_page.day_126_lunch'),
              translate('recipes_page.day_126_snack'),
              translate('recipes_page.day_126_dinner'),
            ],
            total: translate('recipes_page.day_126_total'),
          ),
          DayCard(
            recipeId: 'notes_week_18_title',
            tried: _triedStates['notes_week_18_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_18_title'),

            title: translate('recipes_page.notes_week_18_title'),
            meals: <String>[
              translate('recipes_page.notes_week_18_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_127',
            tried: _triedStates['day_127'] ?? false,
            onTriedChanged: () => _toggleTried('day_127'),

            title: translate('recipes_page.week_19'),
            dayTitle: translate('recipes_page.day_127'),
            meals: <String>[
              translate('recipes_page.day_127_breakfast'),
              translate('recipes_page.day_127_second_breakfast'),
              translate('recipes_page.day_127_lunch'),
              translate('recipes_page.day_127_snack'),
              translate('recipes_page.day_127_small_snack'),
            ],
            total: translate('recipes_page.day_127_total'),
          ),
          DayCard(
            recipeId: 'day_128',
            tried: _triedStates['day_128'] ?? false,
            onTriedChanged: () => _toggleTried('day_128'),

            dayTitle: translate('recipes_page.day_128'),
            meals: <String>[
              translate('recipes_page.day_128_breakfast'),
              translate('recipes_page.day_128_second_breakfast'),
              translate('recipes_page.day_128_lunch'),
              translate('recipes_page.day_128_snack'),
              translate('recipes_page.day_128_dinner'),
            ],
            total: translate('recipes_page.day_128_total'),
          ),
          DayCard(
            recipeId: 'day_129',
            tried: _triedStates['day_129'] ?? false,
            onTriedChanged: () => _toggleTried('day_129'),

            dayTitle: translate('recipes_page.day_129'),
            meals: <String>[
              translate('recipes_page.day_129_breakfast'),
              translate('recipes_page.day_129_second_breakfast'),
              translate('recipes_page.day_129_lunch'),
              translate('recipes_page.day_129_snack'),
              translate('recipes_page.day_129_dinner'),
            ],
            total: translate('recipes_page.day_129_total'),
          ),
          DayCard(
            recipeId: 'day_130',
            tried: _triedStates['day_130'] ?? false,
            onTriedChanged: () => _toggleTried('day_130'),

            dayTitle: translate('recipes_page.day_130'),
            meals: <String>[
              translate('recipes_page.day_130_breakfast'),
              translate('recipes_page.day_130_second_breakfast'),
              translate('recipes_page.day_130_lunch'),
              translate('recipes_page.day_130_snack'),
              translate('recipes_page.day_130_dinner'),
            ],
            total: translate('recipes_page.day_130_total'),
          ),
          DayCard(
            recipeId: 'day_131',
            tried: _triedStates['day_131'] ?? false,
            onTriedChanged: () => _toggleTried('day_131'),

            dayTitle: translate('recipes_page.day_131'),
            meals: <String>[
              translate('recipes_page.day_131_breakfast'),
              translate('recipes_page.day_131_lunch'),
              translate('recipes_page.day_131_snack'),
              translate('recipes_page.day_131_dinner'),
            ],
            total: translate('recipes_page.day_131_total'),
          ),
          DayCard(
            recipeId: 'day_132',
            tried: _triedStates['day_132'] ?? false,
            onTriedChanged: () => _toggleTried('day_132'),

            dayTitle: translate('recipes_page.day_132'),
            meals: <String>[
              translate('recipes_page.day_132_breakfast'),
              translate('recipes_page.day_132_lunch'),
              translate('recipes_page.day_132_snack'),
              translate('recipes_page.day_132_dinner'),
            ],
            total: translate('recipes_page.day_132_total'),
          ),
          DayCard(
            recipeId: 'day_133',
            tried: _triedStates['day_133'] ?? false,
            onTriedChanged: () => _toggleTried('day_133'),

            dayTitle: translate('recipes_page.day_133'),
            meals: <String>[
              translate('recipes_page.day_133_breakfast'),
              translate('recipes_page.day_133_second_breakfast'),
              translate('recipes_page.day_133_lunch'),
              translate('recipes_page.day_133_snack'),
              translate('recipes_page.day_133_dinner'),
            ],
            total: translate('recipes_page.day_133_total'),
          ),
          DayCard(
            recipeId: 'notes_week_19_title',
            tried: _triedStates['notes_week_19_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_19_title'),

            title: translate('recipes_page.notes_week_19_title'),
            meals: <String>[
              translate('recipes_page.notes_week_19_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_134',
            tried: _triedStates['day_134'] ?? false,
            onTriedChanged: () => _toggleTried('day_134'),

            title: translate('recipes_page.week_20'),
            dayTitle: translate('recipes_page.day_134'),
            meals: <String>[
              translate('recipes_page.day_134_breakfast'),
              translate('recipes_page.day_134_second_breakfast'),
              translate('recipes_page.day_134_lunch'),
              translate('recipes_page.day_134_snack'),
              translate('recipes_page.day_134_small_snack'),
            ],
            total: translate('recipes_page.day_134_total'),
          ),
          DayCard(
            recipeId: 'day_135',
            tried: _triedStates['day_135'] ?? false,
            onTriedChanged: () => _toggleTried('day_135'),

            dayTitle: translate('recipes_page.day_135'),
            meals: <String>[
              translate('recipes_page.day_135_breakfast'),
              translate('recipes_page.day_135_second_breakfast'),
              translate('recipes_page.day_135_lunch'),
              translate('recipes_page.day_135_snack'),
              translate('recipes_page.day_135_dinner'),
            ],
            total: translate('recipes_page.day_135_total'),
          ),
          DayCard(
            recipeId: 'day_136',
            tried: _triedStates['day_136'] ?? false,
            onTriedChanged: () => _toggleTried('day_136'),

            dayTitle: translate('recipes_page.day_136'),
            meals: <String>[
              translate('recipes_page.day_136_diet'),
            ],
            total: translate('recipes_page.day_136_total'),
          ),
          DayCard(
            recipeId: 'day_137',
            tried: _triedStates['day_137'] ?? false,
            onTriedChanged: () => _toggleTried('day_137'),

            dayTitle: translate('recipes_page.day_137'),
            meals: <String>[
              translate('recipes_page.day_137_breakfast'),
              translate('recipes_page.day_137_second_breakfast'),
              translate('recipes_page.day_137_lunch'),
              translate('recipes_page.day_137_snack'),
              translate('recipes_page.day_137_dinner'),
            ],
            total: translate('recipes_page.day_137_total'),
          ),
          DayCard(
            recipeId: 'day_138',
            tried: _triedStates['day_138'] ?? false,
            onTriedChanged: () => _toggleTried('day_138'),

            dayTitle: translate('recipes_page.day_138'),
            meals: <String>[
              translate('recipes_page.day_138_breakfast'),
              translate('recipes_page.day_138_second_breakfast'),
              translate('recipes_page.day_138_lunch'),
              translate('recipes_page.day_138_snack'),
              translate('recipes_page.day_138_dinner'),
            ],
            total: translate('recipes_page.day_138_total'),
          ),
          DayCard(
            recipeId: 'day_139',
            tried: _triedStates['day_139'] ?? false,
            onTriedChanged: () => _toggleTried('day_139'),

            dayTitle: translate('recipes_page.day_139'),
            meals: <String>[
              translate('recipes_page.day_139_breakfast'),
              translate('recipes_page.day_139_second_breakfast'),
              translate('recipes_page.day_139_lunch'),
              translate('recipes_page.day_139_snack'),
              translate('recipes_page.day_139_dinner'),
            ],
            total: translate('recipes_page.day_139_total'),
          ),
          DayCard(
            recipeId: 'day_140',
            tried: _triedStates['day_140'] ?? false,
            onTriedChanged: () => _toggleTried('day_140'),

            dayTitle: translate('recipes_page.day_140'),
            meals: <String>[
              translate('recipes_page.day_140_breakfast'),
              translate('recipes_page.day_140_second_breakfast'),
              translate('recipes_page.day_140_lunch'),
              translate('recipes_page.day_140_snack'),
              translate('recipes_page.day_140_dinner'),
            ],
            total: translate('recipes_page.day_140_total'),
          ),
          DayCard(
            recipeId: 'notes_week_20_title',
            tried: _triedStates['notes_week_20_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_20_title'),

            title: translate('recipes_page.notes_week_20_title'),
            meals: <String>[
              translate('recipes_page.notes_week_20_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_141',
            tried: _triedStates['day_141'] ?? false,
            onTriedChanged: () => _toggleTried('day_141'),

            title: translate('recipes_page.week_21'),
            dayTitle: translate('recipes_page.day_141'),
            meals: <String>[
              translate('recipes_page.day_141_breakfast'),
              translate('recipes_page.day_141_second_breakfast'),
              translate('recipes_page.day_141_lunch'),
              translate('recipes_page.day_141_snack'),
              translate('recipes_page.day_141_dinner'),
            ],
            total: translate('recipes_page.day_141_total'),
          ),
          DayCard(
            recipeId: 'day_142',
            tried: _triedStates['day_142'] ?? false,
            onTriedChanged: () => _toggleTried('day_142'),

            dayTitle: translate('recipes_page.day_142'),
            meals: <String>[
              translate('recipes_page.day_142_breakfast'),
              translate('recipes_page.day_142_second_breakfast'),
              translate('recipes_page.day_142_lunch'),
              translate('recipes_page.day_142_snack'),
              translate('recipes_page.day_142_dinner'),
            ],
            total: translate('recipes_page.day_142_total'),
          ),
          DayCard(
            recipeId: 'day_143',
            tried: _triedStates['day_143'] ?? false,
            onTriedChanged: () => _toggleTried('day_143'),

            dayTitle: translate('recipes_page.day_143'),
            meals: <String>[
              translate('recipes_page.day_143_diet'),
            ],
            total: translate('recipes_page.day_143_total'),
          ),
          DayCard(
            recipeId: 'day_144',
            tried: _triedStates['day_144'] ?? false,
            onTriedChanged: () => _toggleTried('day_144'),

            dayTitle: translate('recipes_page.day_144'),
            meals: <String>[
              translate('recipes_page.day_144_breakfast'),
              translate('recipes_page.day_144_second_breakfast'),
              translate('recipes_page.day_144_lunch'),
              translate('recipes_page.day_144_snack'),
              translate('recipes_page.day_144_dinner'),
            ],
            total: translate('recipes_page.day_144_total'),
          ),
          DayCard(
            recipeId: 'day_145',
            tried: _triedStates['day_145'] ?? false,
            onTriedChanged: () => _toggleTried('day_145'),

            dayTitle: translate('recipes_page.day_145'),
            meals: <String>[
              translate('recipes_page.day_145_breakfast'),
              translate('recipes_page.day_145_second_breakfast'),
              translate('recipes_page.day_145_lunch'),
              translate('recipes_page.day_145_snack'),
              translate('recipes_page.day_145_dinner'),
            ],
            total: translate('recipes_page.day_145_total'),
          ),
          DayCard(
            recipeId: 'day_146',
            tried: _triedStates['day_146'] ?? false,
            onTriedChanged: () => _toggleTried('day_146'),

            dayTitle: translate('recipes_page.day_146'),
            meals: <String>[
              translate('recipes_page.day_146_breakfast'),
              translate('recipes_page.day_146_second_breakfast'),
              translate('recipes_page.day_146_lunch'),
              translate('recipes_page.day_146_snack'),
              translate('recipes_page.day_146_dinner'),
            ],
            total: translate('recipes_page.day_146_total'),
          ),
          DayCard(
            recipeId: 'day_147',
            tried: _triedStates['day_147'] ?? false,
            onTriedChanged: () => _toggleTried('day_147'),

            dayTitle: translate('recipes_page.day_147'),
            meals: <String>[
              translate('recipes_page.day_147_breakfast'),
              translate('recipes_page.day_147_lunch'),
              translate('recipes_page.day_147_snack'),
              translate('recipes_page.day_147_small_snack'),
              translate('recipes_page.day_147_dinner'),
            ],
            total: translate('recipes_page.day_147_total'),
          ),
          DayCard(
            recipeId: 'notes_week_21_title',
            tried: _triedStates['notes_week_21_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_21_title'),

            title: translate('recipes_page.notes_week_21_title'),
            meals: <String>[
              translate('recipes_page.notes_week_21_sweets'),
            ],
          ),
          const SizedBox(height: 16),
          DayCard(
            recipeId: 'day_148',
            tried: _triedStates['day_148'] ?? false,
            onTriedChanged: () => _toggleTried('day_148'),

            title: translate('recipes_page.week_22'),
            dayTitle: translate('recipes_page.day_148'),
            meals: <String>[
              translate('recipes_page.day_148_breakfast'),
              translate('recipes_page.day_148_second_breakfast'),
              translate('recipes_page.day_148_snack'),
              translate('recipes_page.day_148_dinner'),
            ],
            total: translate('recipes_page.day_148_total'),
          ),
          DayCard(
            recipeId: 'day_149',
            tried: _triedStates['day_149'] ?? false,
            onTriedChanged: () => _toggleTried('day_149'),

            dayTitle: translate('recipes_page.day_149'),
            meals: <String>[
              translate('recipes_page.day_149_breakfast'),
              translate('recipes_page.day_149_second_breakfast'),
              translate('recipes_page.day_149_lunch'),
              translate('recipes_page.day_149_snack'),
              translate('recipes_page.day_149_dinner'),
            ],
            total: translate('recipes_page.day_149_total'),
          ),
          DayCard(
            recipeId: 'day_150',
            tried: _triedStates['day_150'] ?? false,
            onTriedChanged: () => _toggleTried('day_150'),

            dayTitle: translate('recipes_page.day_150'),
            meals: <String>[
              translate('recipes_page.day_150_meals'),
            ],
            total: translate('recipes_page.day_150_total'),
          ),
          DayCard(
            recipeId: 'day_151',
            tried: _triedStates['day_151'] ?? false,
            onTriedChanged: () => _toggleTried('day_151'),

            dayTitle: translate('recipes_page.day_151'),
            meals: <String>[
              translate('recipes_page.day_151_breakfast'),
              translate('recipes_page.day_151_second_breakfast'),
              translate('recipes_page.day_151_lunch'),
              translate('recipes_page.day_151_snack'),
              translate('recipes_page.day_151_dinner'),
            ],
            total: translate('recipes_page.day_151_total'),
          ),
          DayCard(
            recipeId: 'day_152',
            tried: _triedStates['day_152'] ?? false,
            onTriedChanged: () => _toggleTried('day_152'),

            dayTitle: translate('recipes_page.day_152'),
            meals: <String>[
              translate('recipes_page.day_152_breakfast'),
              translate('recipes_page.day_152_second_breakfast'),
              translate('recipes_page.day_152_lunch'),
              translate('recipes_page.day_152_snack'),
              translate('recipes_page.day_152_dinner'),
            ],
            total: translate('recipes_page.day_152_total'),
          ),
          DayCard(
            recipeId: 'day_153',
            tried: _triedStates['day_153'] ?? false,
            onTriedChanged: () => _toggleTried('day_153'),

            dayTitle: translate('recipes_page.day_153'),
            meals: <String>[
              translate('recipes_page.day_153_breakfast'),
              translate('recipes_page.day_153_second_breakfast'),
              translate('recipes_page.day_153_lunch'),
              translate('recipes_page.day_153_snack'),
              translate('recipes_page.day_153_dinner'),
            ],
            total: translate('recipes_page.day_153_total'),
          ),
          DayCard(
            recipeId: 'day_154',
            tried: _triedStates['day_154'] ?? false,
            onTriedChanged: () => _toggleTried('day_154'),

            dayTitle: translate('recipes_page.day_154'),
            meals: <String>[
              translate('recipes_page.day_154_breakfast'),
              translate('recipes_page.day_154_second_breakfast'),
              translate('recipes_page.day_154_lunch'),
              translate('recipes_page.day_154_snack'),
              translate('recipes_page.day_154_dinner'),
            ],
            total: translate('recipes_page.day_154_total'),
          ),
          DayCard(
            recipeId: 'notes_week_22_title',
            tried: _triedStates['notes_week_22_title'] ?? false,
            onTriedChanged: () => _toggleTried('notes_week_22_title'),

            title: translate('recipes_page.notes_week_22_title'),
            meals: <String>[
              translate('recipes_page.notes_week_22_additions'),
              translate('recipes_page.notes_week_22_sweets'),
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
