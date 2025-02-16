import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/widgets/responsive_button.dart';

/// Submit/Edit Body Weight Button with animation.
class SubmitEditBodyWeightButton extends StatelessWidget {
  const SubmitEditBodyWeightButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      // Animation duration.
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
      ) {
        // Define the transition effect.
        return ScaleTransition(scale: animation, child: child);
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (BuildContext context, HomeState state) {
          return ResponsiveButton(
            // Assign a unique key to differentiate widgets during
            // transitions.
            key: ValueKey<bool>(state is BodyWeightSubmittedState),
            label: state is BodyWeightSubmittedState
                ? 'Edit Body Weight'
                : 'Submit Body Weight',
            onPressed: state.bodyWeight < constants.minBodyWeight
                ? null
                : state is BodyWeightSubmittedState
                    ? () => context.read<HomeBloc>().add(const EditBodyWeight())
                    : () {
                        context
                            .read<HomeBloc>()
                            .add(SubmitBodyWeight(state.bodyWeight));
                      },
          );
        },
      ),
    );
  }
}
