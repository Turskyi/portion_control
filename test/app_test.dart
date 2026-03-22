import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nested/nested.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portion_control/app.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/application_services/blocs/onboarding/onboarding_bloc.dart';
import 'package:portion_control/application_services/blocs/settings/settings_bloc.dart';
import 'package:portion_control/di/dependencies.dart';
import 'package:portion_control/di/dependencies_scope.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/database.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/infrastructure/repositories/settings_repository.dart';
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/services/feedback_email_service.dart';
import 'package:portion_control/services/home_widget_service.dart';
import 'package:portion_control/ui/feedback/feedback_form.dart';
import 'package:portion_control/ui/home/home_page.dart';
import 'package:portion_control/ui/landing/landing_page.dart';
import 'package:portion_control/ui/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'helpers/test_database.dart' as test_database;
import 'helpers/translate_test_helper.dart';
import 'mock_interactors.dart';
import 'mock_repositories.dart';
import 'mocks/mock_services.dart';

void main() {
  group('App Tests', () {
    late MockBodyWeightRepository mockBodyWeightRepository;
    late MockFoodWeightRepository mockFoodWeightRepository;
    late MockUserDetailsRepository mockUserDetailsRepository;
    late MockCalculatePortionControlUseCase mockCalculatePortionControlUseCase;
    late MockClearTrackingDataUseCase mockClearTrackingDataUseCase;
    late LocalDataSource localDataSource;
    late SharedPreferences preferences;
    late LocalizationDelegate localizationDelegate;
    late SettingsRepository settingsRepository;
    late SettingsBloc settingsBloc;
    late HomeWidgetService mockHomeWidgetService;
    late FeedbackEmailService mockFeedbackEmailService;
    late AppDatabase database;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mock PackageInfo
      PackageInfo.setMockInitialValues(
        appName: 'Portion Control',
        packageName: 'com.example.portion_control',
        version: '1.1.9',
        buildNumber: '19',
        buildSignature: '',
      );

      database = await test_database.init();
      SharedPreferences.setMockInitialValues(<String, Object>{});

      // Initialize mocks
      mockBodyWeightRepository = MockBodyWeightRepository();
      mockFoodWeightRepository = MockFoodWeightRepository();
      mockUserDetailsRepository = MockUserDetailsRepository();
      mockCalculatePortionControlUseCase = MockCalculatePortionControlUseCase();
      mockClearTrackingDataUseCase = MockClearTrackingDataUseCase();
      mockHomeWidgetService = MockHomeWidgetService();
      mockFeedbackEmailService = MockFeedbackEmailService();

      // Set up default mock behavior
      when(
        () => mockUserDetailsRepository.getLanguage(),
      ).thenReturn(Language.en);
      when(
        () => mockUserDetailsRepository.getLastPortionControl(),
      ).thenReturn(2000.0);
      when(
        () => mockUserDetailsRepository.getUserDetails(),
      ).thenReturn(const UserDetails.empty());
      when(
        () => mockCalculatePortionControlUseCase.call(),
      ).thenAnswer((_) async => 2000.0);

      // Set up SharedPreferences
      preferences = await SharedPreferences.getInstance();

      // Initialize database and data source
      localDataSource = LocalDataSource(preferences, database);

      // Set up localization
      localizationDelegate = await setUpFlutterTranslateForTests();

      // Initialize repositories
      settingsRepository = SettingsRepository(localDataSource);
      settingsBloc = SettingsBloc(settingsRepository, mockFeedbackEmailService);
    });

    tearDown(() async {
      await settingsBloc.close();
      await database.close();
    });

    testWidgets(
      'App initializes and shows OnboardingScreen for the first launch',
      (
        WidgetTester tester,
      ) async {
        // Create route map
        final Map<String, WidgetBuilder> testRoutes = <String, WidgetBuilder>{
          AppRoute.onboarding.path: (BuildContext _) {
            return BlocProvider<OnboardingBloc>(
              create: (BuildContext context) {
                final Dependencies dependencies = DependenciesScope.of(context);

                return OnboardingBloc(
                  dependencies.saveLanguageUseCase,
                  localDataSource,
                );
              },
              child: const OnboardingScreen(),
            );
          },
          AppRoute.landing.path: (_) {
            return BlocProvider<SettingsBloc>(
              create: (_) => SettingsBloc(
                settingsRepository,
                mockFeedbackEmailService,
              ),
              child: const LandingPage(),
            );
          },
          AppRoute.home.path: (_) => MultiBlocProvider(
            providers: <SingleChildWidget>[
              BlocProvider<SettingsBloc>.value(value: settingsBloc),
            ],
            child: const HomePage(),
          ),
        };

        // Build widget tree
        await tester.pumpWidget(
          LocalizedApp(
            localizationDelegate,
            BetterFeedback(
              feedbackBuilder:
                  (_, OnSubmit onSubmit, ScrollController? scrollController) =>
                      FeedbackForm(
                        onSubmit: onSubmit,
                        scrollController: scrollController,
                      ),
              child: MultiBlocProvider(
                providers: <SingleChildWidget>[
                  BlocProvider<HomeBloc>(
                    create: (BuildContext _) {
                      return HomeBloc(
                        mockUserDetailsRepository,
                        mockBodyWeightRepository,
                        mockFoodWeightRepository,
                        mockClearTrackingDataUseCase,
                        mockHomeWidgetService,
                        mockFeedbackEmailService,
                      );
                    },
                  ),
                  BlocProvider<MenuBloc>(
                    create: (BuildContext _) {
                      return MenuBloc(
                        settingsRepository,
                        mockHomeWidgetService,
                        mockBodyWeightRepository,
                        mockFoodWeightRepository,
                        mockUserDetailsRepository,
                        mockFeedbackEmailService,
                        mockCalculatePortionControlUseCase,
                      );
                    },
                  ),
                ],
                child: DependenciesScope(
                  dependencies: Dependencies(
                    localDataSource,
                    preferences,
                    localizationDelegate,
                  ),
                  child: App(routeMap: testRoutes),
                ),
              ),
            ),
          ),
        );

        // Initial frame
        await tester.pump();

        // Pump a few frames with delay to allow for initialization
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Verify widgets
        expect(
          find.byType(MaterialApp),
          findsOneWidget,
          reason: 'MaterialApp should be present',
        );
        expect(
          find.byType(OnboardingScreen),
          findsOneWidget,
          reason: 'OnboardingScreen should be present',
        );

        // Confirm that onboarding now has 4 pages
        // (so users see the local-storage note).
        final SmoothPageIndicator indicator = tester.widget(
          find.byType(SmoothPageIndicator),
        );
        expect(indicator.count, 4);
      },
    );
    group('MenuBloc Tests', () {
      test('MenuBloc initializes with correct state', () {
        final MenuBloc menuBloc = MenuBloc(
          settingsRepository,
          mockHomeWidgetService,
          mockBodyWeightRepository,
          mockFoodWeightRepository,
          mockUserDetailsRepository,
          mockFeedbackEmailService,
          mockCalculatePortionControlUseCase,
        );

        expect(menuBloc.state, isA<LoadingMenuState>());
        expect(menuBloc.state.language, Language.en);
      });
    });
  });
}
