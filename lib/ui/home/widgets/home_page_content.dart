import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/extensions/list_extension.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/home/widgets/body_weight_line_chart.dart';
import 'package:portion_control/ui/home/widgets/food_entries_column.dart';
import 'package:portion_control/ui/home/widgets/healthy_weight_recommendations.dart';
import 'package:portion_control/ui/home/widgets/portion_control_message.dart';
import 'package:portion_control/ui/home/widgets/submit_edit_body_weight_button.dart';
import 'package:portion_control/ui/home/widgets/user_details_widget.dart';
import 'package:portion_control/ui/widgets/input_row.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final ThemeData themeData = Theme.of(context);
        final TextTheme textTheme = themeData.textTheme;
        final TextStyle? titleMedium = textTheme.titleMedium;
        final double weight = state.bodyWeight;
        final double height = state.height;
        final List<FoodWeight> foodEntries = state.foodEntries;
        return Column(
          spacing: 16.0,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              // Body Weight Input.
              InputRow(
                label: 'Body weight',
                unit: 'kg',
                initialValue:
                    '${weight > constants.minBodyWeight ? weight : ''}',
                value: state is BodyWeightSubmittedState ? '$weight' : null,
                onChanged: (String value) {
                  context.read<HomeBloc>().add(UpdateBodyWeight(value));
                },
              ),
            if (state is DetailsSubmittedState)
              const SubmitEditBodyWeightButton(),
            if (state.bodyWeightEntries.length > 1)
              // Line Chart of Body Weight trends for the last two weeks.
              BodyWeightLineChart(
                bodyWeightEntries: state.bodyWeightEntries
                    .takeLast(DateTime.daysPerWeek * 2)
                    .toList(),
              ),
            if (state is BodyWeightSubmittedState)
              HealthyWeightRecommendations(height: height, weight: weight),
            if (state is BodyWeightSubmittedState)
              const PortionControlMessage(),
            if (state is BodyWeightSubmittedState)
              FoodEntriesColumn(foodEntries: foodEntries),
          ],
        );
      },
    );
  }
}
