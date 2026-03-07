import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;

import '../../../dummy_constants.dart' as dummy;
import '../../../helpers/translate_test_helper.dart' as helper;
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

  setUpAll(() async {
    registerFallbackValue(DateTime.now());
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('uk', null);
  });

  setUp(() async {
    mockUserPreferencesRepository = MockUserDetailsRepository();
    mockBodyWeightRepository = MockBodyWeightRepository();
    mockFoodWeightRepository = MockFoodWeightRepository();
    mockClearTrackingDataUseCase = MockClearTrackingDataUseCase();
    mockHomeWidgetService = MockHomeWidgetService();

    // Initialize localization for tests.
    await helper.setUpFlutterTranslateForTests();

    // Default mock behaviors.
    when(
      () => mockUserPreferencesRepository.getLanguage(),
    ).thenReturn(Language.en);
    when(
      () => mockUserPreferencesRepository.getLanguageIsoCode(),
    ).thenReturn(Language.en.isoLanguageCode);
    when(() => mockUserPreferencesRepository.getUserDetails()).thenReturn(
      UserDetails(
        heightInCm: dummy.dummyHeightInCm,
        gender: Gender.male,
        dateOfBirth: dummy.dummyDateOfBirth,
      ),
    );
    when(
      () => mockUserPreferencesRepository.getLastPortionControl(),
    ).thenReturn(constants.kMaxDailyFoodLimit);
    when(
      () => mockUserPreferencesRepository.isWeightReminderEnabled(),
    ).thenReturn(false);
    when(
      () => mockUserPreferencesRepository.savePortionControl(any()),
    ).thenAnswer((_) async => true);

    when(
      () => mockHomeWidgetService.setAppGroupId(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockHomeWidgetService.saveWidgetData<String>(any(), any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockHomeWidgetService.updateWidget(
        name: any(named: 'name'),
        iOSName: any(named: 'iOSName'),
        androidName: any(named: 'androidName'),
      ),
    ).thenAnswer((_) async => null);

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
      'should fallback to max limit (constants.kMaxDailyFoodLimit) when no '
      'weight increase proof exists',
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
          () {
            return mockUserPreferencesRepository
                .getMinConsumptionWhenWeightIncreased();
          },
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
          () {
            return mockUserPreferencesRepository
                .getMinConsumptionWhenWeightIncreased();
          },
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

    test(
      'should set portionControl to yesterday\'s consumption when weight '
      'increases for the first time and is above healthy',
      () async {
        // GIVEN:
        // Yesterday weight was 73.9.
        when(
          () => mockBodyWeightRepository.getAllBodyWeightEntries(),
        ).thenAnswer(
          (_) async => <BodyWeight>[
            BodyWeight(
              id: 1,
              weight: dummy.dummyWeightYesterday,
              date: yesterday,
            ),
          ],
        );
        when(
          () => mockBodyWeightRepository.getTodayBodyWeight(),
        ).thenAnswer((_) async => BodyWeight.empty());

        // Yesterday consumption was 1241.0.
        when(
          () => mockFoodWeightRepository.getTotalConsumedYesterday(),
        ).thenAnswer((_) async => dummy.dummyConsumedYesterday);

        // When we submit today's weight (74.0 kg).
        // With height 171 cm, BMI is ~25.3 (> 24.9 healthy limit).
        when(
          () => mockBodyWeightRepository.addOrUpdateBodyWeightEntry(
            weight: any(named: 'weight'),
            date: any(named: 'date'),
          ),
        ).thenAnswer((_) async => 2);

        // After update, repository returns both entries.
        when(
          () => mockBodyWeightRepository.getAllBodyWeightEntries(),
        ).thenAnswer(
          (_) async => <BodyWeight>[
            BodyWeight(
              id: 1,
              weight: dummy.dummyWeightYesterday,
              date: yesterday,
            ),
            BodyWeight(id: 2, weight: dummy.dummyWeightToday, date: today),
          ],
        );

        when(() => mockBodyWeightRepository.getTodayBodyWeight()).thenAnswer(
          (_) async =>
              BodyWeight(id: 2, weight: dummy.dummyWeightToday, date: today),
        );

        // Repository now reflects the new "min consumption when weight
        // increased" proof.
        when(
          () => mockUserPreferencesRepository
              .getMinConsumptionWhenWeightIncreased(),
        ).thenAnswer((_) async => dummy.dummyConsumedYesterday);

        when(
          () => mockUserPreferencesRepository.getLastPortionControl(),
        ).thenReturn(constants.kMaxDailyFoodLimit);

        when(
          () => mockFoodWeightRepository.getTodayFoodEntries(),
        ).thenAnswer((_) async => <FoodWeight>[]);

        when(
          () => mockUserPreferencesRepository.isMealsConfirmedForToday,
        ).thenReturn(false);

        // WHEN:
        // User submits weight (74.0) for today.
        homeBloc.add(const SubmitBodyWeight(dummy.dummyWeightToday));

        // THEN:
        // The resulting state should have the portion control adjusted to
        // yesterday's consumption (1241.0) because weight increased and BMI is
        // overweight.
        await expectLater(
          homeBloc.stream,
          emitsThrough(
            isA<BodyWeightSubmittedState>()
                .having(
                  (BodyWeightSubmittedState s) => s.bodyWeight,
                  'bodyWeight',
                  dummy.dummyWeightToday,
                )
                .having(
                  (BodyWeightSubmittedState s) => s.portionControl,
                  'portionControl',
                  dummy.dummyConsumedYesterday,
                )
                .having(
                  (BodyWeightSubmittedState s) => s.isWeightAboveHealthy,
                  'isWeightAboveHealthy',
                  true,
                )
                .having(
                  (BodyWeightSubmittedState s) => s.isWeightIncreasing,
                  'isWeightIncreasing',
                  true,
                ),
          ),
        );

        // Also verify it was saved to preferences.
        verify(
          () => mockUserPreferencesRepository.savePortionControl(
            dummy.dummyConsumedYesterday,
          ),
        ).called(1);
      },
    );

    test(
      'should set correct portionControl even if submitted quickly after '
      'launch (race condition fix verification)',
      () async {
        // GIVEN:
        // Yesterday consumption was 1241.0.
        when(
          () => mockFoodWeightRepository.getTotalConsumedYesterday(),
        ).thenAnswer((_) async => dummy.dummyConsumedYesterday);
        // Yesterday weight was 73.9.
        when(
          () => mockBodyWeightRepository.getAllBodyWeightEntries(),
        ).thenAnswer(
          (_) async => <BodyWeight>[
            BodyWeight(
              id: 1,
              weight: dummy.dummyWeightYesterday,
              date: yesterday,
            ),
          ],
        );
        when(
          () => mockBodyWeightRepository.getTodayBodyWeight(),
        ).thenAnswer((_) async => BodyWeight.empty());
        when(
          () => mockUserPreferencesRepository
              .getMinConsumptionWhenWeightIncreased(),
        ).thenAnswer((_) async => constants.kMaxDailyFoodLimit);
        when(
          () => mockFoodWeightRepository.getTodayFoodEntries(),
        ).thenAnswer((_) async => <FoodWeight>[]);
        when(
          () => mockUserPreferencesRepository.isMealsConfirmedForToday,
        ).thenReturn(false);

        // WHEN:
        // We start loading, which emits intermediate states with 0 yesterday
        // total.
        homeBloc.add(const LoadEntries());

        // Wait for the intermediate state where yesterdayConsumedTotal is 0.
        await expectLater(
          homeBloc.stream,
          emitsThrough(
            isA<LoadingConsumedYesterdayState>().having(
              (LoadingConsumedYesterdayState s) => s.yesterdayConsumedTotal,
              'yesterdayConsumedTotal',
              0,
            ),
          ),
        );

        // AND: User immediately submits weight (74.0) while
        // `state.yesterdayConsumedTotal` is still 0.
        when(
          () => mockBodyWeightRepository.addOrUpdateBodyWeightEntry(
            weight: any(named: 'weight'),
            date: any(named: 'date'),
          ),
        ).thenAnswer((_) async => 2);

        when(
          () => mockBodyWeightRepository.getAllBodyWeightEntries(),
        ).thenAnswer(
          (_) async => <BodyWeight>[
            BodyWeight(
              id: 1,
              weight: dummy.dummyWeightYesterday,
              date: yesterday,
            ),
            BodyWeight(id: 2, weight: dummy.dummyWeightToday, date: today),
          ],
        );
        when(() => mockBodyWeightRepository.getTodayBodyWeight()).thenAnswer(
          (_) async =>
              BodyWeight(id: 2, weight: dummy.dummyWeightToday, date: today),
        );

        // Repository now has the proof.
        when(
          () => mockUserPreferencesRepository
              .getMinConsumptionWhenWeightIncreased(),
        ).thenAnswer((_) async => dummy.dummyConsumedYesterday);

        homeBloc.add(const SubmitBodyWeight(dummy.dummyWeightToday));

        // THEN:
        // The resulting state should have the correct yesterdayConsumedTotal
        // (1241.0) because _submitBodyWeight now fetches it directly from
        // repository.
        // This ensures adjustedPortion returns 1241.0 instead of falling back
        // to 1200.
        await expectLater(
          homeBloc.stream,
          emitsThrough(
            isA<BodyWeightSubmittedState>()
                .having(
                  (BodyWeightSubmittedState s) => s.yesterdayConsumedTotal,
                  'yesterdayConsumedTotal',
                  dummy.dummyConsumedYesterday,
                )
                .having(
                  (BodyWeightSubmittedState s) => s.adjustedPortion,
                  'adjustedPortion',
                  dummy.dummyConsumedYesterday,
                ),
          ),
        );
      },
    );
  });
}
