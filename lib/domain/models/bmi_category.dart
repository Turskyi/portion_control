import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

enum BmiCategory {
  underweight,
  healthy,
  overweight,
  obese;

  static const double minHealthyBmi = 18.5;
  static const double maxHealthyBmi = 24.9;

  static BmiCategory fromBmi(double bmi) {
    final double roundedBmi = roundBmi(bmi);

    if (roundedBmi < minHealthyBmi) {
      return BmiCategory.underweight;
    } else if (roundedBmi <= maxHealthyBmi) {
      return BmiCategory.healthy;
    } else if (roundedBmi < 30.0) {
      return BmiCategory.overweight;
    } else {
      return BmiCategory.obese;
    }
  }

  /// Calculates the classification based on weight and height to ensure
  /// consistency with the displayed healthy weight range.
  static BmiCategory fromWeightAndHeight({
    required double weightKg,
    required double heightCm,
  }) {
    final (double minHealthyWeight, double maxHealthyWeight) =
        healthyWeightRange(heightCm);

    // Round weight to 1 decimal place to match UI input and display.
    final double roundedWeight = (weightKg * 10).roundToDouble() / 10;

    if (roundedWeight < minHealthyWeight) {
      return BmiCategory.underweight;
    } else if (roundedWeight <= maxHealthyWeight) {
      return BmiCategory.healthy;
    } else {
      // For higher categories, we can fall back to BMI-based classification
      // or define similar boundaries. Standard overweight is BMI < 30.
      final double heightInMeters = heightCm / 100;
      final double bmi = weightKg / (heightInMeters * heightInMeters);
      final double roundedBmi = roundBmi(bmi);

      if (roundedBmi < 30.0) {
        return BmiCategory.overweight;
      } else {
        return BmiCategory.obese;
      }
    }
  }

  /// Returns the healthy weight range (min, max) for a given height in cm,
  /// rounded to 1 decimal place.
  static (double min, double max) healthyWeightRange(double heightCm) {
    final double heightInMeters = heightCm / 100;
    final double h2 = heightInMeters * heightInMeters;

    return (
      (minHealthyBmi * h2 * 10).roundToDouble() / 10,
      (maxHealthyBmi * h2 * 10).roundToDouble() / 10,
    );
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
