import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;

import '../../../dummy_constants.dart' as dummy;
import '../../../helpers/translate_test_helper.dart' as helper;

/// Helper function that mirrors _shouldTriggerConfettiAfterBodyWeightSubmit.
/// This allows testing confetti trigger conditions independently.
bool shouldTriggerConfetti({
  required HomeLoaded? previousState,
  required HomeLoaded currentState,
}) {
  // Cast to DetailsSubmittedState to access required properties
  if (previousState is! DetailsSubmittedState) {
    return false;
  }

  if (currentState is! BodyWeightSubmittedState) {
    return false;
  }

  final DetailsSubmittedState previousSubmittedState = previousState;
  final double currentWeight = currentState.bodyWeight;

  final bool isCurrentWeightHealthy =
      !currentState.isWeightAboveHealthyFor(currentWeight) &&
      !currentState.isWeightBelowHealthyFor(currentWeight);

  // Scenario 1: Celebrate first submission in healthy range
  if (previousSubmittedState.bodyWeightEntries.isEmpty) {
    return isCurrentWeightHealthy;
  }

  final double previousLoggedWeight =
      previousSubmittedState.bodyWeightEntries.last.weight;

  // Scenario 2: Recovered from above healthy to healthy
  final bool wasAboveHealthy = currentState.isWeightAboveHealthyFor(
    previousLoggedWeight,
  );
  final bool recoveredToHealthyFromAbove =
      wasAboveHealthy && isCurrentWeightHealthy;

  // Scenario 3: First crossing from above midpoint to below midpoint
  final double midpoint = currentState.midpointWeight;
  final bool wasAboveMidpoint = previousLoggedWeight > midpoint;
  final bool isNowBelowMidpoint = currentWeight < midpoint;
  final bool wasBelowMidpointBefore = previousSubmittedState.bodyWeightEntries
      .any(
        (BodyWeight entry) => entry.weight < midpoint,
      );

  final bool firstMidpointCrossingFromAbove =
      wasAboveMidpoint && isNowBelowMidpoint && !wasBelowMidpointBefore;

  return recoveredToHealthyFromAbove || firstMidpointCrossingFromAbove;
}

