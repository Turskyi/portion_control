import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/ui/input_row.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => HomeBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PortionControl'),
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
              padding: const EdgeInsets.all(16.0),
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
                    label: 'Body Weight',
                    unit: 'kg',
                    initialValue: state is BodyWeightSubmittedState
                        ? state.bodyWeight.toString()
                        : '',
                    onChanged: (String value) {
                      context.read<HomeBloc>().add(UpdateBodyWeight(value));
                    },
                  ),
                  const SizedBox(height: 16),

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

                  // Submit Button
                  ElevatedButton(
                    onPressed: state.bodyWeight.isEmpty
                        ? null
                        : () {
                            context
                                .read<HomeBloc>()
                                .add(const SubmitBodyWeight());
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Submit'),
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
      ),
    );
  }
}
