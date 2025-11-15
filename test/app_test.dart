import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nested/nested.dart';
import 'package:portion_control/app.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/application_services/blocs/onboarding/onboarding_bloc.dart';
import 'package:portion_control/di/dependencies.dart';
import 'package:portion_control/di/dependencies_scope.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/database.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/infrastructure/repositories/settings_repository.dart';
import 'package:portion_control/localization/localization_delegate_getter.dart'
    as localization;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/services/home_widget_service.dart';
import 'package:portion_control/ui/feedback/feedback_form.dart';
import 'package:portion_control/ui/home/home_page.dart';
import 'package:portion_control/ui/landing/landing_page.dart';
import 'package:portion_control/ui/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/translate_test_helper.dart';
import 'mock_interactors.dart';
import 'mock_repositories.dart';
import 'mocks/mock_services.dart';

void main() {
  group('App Tests', () {
    late MockBodyWeightRepository mockBodyWeightRepository;
    late MockFoodWeightRepository mockFoodWeightRepository;
    late MockUserDetailsRepository mockUserDetailsRepository;
    late MockClearTrackingDataUseCase mockClearTrackingDataUseCase;
    late LocalDataSource localDataSource;
    late LocalizationDelegate localizationDelegate;
    late SettingsRepository settingsRepository;
    late HomeWidgetService mockHomeWidgetService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Initialize mocks
      mockBodyWeightRepository = MockBodyWeightRepository();
      mockFoodWeightRepository = MockFoodWeightRepository();
      mockUserDetailsRepository = MockUserDetailsRepository();
      mockClearTrackingDataUseCase = MockClearTrackingDataUseCase();
      mockHomeWidgetService = MockHomeWidgetService();

      // Set up SharedPreferences
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      // Initialize database and data source
      final AppDatabase appDatabase = AppDatabase();
      localDataSource = LocalDataSource(preferences, appDatabase);

      // Set up localization
      await setUpFlutterTranslateForTests();
      localizationDelegate = await localization.getLocalizationDelegate(
        localDataSource,
      );

      // Initialize repositories
      settingsRepository = SettingsRepository(localDataSource);
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
                final String savedIsoCode = localDataSource
                    .getLanguageIsoCode();
                final Language savedLanguage = Language.fromIsoLanguageCode(
                  savedIsoCode,
                );

                return OnboardingBloc(
                  dependencies.saveLanguageUseCase,
                  savedLanguage,
                );
              },
              child: OnboardingScreen(localDataSource: localDataSource),
            );
          },
          AppRoute.landing.path: (_) {
            return LandingPage(localDataSource: localDataSource);
          },
          AppRoute.home.path: (_) => HomePage(localDataSource: localDataSource),
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
                        localDataSource,
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
                        localDataSource,
                      );
                    },
                  ),
                ],
                child: DependenciesScope(
                  dependencies: Dependencies(localDataSource),
                  child: App(
                    routeMap: testRoutes,
                    localDataSource: localDataSource,
                  ),
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
          reason: 'HomePage should be present',
        );
      },
    );
  });
}
