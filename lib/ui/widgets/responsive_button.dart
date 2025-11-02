import 'package:flutter/material.dart';

class ResponsiveButton extends StatelessWidget {
  const ResponsiveButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext _, BoxConstraints constraints) {
        final double buttonWidth = constraints.maxWidth > 600
            ? 300
            : constraints.maxWidth * 0.8;

        return Center(
          child: SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                // Adds height.
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
