import 'package:flutter/material.dart';

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
              child: const Text('Next'),
            )
          else
            ElevatedButton(
              onPressed: onGetStartedPressed,
              child: const Text('Get Started'),
            ),
        ],
      ),
    );
  }
}
