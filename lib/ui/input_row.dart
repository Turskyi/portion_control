import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputRow extends StatelessWidget {
  const InputRow({
    required this.label,
    required this.unit,
    required this.onChanged,
    required this.initialValue,
    super.key,
  });

  final String label;
  final String unit;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
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
