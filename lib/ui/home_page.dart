import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/ui/input_row.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:portion_control/ui/widgets/responsive_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundScaffold(
      appBar: const BlurredAppBar(
        title: Text('PortionControl'),
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (BuildContext context, HomeState state) {
          if (state is BodyWeightSubmittedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Body weight submitted: ${state.bodyWeight} kg',
                ),
              ),
            );
          }
        },
        builder: (BuildContext context, HomeState state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Enter Your Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Text Field for Body Weight.
                InputRow(
                  state: state,
                  label: 'Body Weight',
                  unit: 'kg',
                  initialValue:
                      state is BodyWeightSubmittedState ? state.bodyWeight : '',
                  onChanged: (String value) {
                    context.read<HomeBloc>().add(UpdateBodyWeight(value));
                  },
                ),
                const SizedBox(height: 16),
                // Submit Body Weight Button
                ResponsiveButton(
                  label: state is BodyWeightSubmittedState
                      ? 'Edit Body Weight'
                      : 'Submit Body Weight',
                  onPressed: state.bodyWeight.isEmpty
                      ? null
                      : state is BodyWeightSubmittedState
                          ? () => context
                              .read<HomeBloc>()
                              .add(const EditBodyWeight())
                          : () => context
                              .read<HomeBloc>()
                              .add(const SubmitBodyWeight()),
                ),
                const SizedBox(height: 32),
                // Text Field for Food Weight Placeholder.
                const Row(
                  children: <Widget>[
                    Expanded(
                      child: Placeholder(
                        fallbackHeight: 50,
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text('g'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Food Weight Button
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
                const SizedBox(height: 16),

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
