import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';

class InputRow extends StatelessWidget {
  const InputRow({
    required this.label,
    required this.unit,
    required this.onChanged,
    required this.initialValue,
    required this.state,
    super.key,
  });

  final String label;
  final String unit;
  final String initialValue;
  final HomeState state;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final String? bodyWeight =
        state is BodyWeightSubmittedState ? state.bodyWeight : null;
    final double? bodyLargeFontSize =
        Theme.of(context).textTheme.bodyLarge?.fontSize;
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
            child: bodyWeight != null
                ? Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          // Key ensures the AnimatedSwitcher detects a new
                          // widget.
                          key: const ValueKey<bool>(true),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Text(
                            bodyWeight,
                            style: TextStyle(
                              fontSize: bodyLargeFontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : TextFormField(
                    // Different key for animation.
                    key: const ValueKey<bool>(false),
                    initialValue: initialValue,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: label,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      // Prevent multiple dots.
                      TextInputFormatter.withFunction((
                        TextEditingValue oldValue,
                        TextEditingValue newValue,
                      ) {
                        if (newValue.text.contains('.') &&
                            newValue.text.split('.').length > 2) {
                          return oldValue;
                        }
                        return newValue;
                      }),
                    ],
                    onChanged: onChanged,
                  ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            unit,
            style: TextStyle(
              fontSize: bodyLargeFontSize,
            ),
          ),
        ),
      ],
    );
  }
}
