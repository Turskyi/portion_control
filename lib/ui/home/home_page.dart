import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/extensions/date_time_extension.dart';
import 'package:portion_control/extensions/list_extension.dart';
import 'package:portion_control/res/constants/date_constants.dart';
import 'package:portion_control/ui/home/body_weight_line_chart.dart';
import 'package:portion_control/ui/home/healthy_weight_recommendations.dart';
import 'package:portion_control/ui/home/input_row.dart';
import 'package:portion_control/ui/home/submit_edit_body_weight_button.dart';
import 'package:portion_control/ui/home/submit_edit_details_button.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _dateOfBirthTextEditingController =
      TextEditingController();

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
          final ThemeData themeData = Theme.of(context);
          final TextTheme textTheme = themeData.textTheme;
          final double? bodyLargeFontSize = textTheme.bodyLarge?.fontSize;
          final Color dividerColor = themeData.dividerColor;
          final TextStyle? titleMedium = textTheme.titleMedium;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16.0,
              MediaQuery.of(context).padding.top + 18,
              16.0,
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
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AnimatedSwitcher(
                        // Animation duration.
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          // Use a fade and slide transition.
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                // Slide in from below.
                                begin: const Offset(0.0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: state is DetailsSubmittedState
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12.0,
                                      0,
                                      4,
                                      1,
                                    ),
                                    child: Text(
                                      'Gender',
                                      style: TextStyle(
                                        fontSize: textTheme.bodySmall?.fontSize,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          // Key ensures the AnimatedSwitcher
                                          // detects a new widget.
                                          key: ValueKey<String>('$bodyWeight'),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: themeData
                                                  .colorScheme.onTertiary,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                gender.emoji,
                                                // Display the emoji here
                                                style: TextStyle(
                                                  fontSize: textTheme
                                                      .titleMedium?.fontSize,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                gender.displayName,
                                                style: TextStyle(
                                                  fontSize: bodyLargeFontSize,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 17.0),
                                child: DropdownButtonFormField<Gender>(
                                  key: ValueKey<String>('$bodyWeight'),
                                  value: state.gender,
                                  decoration: InputDecoration(
                                    labelText: 'Gender',
                                    filled: true,
                                    fillColor: themeData.colorScheme.secondary
                                        .withOpacity(0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: dividerColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: dividerColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: themeData.primaryColor,
                                      ),
                                    ),
                                  ),
                                  items: Gender.values
                                      .map(
                                        (Gender gender) =>
                                            DropdownMenuItem<Gender>(
                                          value: gender,
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                gender.emoji,
                                                // Display the emoji here
                                                style: TextStyle(
                                                  fontSize:
                                                      titleMedium?.fontSize,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                gender.displayName,
                                                style: TextStyle(
                                                  fontSize:
                                                      titleMedium?.fontSize,
                                                  fontWeight: FontWeight.w600,
                                                  color: textTheme
                                                      .bodyLarge?.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (Gender? value) {
                                    if (value != null) {
                                      context
                                          .read<HomeBloc>()
                                          .add(UpdateGender(value));
                                    }
                                  },
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: InputRow(
                        label: 'Date of Birth',
                        controller: _dateOfBirthTextEditingController
                          ..text = dateOfBirth,
                        readOnly: true,
                        value:
                            state is DetailsSubmittedState ? dateOfBirth : null,
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: dateOfBirth.isNotEmpty
                                ? state.dateOfBirth
                                : DateTime(1987, 1, 13),
                            firstDate: maxAllowedBirthDate,
                            lastDate: minAllowedBirthDate,
                          );

                          if (context.mounted && pickedDate != null) {
                            _dateOfBirthTextEditingController.text =
                                pickedDate.toIso8601Date() ?? '';
                            context
                                .read<HomeBloc>()
                                .add(UpdateDateOfBirth(pickedDate));
                          }
                        },
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
                const SizedBox(height: 16),
                if (state is BodyWeightSubmittedState && state.foodWeight == 0)
                  // TODO: replace placeholder with the Text, concisely
                  //  explaining how are we going to calculate
                  //  "portion control". Be concise. Inform that we do not care
                  // what user eat, but we need to know how his food of choice
                  // impacts his body weight. For that reason the first day
                  // user does not have a "portion control", if user will enter
                  // every single gram of what he consumes in the input bellow
                  // the next day we will see a trend where the weight goes and
                  // if it will go up, we will fix that amount and, af
                  const Placeholder(fallbackHeight: 50),
                if (state is BodyWeightSubmittedState)
                  // Food Weight Input Placeholder
                  const Row(
                    children: <Widget>[
                      Expanded(
                        child: Placeholder(fallbackHeight: 50),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: Text('g'),
                      ),
                    ],
                  ),
                if (state.bodyWeightEntries.isNotEmpty)
                  ElevatedButton(
                    onPressed: state.foodWeight == 0
                        ? null
                        : () => context
                            .read<HomeBloc>()
                            .add(const SubmitFoodWeight()),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Submit Food Weight'),
                  ),
                if (state.bodyWeightEntries.isNotEmpty && state.height > 0)
                  // Recommendation for food consumption Section Placeholder
                  const Placeholder(
                    fallbackHeight: 100,
                    fallbackWidth: double.infinity,
                  ),
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
    super.dispose();
  }
}

void _homeStateListener(BuildContext context, HomeState state) {
  if (state is BodyWeightSubmittedState) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Body weight submitted: ${state.bodyWeight} kg',
        ),
      ),
    );
  }
}
