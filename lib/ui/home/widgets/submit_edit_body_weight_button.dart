import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
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
          // Helper for translation
          String t(String key) => translate(key);
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
                  key: ValueKey<bool>(state is BodyWeightSubmittedState),
                  label: state is BodyWeightSubmittedState
                      ? t('submit_edit_body_weight_button.edit_body_weight')
                      : t('submit_edit_body_weight_button.submit_body_weight'),
                  onPressed: state.bodyWeight < constants.minBodyWeight
                      ? null
                      : state is BodyWeightSubmittedState
                          ? () => context
                              .read<HomeBloc>()
                              .add(const EditBodyWeight())
                          : () {
                              context
                                  .read<HomeBloc>()
                                  .add(SubmitBodyWeight(state.bodyWeight));
                            },
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
}
