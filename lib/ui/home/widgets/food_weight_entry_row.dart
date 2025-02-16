import 'package:flutter/material.dart';

class FoodWeightEntryRow extends StatefulWidget {
  const FoodWeightEntryRow({
    this.value,
    this.time = '',
    this.isEditState = false,
    this.onEdit,
    this.onDelete,
    this.onSave,
    super.key,
  });

  final String? value;
  final String time;
  final bool isEditState;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onSave;

  @override
  State<FoodWeightEntryRow> createState() => _FoodWeightEntryRowState();
}

class _FoodWeightEntryRowState extends State<FoodWeightEntryRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant FoodWeightEntryRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _controller,
            enabled: widget.isEditState,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter food weight',
              suffixText: 'g',
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (_) => _handleSave(),
          ),
        ),
        const SizedBox(width: 8),
        Text(widget.time),
        if (widget.isEditState)
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _handleSave,
          )
        else ...<Widget>[
          if (widget.onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: widget.onEdit,
            ),
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: widget.onDelete,
            ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave?.call(_controller.text);
  }
}