void main() {
  late UserDetails testUserDetails;

  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await helper.setUpFlutterTranslateForTests();

    testUserDetails = UserDetails(
      heightInCm: dummy.dummyHeightInCm,
      gender: Gender.male,
      dateOfBirth: dummy.dummyDateOfBirth,
    );
  });

  group('Confetti Trigger Logic', () {
    group('Scenario 1: First submission in healthy range', () {
      test(
        'should trigger confetti when first weight entry '
        'is in healthy range',
        () {
          // Arrange: Empty history, first submission with healthy weight
          final DetailsSubmittedState detailsState = DetailsSubmittedState(
            userDetails: testUserDetails,
            bodyWeight: 70.0, // Healthy range for given height
            bodyWeightEntries: const <BodyWeight>[],
            foodEntries: const <FoodWeight>[],
            language: Language.en,
            hasWeightIncreaseProof: false,
            date: DateTime.now(),
            portionControl: constants.kMaxDailyFoodLimit,
            yesterdayConsumedTotal: 0,
          );

          final BodyWeightSubmittedState currentState =
              BodyWeightSubmittedState(
                userDetails: testUserDetails,
                bodyWeight: 70.0,
                bodyWeightEntries: const <BodyWeight>[],
                foodEntries: const <FoodWeight>[],
                language: Language.en,
                hasWeightIncreaseProof: false,
                date: DateTime.now(),
                portionControl: constants.kMaxDailyFoodLimit,
                yesterdayConsumedTotal: 0,
                isConfirmedAllMealsLogged: false,
              );

          // Act
          final bool shouldTrigger = shouldTriggerConfetti(
            previousState: detailsState,
            currentState: currentState,
          );

          // Assert
          expect(shouldTrigger, isTrue);
        },
      );

      test(
        'should NOT trigger confetti when first weight '
        'entry is above healthy range',
        () {
          // Arrange: Empty history, first submission above range
          final DetailsSubmittedState detailsState = DetailsSubmittedState(
            userDetails: testUserDetails,
            bodyWeight: 100.0, // Above healthy range
            bodyWeightEntries: const <BodyWeight>[],
            foodEntries: const <FoodWeight>[],
            language: Language.en,
            hasWeightIncreaseProof: false,
            date: DateTime.now(),
            portionControl: constants.kMaxDailyFoodLimit,
            yesterdayConsumedTotal: 0,
          );

          final BodyWeightSubmittedState currentState =
              BodyWeightSubmittedState(
                userDetails: testUserDetails,
                bodyWeight: 100.0,
                bodyWeightEntries: const <BodyWeight>[],
                foodEntries: const <FoodWeight>[],
                language: Language.en,
                hasWeightIncreaseProof: false,
                date: DateTime.now(),
                portionControl: constants.kMaxDailyFoodLimit,
                yesterdayConsumedTotal: 0,
                isConfirmedAllMealsLogged: false,
              );

          // Act
          final bool shouldTrigger = shouldTriggerConfetti(
            previousState: detailsState,
            currentState: currentState,
          );

          // Assert
          expect(shouldTrigger, isFalse);
        },
      );

      test(
        'should NOT trigger confetti when first weight '
        'entry is below healthy range',
        () {
          // Arrange: Empty history, first submission below range
          final DetailsSubmittedState detailsState = DetailsSubmittedState(
            userDetails: testUserDetails,
            bodyWeight: 50.0, // Below healthy range
            bodyWeightEntries: const <BodyWeight>[],
            foodEntries: const <FoodWeight>[],
            language: Language.en,
            hasWeightIncreaseProof: false,
            date: DateTime.now(),
            portionControl: constants.kMaxDailyFoodLimit,
            yesterdayConsumedTotal: 0,
          );

          final BodyWeightSubmittedState currentState =
              BodyWeightSubmittedState(
                userDetails: testUserDetails,
                bodyWeight: 50.0,
                bodyWeightEntries: const <BodyWeight>[],
                foodEntries: const <FoodWeight>[],
                language: Language.en,
                hasWeightIncreaseProof: false,
                date: DateTime.now(),
                portionControl: constants.kMaxDailyFoodLimit,
                yesterdayConsumedTotal: 0,
                isConfirmedAllMealsLogged: false,
              );

          // Act
          final bool shouldTrigger = shouldTriggerConfetti(
            previousState: detailsState,
            currentState: currentState,
          );

          // Assert
          expect(shouldTrigger, isFalse);
        },
      );
    });

    group('Scenario 2: Recovery from above healthy to healthy range', () {
      test(
        'should trigger confetti when recovering from above healthy to healthy',
        () {
          // Arrange: Previous weight was above healthy, new weight is healthy
          final BodyWeight previousEntry = BodyWeight(
            id: 1,
            weight: 85.0, // Above healthy
            date: DateTime.now().subtract(const Duration(days: 1)),
          );

          final DetailsSubmittedState detailsState = DetailsSubmittedState(
            userDetails: testUserDetails,
            bodyWeight: 85.0,
            bodyWeightEntries: <BodyWeight>[previousEntry],
            foodEntries: const <FoodWeight>[],
            language: Language.en,
            hasWeightIncreaseProof: false,
            date: DateTime.now().subtract(const Duration(days: 1)),
            portionControl: constants.kMaxDailyFoodLimit,
            yesterdayConsumedTotal: 0,
          );

          final BodyWeightSubmittedState currentState =
              BodyWeightSubmittedState(
                userDetails: testUserDetails,
                bodyWeight: 72.0, // Now healthy
                bodyWeightEntries: <BodyWeight>[previousEntry],
                foodEntries: const <FoodWeight>[],
                language: Language.en,
                hasWeightIncreaseProof: false,
                date: DateTime.now(),
                portionControl: constants.kMaxDailyFoodLimit,
                yesterdayConsumedTotal: 0,
                isConfirmedAllMealsLogged: false,
              );

          // Act
          final bool shouldTrigger = shouldTriggerConfetti(
            previousState: detailsState,
            currentState: currentState,
          );

          // Assert
          expect(shouldTrigger, isTrue);
        },
      );

      test('should NOT trigger confetti when staying above '
          'healthy range', () {
        // Arrange: Both previous and current weights are above healthy
        final BodyWeight previousEntry = BodyWeight(
          id: 1,
          weight: 90.0, // Above healthy
          date: DateTime.now().subtract(const Duration(days: 1)),
        );

        final DetailsSubmittedState detailsState = DetailsSubmittedState(
          userDetails: testUserDetails,
          bodyWeight: 90.0,
          bodyWeightEntries: <BodyWeight>[previousEntry],
          foodEntries: const <FoodWeight>[],
          language: Language.en,
          hasWeightIncreaseProof: false,
          date: DateTime.now().subtract(const Duration(days: 1)),
          portionControl: constants.kMaxDailyFoodLimit,
          yesterdayConsumedTotal: 0,
        );

        final BodyWeightSubmittedState currentState = BodyWeightSubmittedState(
          userDetails: testUserDetails,
          bodyWeight: 88.0, // Still above healthy
          bodyWeightEntries: <BodyWeight>[previousEntry],
          foodEntries: const <FoodWeight>[],
          language: Language.en,
          hasWeightIncreaseProof: false,
          date: DateTime.now(),
          portionControl: constants.kMaxDailyFoodLimit,
          yesterdayConsumedTotal: 0,
          isConfirmedAllMealsLogged: false,
        );

        // Act
        final bool shouldTrigger = shouldTriggerConfetti(
          previousState: detailsState,
          currentState: currentState,
        );

        // Assert
        expect(shouldTrigger, isFalse);
      });

      test('should NOT trigger confetti when healthy weight '
          'stays healthy', () {
        // Arrange: Both weights are healthy
        final BodyWeight previousEntry = BodyWeight(
          id: 1,
          weight: 72.0, // Healthy
          date: DateTime.now().subtract(const Duration(days: 1)),
        );

        final DetailsSubmittedState detailsState = DetailsSubmittedState(
          userDetails: testUserDetails,
          bodyWeight: 72.0,
          bodyWeightEntries: <BodyWeight>[previousEntry],
          foodEntries: const <FoodWeight>[],
          language: Language.en,
          hasWeightIncreaseProof: false,
          date: DateTime.now().subtract(const Duration(days: 1)),
          portionControl: constants.kMaxDailyFoodLimit,
          yesterdayConsumedTotal: 0,
        );

        final BodyWeightSubmittedState currentState = BodyWeightSubmittedState(
          userDetails: testUserDetails,
          bodyWeight: 71.0, // Still healthy
          bodyWeightEntries: <BodyWeight>[previousEntry],
          foodEntries: const <FoodWeight>[],
          language: Language.en,
          hasWeightIncreaseProof: false,
          date: DateTime.now(),
          portionControl: constants.kMaxDailyFoodLimit,
          yesterdayConsumedTotal: 0,
          isConfirmedAllMealsLogged: false,
        );

        // Act
        final bool shouldTrigger = shouldTriggerConfetti(
          previousState: detailsState,
          currentState: currentState,
        );

        // Assert
        expect(shouldTrigger, isFalse);
      });
    });

    group('Scenario 3: First crossing from above midpoint '
        'to below midpoint', () {
      test(
        'should trigger confetti when crossing midpoint for the first time',
        () {
          // Arrange: Previous weight above midpoint,
          // new weight below midpoint, no prior entries below
          final BodyWeight previousEntry = BodyWeight(
            id: 1,
            weight: 70.0, // Above midpoint
            date: DateTime.now().subtract(const Duration(days: 1)),
          );

          final DetailsSubmittedState detailsState = DetailsSubmittedState(
            userDetails: testUserDetails,
            bodyWeight: 70.0,
            bodyWeightEntries: <BodyWeight>[previousEntry],
            foodEntries: const <FoodWeight>[],
            language: Language.en,
            hasWeightIncreaseProof: false,
            date: DateTime.now().subtract(const Duration(days: 1)),
            portionControl: constants.kMaxDailyFoodLimit,
            yesterdayConsumedTotal: 0,
          );

          final BodyWeightSubmittedState currentState =
              BodyWeightSubmittedState(
                userDetails: testUserDetails,
                bodyWeight: 62.0, // Below midpoint for first time
                bodyWeightEntries: <BodyWeight>[previousEntry],
                foodEntries: const <FoodWeight>[],
                language: Language.en,
                hasWeightIncreaseProof: false,
                date: DateTime.now(),
                portionControl: constants.kMaxDailyFoodLimit,
                yesterdayConsumedTotal: 0,
                isConfirmedAllMealsLogged: false,
              );

          // Act
          final bool shouldTrigger = shouldTriggerConfetti(
            previousState: detailsState,
            currentState: currentState,
          );

          // Assert
          expect(shouldTrigger, isTrue);
        },
      );

      test(
        'should NOT trigger confetti when crossing midpoint '
        'after already being below',
        () {
          // Arrange: Has previous below-midpoint entry,
          // not first crossing
          final BodyWeight entryBelowMidpoint = BodyWeight(
            id: 1,
            weight: 61.0, // Below midpoint (midpoint is ~63.5 for 171cm)
            date: DateTime.now().subtract(const Duration(days: 3)),
          );
          final BodyWeight entryAboveMidpoint = BodyWeight(
            id: 2,
            weight: 70.0, // Above midpoint
            date: DateTime.now().subtract(const Duration(days: 1)),
          );

          final DetailsSubmittedState detailsState = DetailsSubmittedState(
            userDetails: testUserDetails,
            bodyWeight: 70.0,
            bodyWeightEntries: <BodyWeight>[
              entryBelowMidpoint,
              entryAboveMidpoint,
            ],
            foodEntries: const <FoodWeight>[],
            language: Language.en,
            hasWeightIncreaseProof: false,
            date: DateTime.now().subtract(const Duration(days: 1)),
            portionControl: constants.kMaxDailyFoodLimit,
            yesterdayConsumedTotal: 0,
          );

          final BodyWeightSubmittedState currentState =
              BodyWeightSubmittedState(
                userDetails: testUserDetails,
                bodyWeight: 62.0, // Below midpoint again, but not first time
                bodyWeightEntries: <BodyWeight>[
                  entryBelowMidpoint,
                  entryAboveMidpoint,
                ],
                foodEntries: const <FoodWeight>[],
                language: Language.en,
                hasWeightIncreaseProof: false,
                date: DateTime.now(),
                portionControl: constants.kMaxDailyFoodLimit,
                yesterdayConsumedTotal: 0,
                isConfirmedAllMealsLogged: false,
              );

          // Act
          final bool shouldTrigger = shouldTriggerConfetti(
            previousState: detailsState,
            currentState: currentState,
          );

          // Assert
          expect(shouldTrigger, isFalse);
        },
      );

      test('should NOT trigger confetti when staying above midpoint', () {
        // Arrange: Both weights above midpoint (70kg and 68kg both > 63.5kg)
        final BodyWeight previousEntry = BodyWeight(
          id: 1,
          weight: 70.0, // Above midpoint
          date: DateTime.now().subtract(const Duration(days: 1)),
        );

        final DetailsSubmittedState detailsState = DetailsSubmittedState(
          userDetails: testUserDetails,
          bodyWeight: 70.0,
          bodyWeightEntries: <BodyWeight>[previousEntry],
          foodEntries: const <FoodWeight>[],
          language: Language.en,
          hasWeightIncreaseProof: false,
          date: DateTime.now().subtract(const Duration(days: 1)),
          portionControl: constants.kMaxDailyFoodLimit,
          yesterdayConsumedTotal: 0,
        );

        final BodyWeightSubmittedState currentState = BodyWeightSubmittedState(
          userDetails: testUserDetails,
          bodyWeight: 68.0, // Still above midpoint
          bodyWeightEntries: <BodyWeight>[previousEntry],
          foodEntries: const <FoodWeight>[],
          language: Language.en,
          hasWeightIncreaseProof: false,
          date: DateTime.now(),
          portionControl: constants.kMaxDailyFoodLimit,
          yesterdayConsumedTotal: 0,
          isConfirmedAllMealsLogged: false,
        );

        // Act
        final bool shouldTrigger = shouldTriggerConfetti(
          previousState: detailsState,
          currentState: currentState,
        );

        // Assert
        expect(shouldTrigger, isFalse);
      });

      test(
        'should NOT trigger confetti when already below '
        'midpoint stays below',
        () {
          // Arrange: Both weights below midpoint (61kg and 60kg both < 63.5kg)
          final BodyWeight previousEntry = BodyWeight(
            id: 1,
            weight: 61.0, // Below midpoint
            date: DateTime.now().subtract(const Duration(days: 1)),
          );

          final DetailsSubmittedState detailsState = DetailsSubmittedState(
            userDetails: testUserDetails,
            bodyWeight: 61.0,
            bodyWeightEntries: <BodyWeight>[previousEntry],
            foodEntries: const <FoodWeight>[],
            language: Language.en,
            hasWeightIncreaseProof: false,
            date: DateTime.now().subtract(const Duration(days: 1)),
            portionControl: constants.kMaxDailyFoodLimit,
            yesterdayConsumedTotal: 0,
          );

          final BodyWeightSubmittedState currentState =
              BodyWeightSubmittedState(
                userDetails: testUserDetails,
                bodyWeight: 60.0, // Still below midpoint
                bodyWeightEntries: <BodyWeight>[previousEntry],
                foodEntries: const <FoodWeight>[],
                language: Language.en,
                hasWeightIncreaseProof: false,
                date: DateTime.now(),
                portionControl: constants.kMaxDailyFoodLimit,
                yesterdayConsumedTotal: 0,
                isConfirmedAllMealsLogged: false,
              );

          // Act
          final bool shouldTrigger = shouldTriggerConfetti(
            previousState: detailsState,
            currentState: currentState,
          );

          // Assert
          expect(shouldTrigger, isFalse);
        },
      );
    });

    group('Edge cases and combined scenarios', () {
      test(
        'should NOT trigger confetti when previous state '
        'is not DetailsSubmittedState',
        () {
          // Arrange: Non-DetailsSubmittedState as previous
          final BodyWeightSubmittedState currentState =
              BodyWeightSubmittedState(
                userDetails: testUserDetails,
                bodyWeight: 70.0,
                bodyWeightEntries: const <BodyWeight>[],
                foodEntries: const <FoodWeight>[],
                language: Language.en,
                hasWeightIncreaseProof: false,
                date: DateTime.now(),
                portionControl: constants.kMaxDailyFoodLimit,
                yesterdayConsumedTotal: 0,
                isConfirmedAllMealsLogged: false,
              );

          // Act - using non-DetailsSubmittedState
          final bool shouldTrigger = shouldTriggerConfetti(
            previousState: null,
            currentState: currentState,
          );

          // Assert
          expect(shouldTrigger, isFalse);
        },
      );

      test(
        'should NOT trigger confetti when current state '
        'is not BodyWeightSubmittedState',
        () {
          // Arrange: DetailsSubmittedState as previous and current
          final DetailsSubmittedState detailsState = DetailsSubmittedState(
            userDetails: testUserDetails,
            bodyWeight: 70.0,
            bodyWeightEntries: const <BodyWeight>[],
            foodEntries: const <FoodWeight>[],
            language: Language.en,
            hasWeightIncreaseProof: false,
            date: DateTime.now(),
            portionControl: constants.kMaxDailyFoodLimit,
            yesterdayConsumedTotal: 0,
          );

          // Act - using DetailsSubmittedState as current
          final bool shouldTrigger = shouldTriggerConfetti(
            previousState: detailsState,
            currentState: detailsState,
          );

          // Assert
          expect(shouldTrigger, isFalse);
        },
      );

      test(
        'should trigger confetti when recovering to healthy '
        'AND crossing midpoint',
        () {
          // Arrange: Both recovery and midpoint conditions met
          final BodyWeight previousEntry = BodyWeight(
            id: 1,
            weight: 85.0, // Above healthy AND above midpoint
            date: DateTime.now().subtract(const Duration(days: 1)),
          );

          final DetailsSubmittedState detailsState = DetailsSubmittedState(
            userDetails: testUserDetails,
            bodyWeight: 85.0,
            bodyWeightEntries: <BodyWeight>[previousEntry],
            foodEntries: const <FoodWeight>[],
            language: Language.en,
            hasWeightIncreaseProof: false,
            date: DateTime.now().subtract(const Duration(days: 1)),
            portionControl: constants.kMaxDailyFoodLimit,
            yesterdayConsumedTotal: 0,
          );

          final BodyWeightSubmittedState currentState =
              BodyWeightSubmittedState(
                userDetails: testUserDetails,
                bodyWeight: 62.0, // Below midpoint (first time)
                bodyWeightEntries: <BodyWeight>[previousEntry],
                foodEntries: const <FoodWeight>[],
                language: Language.en,
                hasWeightIncreaseProof: false,
                date: DateTime.now(),
                portionControl: constants.kMaxDailyFoodLimit,
                yesterdayConsumedTotal: 0,
                isConfirmedAllMealsLogged: false,
              );

          // Act
          final bool shouldTrigger = shouldTriggerConfetti(
            previousState: detailsState,
            currentState: currentState,
          );

          // Assert - should trigger because of recovery to healthy
          expect(shouldTrigger, isTrue);
        },
      );
    });
  });
}
