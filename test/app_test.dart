import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nested/nested.dart';
import 'package:portion_control/app.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/database.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/infrastructure/repositories/settings_repository.dart';
import 'package:portion_control/localization/localization_delegate_getter.dart'
    as localization;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/feedback/feedback_form.dart';
import 'package:portion_control/ui/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/translate_test_helper.dart';
import 'mock_interactors.dart';
import 'mock_repositories.dart';

void main() {
  group('App Tests', () {
    late MockBodyWeightRepository mockBodyWeightRepository;
    late MockFoodWeightRepository mockFoodWeightRepository;
    late MockUserDetailsRepository mockUserDetailsRepository;
    late MockClearTrackingDataUseCase mockClearTrackingDataUseCase;
    late LocalDataSource localDataSource;
    late LocalizationDelegate localizationDelegate;
    late SettingsRepository settingsRepository;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Initialize mocks
      mockBodyWeightRepository = MockBodyWeightRepository();
      mockFoodWeightRepository = MockFoodWeightRepository();
      mockUserDetailsRepository = MockUserDetailsRepository();
      mockClearTrackingDataUseCase = MockClearTrackingDataUseCase();

      // Set up SharedPreferences
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      // Initialize database and data source
      final AppDatabase appDatabase = AppDatabase();
      localDataSource = LocalDataSource(preferences, appDatabase);

      // Set up localization
      await setUpFlutterTranslateForTests();
      localizationDelegate =
          await localization.getLocalizationDelegate(localDataSource);

      // Initialize repositories
      settingsRepository = SettingsRepository(localDataSource);
    });

    testWidgets('App initializes and shows HomePage',
        (WidgetTester tester) async {
      // Create route map
      final Map<String, WidgetBuilder> testRoutes = <String, WidgetBuilder>{
        '/': (_) => HomePage(localDataSource: localDataSource),
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
                  create: (BuildContext _) => HomeBloc(
                    mockUserDetailsRepository,
                    mockBodyWeightRepository,
                    mockFoodWeightRepository,
                    mockClearTrackingDataUseCase,
                  ),
                ),
                BlocProvider<MenuBloc>(
                  create: (_) => MenuBloc(settingsRepository),
                ),
              ],
              child: App(routeMap: testRoutes),
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
        find.byType(HomePage),
        findsOneWidget,
        reason: 'HomePage should be present',
      );
    });
  });
}
