import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class OnboardingControls extends StatelessWidget {
  const OnboardingControls({
    required this.currentPage,
    required this.onNextPressed,
    required this.onGetStartedPressed,
    super.key,
  });

  final int currentPage;
  final VoidCallback onNextPressed;
  final VoidCallback onGetStartedPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (currentPage != 2)
            ElevatedButton(
              onPressed: onNextPressed,
              child: Text(translate('next')),
            )
          else
            ElevatedButton(
              onPressed: onGetStartedPressed,
              child: Text(translate('get_started')),
            ),
        ],
      ),
    );
  }
}
