import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class NextButton extends StatelessWidget {
  const NextButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(translate('next')),
    );
  }
}
