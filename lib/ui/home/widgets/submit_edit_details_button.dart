import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/widgets/responsive_button.dart';

/// Submit/Edit Height Button with animation.
class SubmitEditDetailsButton extends StatelessWidget {
  const SubmitEditDetailsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      // Animation duration.
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Define the transition effect.
        return ScaleTransition(scale: animation, child: child);
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (BuildContext context, HomeState state) {
          final bool isDetailsSubmitted = state is DetailsSubmittedState;
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return BlocListener<MenuBloc, MenuState>(
                listenWhen: _shouldRebuildOnLanguageChange,
                listener: (BuildContext _, MenuState _) {
                  setState(() {});
                },
                child: ResponsiveButton(
                  // Assign a unique key to differentiate widgets during
                  // transitions.
                  key: ValueKey<bool>(isDetailsSubmitted),
                  label: isDetailsSubmitted
                      ? translate('button.edit_details')
                      : translate('button.submit_details'),
                  onPressed: state.heightInCm < constants.minUserHeight
                      ? null
                      : isDetailsSubmitted
                      ? () async {
                          if (state.bodyWeightEntries.isEmpty) {
                            context.read<HomeBloc>().add(const EditDetails());
                          } else {
                            await _showConfirmationDialog(context);
                          }
                        }
                      : () =>
                            context.read<HomeBloc>().add(const SubmitDetails()),
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool _shouldRebuildOnLanguageChange(MenuState previous, MenuState current) {
    return previous.language != current.language;
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    final bool? shouldResetData = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('dialog.reset_data_title')),
          content: Text(translate('dialog.reset_data_content')),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Don't reset data.
                Navigator.of(context).pop(false);
              },
              child: Text(translate('button.keep_my_records')),
            ),
            TextButton(
              onPressed: () {
                // Reset all data.
                Navigator.of(context).pop(true);
              },
              child: Text(translate('button.start_fresh')),
            ),
          ],
        );
      },
    );

    if (context.mounted && shouldResetData == true) {
      // Reset all user data (body weight, food intake, etc.)
      context.read<HomeBloc>().add(const ClearTrackingData());
    } else if (context.mounted) {
      context.read<HomeBloc>().add(const EditDetails());
    }
  }
}
