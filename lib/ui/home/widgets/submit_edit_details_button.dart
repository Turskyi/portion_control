import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/ui/widgets/responsive_button.dart';

/// Submit/Edit Height Button with animation.
class SubmitEditDetailsButton extends StatelessWidget {
  const SubmitEditDetailsButton({
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
            key: ValueKey<bool>(state is DetailsSubmittedState),
            label: state is DetailsSubmittedState
                ? 'Edit Details'
                : 'Submit Details',
            onPressed: state.height == 0 || state.dateOfBirth == null
                ? null
                : state is DetailsSubmittedState
                    ? () => context.read<HomeBloc>().add(const EditDetails())
                    : () => context.read<HomeBloc>().add(const SubmitDetails()),
          );
        },
      ),
    );
  }
}
