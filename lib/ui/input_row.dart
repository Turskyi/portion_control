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
    return Row(
      children: <Widget>[
        Expanded(
          child: bodyWeight != null
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Text(
                    bodyWeight,
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : TextFormField(
                  initialValue: initialValue,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: label,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            unit,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
