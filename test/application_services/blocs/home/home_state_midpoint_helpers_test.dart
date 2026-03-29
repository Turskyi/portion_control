import 'package:flutter_test/flutter_test.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/res/constants/constants.dart';

void main() {
  group('HomeState - Midpoint Helpers', () {
    const double kValidHeight = 170.0; // cm
    const double kBuffer = kMidpointBuffer;

    /// Create a BodyWeightSubmittedState for testing midpoint helpers.
    /// This concrete state supports isMealsConfirmedForToday property.
    BodyWeightSubmittedState createState({
      double bodyWeight = 70.0,
      double heightInCm = kValidHeight,
      bool isConfirmedAllMealsLogged = false,
      List<BodyWeight> bodyWeightEntries = const <BodyWeight>[],
      double yesterdayConsumedTotal = 0.0,
    }) {
      final UserDetails userDetails = UserDetails(
        heightInCm: heightInCm,
        gender: Gender.male,
        dateOfBirth: null,
      );

      return BodyWeightSubmittedState(
        userDetails: userDetails,
        bodyWeight: bodyWeight,
        bodyWeightEntries: bodyWeightEntries,
        foodEntries: const <FoodWeight>[],
        language: Language.en,
        hasWeightIncreaseProof: false,
        date: DateTime.now(),
        portionControl: 2000.0,
        yesterdayConsumedTotal: yesterdayConsumedTotal,
        isConfirmedAllMealsLogged: isConfirmedAllMealsLogged,
      );
    }

    List<BodyWeight> trendEntries({
      required double previous,
      required double current,
    }) {
      final DateTime yesterday = DateTime(2026, 3, 28);
      final DateTime today = DateTime(2026, 3, 29);
      return <BodyWeight>[
        BodyWeight(id: 1, weight: previous, date: yesterday),
        BodyWeight(id: 2, weight: current, date: today),
      ];
    }

    group('hasValidHeightForMidpoint', () {
      test('returns true when height is above minimum', () {
        final BodyWeightSubmittedState state = createState(
          heightInCm: kMinUserHeight + 1,
        );
        expect(state.hasValidHeightForMidpoint, isTrue);
      });

      test('returns false when height is at minimum', () {
        final BodyWeightSubmittedState state = createState(
          heightInCm: kMinUserHeight,
        );
        expect(state.hasValidHeightForMidpoint, isFalse);
      });

      test('returns false when height is below minimum', () {
        final BodyWeightSubmittedState state = createState(
          heightInCm: kMinUserHeight - 1,
        );
        expect(state.hasValidHeightForMidpoint, isFalse);
      });
    });

    group('midpointWeight', () {
      test('calculates midpoint correctly when height is valid', () {
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
        );
        expect(state.midpointWeight, isNotNull);
        expect(state.midpointWeight, greaterThan(0));
      });

      test('returns bodyWeight when height is invalid', () {
        final double invalidHeight = kMinUserHeight - 10;
        const double testWeight = 65.0;
        final BodyWeightSubmittedState state = createState(
          heightInCm: invalidHeight,
          bodyWeight: testWeight,
        );
        expect(state.midpointWeight, equals(testWeight));
      });

      test('midpoint weight is between healthy range bounds', () {
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = state.midpointWeight;

        // For a given height, midpoint should be reasonable
        // (roughly in the middle of healthy BMI range)
        expect(midpoint, greaterThan(50)); // reasonable minimum
        expect(midpoint, lessThan(100)); // reasonable maximum
      });
    });

    group('isWeightAboveMidpoint', () {
      test('returns true when weight is above midpoint + buffer', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint + kBuffer + 0.1,
        );
        expect(state.isWeightAboveMidpoint, isTrue);
      });

      test('returns false when weight is below midpoint + buffer', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint + kBuffer - 0.1,
        );
        expect(state.isWeightAboveMidpoint, isFalse);
      });

      test('returns false when weight is within midpoint buffer zone', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint,
        );
        expect(state.isWeightAboveMidpoint, isFalse);
      });

      test('returns false when height is invalid', () {
        final BodyWeightSubmittedState state = createState(
          heightInCm: kMinUserHeight - 1,
          bodyWeight: 100.0,
        );
        expect(state.isWeightAboveMidpoint, isFalse);
      });
    });

    group('isWeightBelowMidpoint', () {
      test('returns true when weight is below midpoint - buffer', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint - kBuffer - 0.1,
        );
        expect(state.isWeightBelowMidpoint, isTrue);
      });

      test('returns false when weight is above midpoint - buffer', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint - kBuffer + 0.1,
        );
        expect(state.isWeightBelowMidpoint, isFalse);
      });

      test('returns false when weight is within midpoint buffer zone', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint,
        );
        expect(state.isWeightBelowMidpoint, isFalse);
      });

      test('returns false when height is invalid', () {
        final BodyWeightSubmittedState state = createState(
          heightInCm: kMinUserHeight - 1,
          bodyWeight: 50.0,
        );
        expect(state.isWeightBelowMidpoint, isFalse);
      });
    });

    group('midpoint out-of-buffer detection', () {
      test('returns true when weight is above midpoint', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint + kBuffer + 0.1,
        );
        expect(
          state.isWeightAboveMidpoint || state.isWeightBelowMidpoint,
          isTrue,
        );
      });

      test('returns true when weight is below midpoint', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint - kBuffer - 0.1,
        );
        expect(
          state.isWeightAboveMidpoint || state.isWeightBelowMidpoint,
          isTrue,
        );
      });

      test('returns false when weight is within midpoint buffer zone', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint,
        );
        expect(
          state.isWeightAboveMidpoint || state.isWeightBelowMidpoint,
          isFalse,
        );
      });

      test('returns false when height is invalid', () {
        final BodyWeightSubmittedState state = createState(
          heightInCm: kMinUserHeight - 1,
          bodyWeight: 100.0,
        );
        expect(
          state.isWeightAboveMidpoint || state.isWeightBelowMidpoint,
          isFalse,
        );
      });
    });

    group('shouldAskForMealConfirmation', () {
      test(
        'returns true when weight is increasing above midpoint '
        'and meals are not confirmed',
        () {
          final BodyWeightSubmittedState baseState = createState(
            heightInCm: kValidHeight,
          );
          final double midpoint = baseState.midpointWeight;
          final BodyWeightSubmittedState state = createState(
            heightInCm: kValidHeight,
            bodyWeight: midpoint + kBuffer + 0.1,
            isConfirmedAllMealsLogged: false,
            yesterdayConsumedTotal: 1800,
            bodyWeightEntries: trendEntries(
              previous: midpoint + kBuffer,
              current: midpoint + kBuffer + 0.3,
            ),
          );
          expect(state.shouldAskForMealConfirmation, isTrue);
        },
      );

      test(
        'returns false when weight is above midpoint but decreasing',
        () {
          final BodyWeightSubmittedState baseState = createState(
            heightInCm: kValidHeight,
          );
          final double midpoint = baseState.midpointWeight;
          final BodyWeightSubmittedState state = createState(
            heightInCm: kValidHeight,
            bodyWeight: midpoint + kBuffer + 0.1,
            isConfirmedAllMealsLogged: false,
            yesterdayConsumedTotal: 1800,
            bodyWeightEntries: trendEntries(
              previous: midpoint + kBuffer + 0.4,
              current: midpoint + kBuffer + 0.1,
            ),
          );
          expect(state.shouldAskForMealConfirmation, isFalse);
        },
      );

      test(
        'returns true when weight is decreasing below midpoint '
        'and meals are not confirmed',
        () {
          final BodyWeightSubmittedState baseState = createState(
            heightInCm: kValidHeight,
          );
          final double midpoint = baseState.midpointWeight;
          final BodyWeightSubmittedState state = createState(
            heightInCm: kValidHeight,
            bodyWeight: midpoint - kBuffer - 0.1,
            isConfirmedAllMealsLogged: false,
            yesterdayConsumedTotal: 1800,
            bodyWeightEntries: trendEntries(
              previous: midpoint - kBuffer,
              current: midpoint - kBuffer - 0.3,
            ),
          );
          expect(state.shouldAskForMealConfirmation, isTrue);
        },
      );

      test('returns false when weight is below midpoint but increasing', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint - kBuffer - 0.1,
          isConfirmedAllMealsLogged: false,
          yesterdayConsumedTotal: 1800,
          bodyWeightEntries: trendEntries(
            previous: midpoint - kBuffer - 0.4,
            current: midpoint - kBuffer - 0.1,
          ),
        );
        expect(state.shouldAskForMealConfirmation, isFalse);
      });

      test(
        'returns false when trend qualifies but meals are already confirmed',
        () {
          final BodyWeightSubmittedState baseState = createState(
            heightInCm: kValidHeight,
          );
          final double midpoint = baseState.midpointWeight;
          final BodyWeightSubmittedState state = createState(
            heightInCm: kValidHeight,
            bodyWeight: midpoint + kBuffer + 0.1,
            isConfirmedAllMealsLogged: true,
            yesterdayConsumedTotal: 1800,
            bodyWeightEntries: trendEntries(
              previous: midpoint + kBuffer,
              current: midpoint + kBuffer + 0.3,
            ),
          );
          expect(state.shouldAskForMealConfirmation, isFalse);
        },
      );

      test('returns false when no trend data is available', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint + kBuffer + 0.1,
          isConfirmedAllMealsLogged: false,
          yesterdayConsumedTotal: 0,
          bodyWeightEntries: const <BodyWeight>[],
        );
        expect(state.shouldAskForMealConfirmation, isFalse);
      });
    });

    group('Buffer zone boundary conditions', () {
      test('weight at exactly midpoint + buffer is NOT above threshold', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint + kBuffer,
        );
        // At the boundary, > is false, so no adjustment needed
        expect(
          state.isWeightAboveMidpoint || state.isWeightBelowMidpoint,
          isFalse,
        );
      });

      test('weight at exactly midpoint - buffer is NOT below threshold', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint - kBuffer,
        );
        // At the boundary, < is false, so no adjustment needed
        expect(
          state.isWeightAboveMidpoint || state.isWeightBelowMidpoint,
          isFalse,
        );
      });

      test('weight just above buffer zone needs adjustment', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint + kBuffer + 0.01,
        );
        expect(
          state.isWeightAboveMidpoint || state.isWeightBelowMidpoint,
          isTrue,
        );
      });

      test('weight just below buffer zone needs adjustment', () {
        final BodyWeightSubmittedState baseState = createState(
          heightInCm: kValidHeight,
        );
        final double midpoint = baseState.midpointWeight;
        final BodyWeightSubmittedState state = createState(
          heightInCm: kValidHeight,
          bodyWeight: midpoint - kBuffer - 0.01,
        );
        expect(
          state.isWeightAboveMidpoint || state.isWeightBelowMidpoint,
          isTrue,
        );
      });
    });
  });
}
