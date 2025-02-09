import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/extensions/list_extension.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/home/widgets/body_weight_line_chart.dart';
import 'package:portion_control/ui/home/widgets/food_weight_entry_row.dart';
import 'package:portion_control/ui/home/widgets/healthy_weight_recommendations.dart';
import 'package:portion_control/ui/home/widgets/portion_control_message.dart';
import 'package:portion_control/ui/home/widgets/submit_edit_body_weight_button.dart';
import 'package:portion_control/ui/home/widgets/user_details_widget.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:portion_control/ui/widgets/input_row.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundScaffold(
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: _homeStateListener,
        builder: (BuildContext context, HomeState state) {
          final double bodyWeight = state.bodyWeight;
          final List<FoodWeight> foodEntries = state.foodEntries;

          final ThemeData themeData = Theme.of(context);
          final TextTheme textTheme = themeData.textTheme;
          final TextStyle? titleMedium = textTheme.titleMedium;
          final double horizontalIndent = 12.0;

          return SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              horizontalIndent,
              MediaQuery.of(context).padding.top + 18,
              horizontalIndent,
              80.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.0,
              children: <Widget>[
                const UserDetailsWidget(),
                if (state.isWeightNotSubmitted)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      '👉 Enter weight before your first meal.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleMedium?.fontSize,
                      ),
                    ),
                  ),
                if (state is DetailsSubmittedState)
                  // Body Weight Input
                  InputRow(
                    label: 'Body weight',
                    unit: 'kg',
                    initialValue: '${bodyWeight > 0 ? bodyWeight : ''}',
                    value: state is BodyWeightSubmittedState
                        ? '$bodyWeight'
                        : null,
                    onChanged: (String value) {
                      context.read<HomeBloc>().add(UpdateBodyWeight(value));
                    },
                  ),
                if (state is DetailsSubmittedState)
                  const SubmitEditBodyWeightButton(),
                if (state.bodyWeightEntries.length > 1)
                  // Line Chart of Body Weight trends
                  BodyWeightLineChart(
                    bodyWeightEntries: state.bodyWeightEntries
                        .takeLast(DateTime.daysPerWeek * 2)
                        .toList(),
                  ),
                if (state is BodyWeightSubmittedState)
                  HealthyWeightRecommendations(
                    height: state.height,
                    weight: state.bodyWeight,
                  ),
                if (state is BodyWeightSubmittedState)
                  const PortionControlMessage(),
                if (state is BodyWeightSubmittedState) ...<Widget>[
                  Column(
                    spacing: 16,
                    children: <Widget>[
                      // Existing food entries.
                      ...foodEntries.map((FoodWeight entry) {
                        return FoodWeightEntryRow(
                          value: '${entry.weight}',
                          time: entry.time,
                          isEditable: state is FoodWeightUpdateState &&
                              state.foodEntryId == entry.id,
                          onEdit: () {
                            context
                                .read<HomeBloc>()
                                .add(EditFoodEntry(entry.id));
                          },
                          onDelete: () {
                            context
                                .read<HomeBloc>()
                                .add(DeleteFoodEntry(entry.id));
                          },
                          onSave: (String value) {
                            context.read<HomeBloc>().add(
                                  UpdateFoodWeight(
                                    foodEntryId: entry.id,
                                    foodWeight: value,
                                  ),
                                );
                          },
                        );
                      }),
                      if (state.totalConsumedToday <
                          constants.maxDailyFoodLimit)
                        // Input field for new food entry
                        FoodWeightEntryRow(
                          isEditable: true,
                          onSave: (String value) {
                            context.read<HomeBloc>().add(AddFoodEntry(value));
                          },
                        )
                      else
                        const Text(
                          'It seems like you’ve set a big challenge for '
                          'yourself today. We’re not sure what your plans are, '
                          'but we definitely suggest not overdoing it with '
                          'that amount of food. 😅',
                        ),
                    ],
                  ),
                  Text(
                    'Total consumed today: ${state.totalConsumedToday} g',
                    style: textTheme.titleMedium,
                  ),
                  if (state.totalConsumedToday < state.portionControl)
                    Text(
                      'You can eat '
                      '${state.portionControl - state.totalConsumedToday} g '
                      'more today',
                      style: textTheme.bodyMedium,
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _homeStateListener(BuildContext context, HomeState state) {
    if (state is BodyWeightSubmittedState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }
}
