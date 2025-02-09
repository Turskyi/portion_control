import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
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
            onPressed: state.height < constants.minHeight
                ? null
                : state is DetailsSubmittedState
                    ? () async {
                        if (state.bodyWeightEntries.isEmpty) {
                          context.read<HomeBloc>().add(const EditDetails());
                        } else {
                          await _showConfirmationDialog(context);
                        }
                      }
                    : () => context.read<HomeBloc>().add(const SubmitDetails()),
          );
        },
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    final bool? shouldResetData = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Data'),
          content: const Text(
            'Changing your details will affect your tracking. Do you want to '
            'start fresh and reset all data?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Don't reset data.
                Navigator.of(context).pop(false);
              },
              child: const Text('Keep My Records'),
            ),
            TextButton(
              onPressed: () {
                // Reset all data.
                Navigator.of(context).pop(true);
              },
              child: const Text('Start Fresh'),
            ),
          ],
        );
      },
    );

    if (context.mounted && shouldResetData == true) {
      // Reset all user data (body weight, food intake, etc.)
      context.read<HomeBloc>().add(const ClearUserData());
    } else if (context.mounted) {
      context.read<HomeBloc>().add(const EditDetails());
    }
  }
}
