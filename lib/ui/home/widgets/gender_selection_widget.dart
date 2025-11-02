import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/domain/enums/gender.dart';

class GenderSelectionWidget extends StatelessWidget {
  const GenderSelectionWidget({
    required this.bodyWeight,
    required this.gender,
    required this.isDetailsSubmitted,
    super.key,
  });

  final double bodyWeight;
  final Gender gender;
  final bool isDetailsSubmitted;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final double? bodyLargeFontSize = textTheme.bodyLarge?.fontSize;
    final Color dividerColor = themeData.dividerColor;
    final TextStyle? titleMedium = textTheme.titleMedium;
    return Row(
      children: <Widget>[
        Expanded(
          child: AnimatedSwitcher(
            // Animation duration.
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
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
            child: isDetailsSubmitted
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 0, 4, 1),
                        child: Text(
                          translate('gender'),
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
                                  color: themeData.colorScheme.onTertiary,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              child: Row(
                                children: <Widget>[
                                  // Display the emoji here.
                                  Text(
                                    gender.emoji,
                                    style: TextStyle(
                                      fontSize: textTheme.titleMedium?.fontSize,
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
                      value: gender,
                      decoration: InputDecoration(
                        labelText: translate('gender'),
                        filled: true,
                        fillColor: themeData.colorScheme.secondary.withOpacity(
                          0.1,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: themeData.primaryColor),
                        ),
                      ),
                      items: Gender.values
                          .map(
                            (Gender gender) => DropdownMenuItem<Gender>(
                              value: gender,
                              child: Row(
                                children: <Widget>[
                                  // Display the emoji here.
                                  Text(
                                    gender.emoji,
                                    style: TextStyle(
                                      fontSize: titleMedium?.fontSize,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    gender.displayName,
                                    style: TextStyle(
                                      fontSize: titleMedium?.fontSize,
                                      fontWeight: FontWeight.w600,
                                      color: textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (Gender? value) {
                        if (value != null) {
                          context.read<HomeBloc>().add(UpdateGender(value));
                        }
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
