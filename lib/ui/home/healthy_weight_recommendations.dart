import 'package:flutter/material.dart';

class HealthyWeightRecommendations extends StatelessWidget {
  const HealthyWeightRecommendations({
    required this.height,
    required this.weight,
    super.key,
  });

  /// in cm.
  final double height;

  /// in kg
  final double weight;

  @override
  Widget build(BuildContext context) {
    // Calculate Body Mass Index (BMI).
    final double heightInMeters = height / 100;
    final double bmi = weight / (heightInMeters * heightInMeters);

    // Calculate healthy weight range (BMI 18.5–24.9).
    final double minHealthyWeight = 18.5 * (heightInMeters * heightInMeters);
    final double maxHealthyWeight = 24.9 * (heightInMeters * heightInMeters);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your Body Mass Index (BMI): ${bmi.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Healthy Weight Range: '
              '${minHealthyWeight.toStringAsFixed(1)}–'
              '${maxHealthyWeight.toStringAsFixed(1)} kg',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _getBmiMessage(bmi),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _getBmiMessageColor(bmi, context),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBmiMessage(double bmi) {
    if (bmi < 18.5) {
      return 'You are underweight. 🥦💪 \nTime to bulk up!';
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      return 'You are in the healthy weight range. 🎉💚 \nKeep it up!';
    } else if (bmi >= 25.0 && bmi <= 29.9) {
      return 'You are overweight. 🍔⚠️\nConsider a balanced diet.';
    } else {
      return 'You are in the obese range. 🍩🚨\nFocus on health!';
    }
  }

  Color _getBmiMessageColor(double bmi, BuildContext context) {
    if (bmi < 18.5) {
      // Underweight.
      return Colors.blue;
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      // Healthy weight.
      return Colors.green;
    } else if (bmi >= 25.0 && bmi <= 29.9) {
      // Overweight.
      return Colors.orange;
    } else {
      // Obese.
      return Colors.red;
    }
  }
}
