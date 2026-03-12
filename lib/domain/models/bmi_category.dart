import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

enum BmiCategory {
  underweight,
  healthy,
  overweight,
  obese;

  static BmiCategory fromBmi(double bmi) {
    final double roundedBmi = roundBmi(bmi);

    if (roundedBmi < 18.5) {
      return BmiCategory.underweight;
    } else if (roundedBmi < 25.0) {
      return BmiCategory.healthy;
    } else if (roundedBmi < 30.0) {
      return BmiCategory.overweight;
    } else {
      return BmiCategory.obese;
    }
  }

  static double roundBmi(double bmi) {
    // Round to 1 decimal place to match the displayed value and standard
    // thresholds.
    return (bmi * 10).roundToDouble() / 10;
  }

  String get message => translate('healthy_weight.${name}_message');

  Color color(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      BmiCategory.underweight => colorScheme.primaryContainer,
      BmiCategory.healthy => colorScheme.tertiary,
      BmiCategory.overweight => colorScheme.secondaryContainer,
      BmiCategory.obese => colorScheme.error,
    };
  }
}
