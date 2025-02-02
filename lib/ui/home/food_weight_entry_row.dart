import 'package:flutter/material.dart';

class FoodWeightEntryRow extends StatelessWidget {
  const FoodWeightEntryRow({
    required this.time,
    this.value,
    this.isEditable = false,
    this.onEdit,
    this.onDelete,
    this.onSave,
    super.key,
  });

  final String? value;
  final String time;
  final bool isEditable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            initialValue: value,
            enabled: isEditable,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter food weight',
              suffixText: 'g',
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: onSave,
          ),
        ),
        const SizedBox(width: 8),
        Text(time),
        if (!isEditable) ...<Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ],
    );
  }
}
