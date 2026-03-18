import 'package:flutter_test/flutter_test.dart';
import 'package:portion_control/domain/models/bmi_category.dart';

void main() {
  group('BmiCategory', () {
    test(
      'Test Case 1 — Boundary above healthy range (critical regression test)',
      () {
        const double height = 171; // cm
        const double weight = 72.9; // kg

        final (double min, double max) = BmiCategory.healthyWeightRange(height);

        expect(min, 54.1);
        expect(max, 72.8);

        final BmiCategory category = BmiCategory.fromWeightAndHeight(
          weightKg: weight,
          heightCm: height,
        );

        expect(
          weight,
          greaterThan(max),
          reason: 'Weight should be above displayed healthy range',
        );
        expect(
          category,
          BmiCategory.overweight,
          reason:
              '72.9kg should be overweight for 171cm height if max healthy '
              'weight is 72.8kg',
        );
      },
    );

    test('Test Case 2 — Exact upper healthy boundary', () {
      const double height = 171; // cm
      const double weight = 72.8; // kg

      final (double min, double max) = BmiCategory.healthyWeightRange(height);

      expect(min, 54.1);
      expect(max, 72.8);

      final BmiCategory category = BmiCategory.fromWeightAndHeight(
        weightKg: weight,
        heightCm: height,
      );

      expect(weight, lessThanOrEqualTo(max));
      expect(category, BmiCategory.healthy);
    });

    test('Test Case 3 — Mid healthy value', () {
      const double height = 171; // cm
      const double weight = 65; // kg

      final BmiCategory category = BmiCategory.fromWeightAndHeight(
        weightKg: weight,
        heightCm: height,
      );

      expect(category, BmiCategory.healthy);
    });

    test('Test Case 4 - Rounding consistency for displayed BMI', () {
      // 171cm, 72.9kg -> BMI = 72.9 / (1.71^2) = 24.930...
      // Rounded to 1 decimal place: 24.9
      const double height = 171;
      const double weight = 72.9;
      final double bmi = weight / ((height / 100) * (height / 100));

      expect(BmiCategory.roundBmi(bmi), 24.9);

      // Even though rounded BMI is 24.9 (which is normally the max healthy
      // BMI),
      // the classification should be overweight because the weight 72.9
      // exceeds the healthy range [54.1, 72.8] derived from BMI [18.5, 24.9].
      final BmiCategory category = BmiCategory.fromWeightAndHeight(
        weightKg: weight,
        heightCm: height,
      );
      expect(category, BmiCategory.overweight);
    });
  });
}
