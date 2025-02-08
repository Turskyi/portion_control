import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/extensions/date_time_extension.dart';
import 'package:portion_control/extensions/list_extension.dart';
import 'package:portion_control/res/constants/date_constants.dart';
import 'package:portion_control/ui/home/widgets/body_weight_line_chart.dart';
import 'package:portion_control/ui/home/widgets/food_weight_entry_row.dart';
import 'package:portion_control/ui/home/widgets/gender_selection_widget.dart';
import 'package:portion_control/ui/home/widgets/healthy_weight_recommendations.dart';
import 'package:portion_control/ui/home/widgets/input_row.dart';
import 'package:portion_control/ui/home/widgets/portion_control_message.dart';
import 'package:portion_control/ui/home/widgets/submit_edit_body_weight_button.dart';
import 'package:portion_control/ui/home/widgets/submit_edit_details_button.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _dateOfBirthTextEditingController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundScaffold(
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: _homeStateListener,
        builder: (BuildContext context, HomeState state) {
          final String dateOfBirth = state.dateOfBirth?.toIso8601Date() ?? '';
          final Gender gender = state.gender;
          final double height = state.height;
          final double bodyWeight = state.bodyWeight;
          final List<FoodWeight> foodEntries = state.foodEntries;

          final ThemeData themeData = Theme.of(context);
          final TextTheme textTheme = themeData.textTheme;
          final TextStyle? titleMedium = textTheme.titleMedium;

          return SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              12.0,
              MediaQuery.of(context).padding.top + 18,
              12.0,
              80.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: <Widget>[
                Text(
                  state is BodyWeightSubmittedState
                      ? 'Your Details'
                      : 'Enter Your Details',
                  style: TextStyle(
                    fontSize: textTheme.titleLarge?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GenderSelectionWidget(
                  bodyWeight: bodyWeight,
                  gender: gender,
                  isDetailsSubmitted: state is DetailsSubmittedState,
                ),
                Row(
                  children: <Widget>[
                    if (gender.isMaleOrFemale)
                      Expanded(
                        child: InputRow(
                          label: 'Date of Birth',
                          controller: _dateOfBirthTextEditingController
                            ..text = dateOfBirth,
                          readOnly: true,
                          value: state is DetailsSubmittedState
                              ? dateOfBirth
                              : null,
                          onTap: () => _pickDate(
                            dateOfBirthText: dateOfBirth,
                            dateOfBirthDateTime: state.dateOfBirth,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InputRow(
                        label: 'Height',
                        unit: 'cm',
                        initialValue: '${height > 0 ? height : ''}',
                        isRequired: true,
                        value:
                            state is DetailsSubmittedState ? '$height' : null,
                        onChanged: (String value) {
                          context.read<HomeBloc>().add(UpdateHeight(value));
                        },
                      ),
                    ),
                  ],
                ),
                const SubmitEditDetailsButton(),
                const SizedBox(height: 4),
                if (state is DetailsSubmittedState)
                  Text(
                    '👉 Enter weight before your first meal.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: titleMedium?.fontSize,
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
                          isEditable: (state is FoodWeightUpdateState &&
                                  state.foodEntryId == entry.id)
                              ? true
                              : false,
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
                      // Input field for new food entry
                      FoodWeightEntryRow(
                        isEditable: true,
                        onSave: (String value) {
                          context.read<HomeBloc>().add(AddFoodEntry(value));
                        },
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
    _dateOfBirthTextEditingController.dispose();
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

  Future<void> _pickDate({
    required String dateOfBirthText,
    required DateTime? dateOfBirthDateTime,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dateOfBirthText.isNotEmpty
          ? dateOfBirthDateTime
          : DateTime(1987, 1, 13),
      firstDate: maxAllowedBirthDate,
      lastDate: minAllowedBirthDate,
    );

    if (mounted && pickedDate != null) {
      _dateOfBirthTextEditingController.text = pickedDate.toIso8601Date() ?? '';
      context.read<HomeBloc>().add(UpdateDateOfBirth(pickedDate));
    }
  }
}
