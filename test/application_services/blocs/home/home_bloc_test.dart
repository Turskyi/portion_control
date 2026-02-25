import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;

import '../../../mock_interactors.dart';
import '../../../mock_repositories.dart';
import '../../../mocks/mock_services.dart';

void main() {
  late HomeBloc homeBloc;
  late MockUserDetailsRepository mockUserPreferencesRepository;
  late MockBodyWeightRepository mockBodyWeightRepository;
  late MockFoodWeightRepository mockFoodWeightRepository;
  late MockClearTrackingDataUseCase mockClearTrackingDataUseCase;
  late MockHomeWidgetService mockHomeWidgetService;

  setUp(() {
    mockUserPreferencesRepository = MockUserDetailsRepository();
    mockBodyWeightRepository = MockBodyWeightRepository();
    mockFoodWeightRepository = MockFoodWeightRepository();
    mockClearTrackingDataUseCase = MockClearTrackingDataUseCase();
    mockHomeWidgetService = MockHomeWidgetService();

    // Default mock behaviors.
    when(
      () => mockUserPreferencesRepository.getLanguage(),
    ).thenReturn(Language.en);
    when(() => mockUserPreferencesRepository.getUserDetails()).thenReturn(
      const UserDetails(
        heightInCm: 180,
        gender: Gender.male,
        dateOfBirth: null,
      ),
    );

    homeBloc = HomeBloc(
      mockUserPreferencesRepository,
      mockBodyWeightRepository,
      mockFoodWeightRepository,
      mockClearTrackingDataUseCase,
      mockHomeWidgetService,
    );
  });

  group('HomeBloc - Weight Increase Proof Logic', () {
    final DateTime today = DateTime.now();
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    test(
      'should fallback to max limit when no weight increase proof exists',
      () async {
        // Data from the screenshot:
        // Yesterday: 75.6kg, Total: 1263g
        // Today: 75.3kg (Weight decreased)
        // Proof: None (Weight hasn't increased yet)

        when(
          () => mockBodyWeightRepository.getTodayBodyWeight(),
        ).thenAnswer((_) async => BodyWeight(id: 1, weight: 75.3, date: today));
        when(
          () => mockFoodWeightRepository.getTotalConsumedYesterday(),
        ).thenAnswer((_) async => 1263.0);
        when(
          () => mockBodyWeightRepository.getAllBodyWeightEntries(),
        ).thenAnswer(
          (_) async => <BodyWeight>[
            BodyWeight(id: 2, weight: 75.6, date: yesterday),
            BodyWeight(id: 1, weight: 75.3, date: today),
          ],
        );
        when(
          () => mockUserPreferencesRepository
              .getMinConsumptionWhenWeightIncreased(),
        ).thenAnswer((_) async => constants.kMaxDailyFoodLimit);
        when(
          () => mockUserPreferencesRepository
              .getMaxConsumptionWhenWeightDecreased(),
        ).thenAnswer((_) async => 1263.0);
        when(
          () => mockUserPreferencesRepository.getLastPortionControl(),
        ).thenReturn(1263.0); // Wrong limit saved previously
        when(
          () => mockFoodWeightRepository.getTodayFoodEntries(),
        ).thenAnswer((_) async => <FoodWeight>[]);
        when(
          () => mockUserPreferencesRepository.isMealsConfirmedForToday,
        ).thenReturn(false);

        // We expect the Bloc to emit states where hasWeightIncreaseProof is
        // false and adjustedPortion is kMaxDailyFoodLimit.
        homeBloc.add(const LoadEntries());

        await expectLater(
          homeBloc.stream,
          emitsThrough(
            isA<BodyWeightSubmittedState>()
                .having(
                  (BodyWeightSubmittedState s) => s.hasWeightIncreaseProof,
                  'hasWeightIncreaseProof',
                  false,
                )
                .having(
                  (BodyWeightSubmittedState s) => s.adjustedPortion,
                  'adjustedPortion',
                  constants.kMaxDailyFoodLimit,
                ),
          ),
        );
      },
    );

    test(
      'should use observed limit when weight increase proof exists',
      () async {
        // Historical data showing a weight increase:
        // Day 1: 75.0kg, ate 1500g
        // Day 2: 75.2kg (Increase!) -> Proof found.

        when(
          () => mockBodyWeightRepository.getTodayBodyWeight(),
        ).thenAnswer((_) async => BodyWeight(id: 1, weight: 75.3, date: today));
        when(
          () => mockFoodWeightRepository.getTotalConsumedYesterday(),
        ).thenAnswer((_) async => 1200.0);
        when(
          () => mockBodyWeightRepository.getAllBodyWeightEntries(),
        ).thenAnswer(
          (_) async => <BodyWeight>[
            BodyWeight(
              id: 3,
              weight: 75.0,
              date: yesterday.subtract(const Duration(days: 1)),
            ),
            BodyWeight(id: 2, weight: 75.2, date: yesterday),
            BodyWeight(id: 1, weight: 75.3, date: today),
          ],
        );
        when(
          () => mockUserPreferencesRepository
              .getMinConsumptionWhenWeightIncreased(),
        ).thenAnswer((_) async => 1500.0);
        when(
          () => mockUserPreferencesRepository.getLastPortionControl(),
        ).thenReturn(1500.0);
        when(
          () => mockFoodWeightRepository.getTodayFoodEntries(),
        ).thenAnswer((_) async => <FoodWeight>[]);
        when(
          () => mockUserPreferencesRepository.isMealsConfirmedForToday,
        ).thenReturn(false);

        homeBloc.add(const LoadEntries());

        await expectLater(
          homeBloc.stream,
          emitsThrough(
            isA<BodyWeightSubmittedState>()
                .having(
                  (BodyWeightSubmittedState s) => s.hasWeightIncreaseProof,
                  'hasWeightIncreaseProof',
                  true,
                )
                .having(
                  (BodyWeightSubmittedState s) => s.adjustedPortion,
                  'adjustedPortion',
                  1500.0,
                ),
          ),
        );
      },
    );
  });
}
