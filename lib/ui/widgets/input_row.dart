import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';

class InputRow extends StatelessWidget {
  const InputRow({
    required this.label,
    required this.value,
    this.initialValue,
    this.unit = '',
    this.isRequired = false,
    this.readOnly = false,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onUnitTap,
    this.message = '',
    super.key,
  });

  final String label;
  final String unit;
  final String? initialValue;
  final String? value;
  final bool isRequired;
  final bool readOnly;
  final TextEditingController? controller;
  final GestureTapCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onUnitTap;

  /// The text to display in the tooltip.
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final double? bodyLargeFontSize = themeData.textTheme.bodyLarge?.fontSize;
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
            child: value != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 0, 4, 1),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: themeData.textTheme.bodySmall?.fontSize,
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              // Key ensures the AnimatedSwitcher detects a
                              // new widget.
                              key: ValueKey<String>('$value'),
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
                              child: Text(
                                value ?? '',
                                style: TextStyle(fontSize: bodyLargeFontSize),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: TextFormField(
                      // Different key for animation.
                      key: ValueKey<String>('$value'),
                      readOnly: readOnly,
                      controller: controller,
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
                      onTap: onTap,
                      validator: isRequired
                          ? (String? value) {
                              if (value == null || value.isEmpty) {
                                return translate('field_required');
                              }
                              return null;
                            }
                          : null,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Tooltip(
            message: message,
            waitDuration: const Duration(milliseconds: 400),
            child: InkWell(
              onTap: onUnitTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: onUnitTap != null
                    ? const EdgeInsets.fromLTRB(8.0, 14.0, 14.0, 14.0)
                    : EdgeInsets.zero,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Text(
                      unit,
                      style: TextStyle(fontSize: bodyLargeFontSize),
                    ),
                    if (onUnitTap != null)
                      Positioned(
                        top: -8,
                        right: -10,
                        child: Icon(
                          Icons.info_outline,
                          size: 12,
                          color: Colors.grey,
                          semanticLabel: translate('info'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
