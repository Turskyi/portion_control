import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

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
  final FocusNode _focusNode = FocusNode();

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
    if (widget.isEditState && !oldWidget.isEditState) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (BuildContext _, TextEditingValue value, Widget? _) {
              final String input = value.text;

              return TextFormField(
                focusNode: _focusNode,
                controller: _controller,
                readOnly: !widget.isEditState,
                onTap: !widget.isEditState ? widget.onEdit : null,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: translate('hint.enter_food_weight'),
                  suffixText: translate('unit.gram'),
                  border: const OutlineInputBorder(),
                ),
                onFieldSubmitted: _isValidWeightInput(input)
                    ? (String _) => _handleSave()
                    : null,
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(widget.time),
        if (widget.isEditState)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            child: const Icon(Icons.check),
            builder: (BuildContext _, TextEditingValue value, Widget? icon) {
              final String input = value.text;
              return IconButton(
                icon: icon ?? const Icon(Icons.check),
                onPressed: _isValidWeightInput(input) ? _handleSave : null,
              );
            },
          )
        else ...<Widget>[
          if (widget.onEdit != null)
            IconButton(icon: const Icon(Icons.edit), onPressed: widget.onEdit),
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
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave?.call(_controller.text);
  }

  bool _isValidWeightInput(String input) {
    return (input.isNotEmpty && (double.tryParse(input) ?? 0) > 0);
  }
}
