import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

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

    final TextTheme textTheme = Theme.of(context).textTheme;
    final String kgSuffix = translate('healthy_weight.kg_suffix');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${translate(
                      'healthy_weight.your_bmi_prefix',
                    )}${bmi.toStringAsFixed(1)}',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${translate('healthy_weight.range_prefix')}'
                    '${minHealthyWeight.toStringAsFixed(1)}${translate(
                      'healthy_weight.range_separator',
                    )}'
                    '${maxHealthyWeight.toStringAsFixed(1)}$kgSuffix',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getBmiMessage(bmi),
                    style: textTheme.titleLarge?.copyWith(
                      color: _getBmiMessageColor(bmi, context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getBmiMessage(double bmi) {
    if (bmi < 18.5) {
      return translate('healthy_weight.underweight_message');
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      return translate('healthy_weight.healthy_message');
    } else if (bmi >= 25.0 && bmi <= 29.9) {
      return translate('healthy_weight.overweight_message');
    } else {
      return translate('healthy_weight.obese_message');
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
