import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/ui/home/input_row.dart';
import 'package:portion_control/ui/home/submit_edit_body_weight_button.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundScaffold(
      appBar: const BlurredAppBar(title: 'PortionControl'),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: _homeStateListener,
        builder: (BuildContext context, HomeState state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 80.0),
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Enter Your Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                // Text Field for Body Weight.
                InputRow(
                  label: 'Body Weight',
                  unit: 'kg',
                  initialValue: state.bodyWeight,
                  onChanged: (String value) {
                    context.read<HomeBloc>().add(UpdateBodyWeight(value));
                  },
                ),

                const SubmitEditBodyWeightButton(),

                // Line Chart of Body Weight trends Placeholder.
                const Placeholder(
                  fallbackHeight: 100,
                  fallbackWidth: double.infinity,
                ),

                const SizedBox(height: 16),
                // Text Field for Food Weight Placeholder.
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
                const SizedBox(height: 16),

                // Submit Food Weight Button.
                ElevatedButton(
                  onPressed: state.foodWeight.isEmpty
                      ? null
                      : () {
                          context
                              .read<HomeBloc>()
                              .add(const SubmitFoodWeight());
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Submit Food Weight'),
                ),

                // Recommendation Section Placeholder
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
