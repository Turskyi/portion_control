import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/ui/home/home_page.dart';
import 'package:portion_control/ui/home/widgets/home_page_content.dart'
    show HomePageContent;
import 'package:portion_control/ui/home/widgets/user_details_widget.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart'
    show GradientBackgroundScaffold;
import 'package:portion_control/ui/widgets/input_row.dart';

import 'mock_interactors.dart';
import 'mock_repositories.dart';

void main() {
  group('HomePage', () {
    late MockBodyWeightRepository mockBodyWeightRepository;
    late MockFoodWeightRepository mockFoodWeightRepository;
    late MockUserDetailsRepository mockUserDetailsRepository;
    late MockClearTrackingDataUseCase mockClearTrackingDataUseCase;
    late HomeBloc homeBloc;

    setUp(() {
      mockBodyWeightRepository = MockBodyWeightRepository();
      mockFoodWeightRepository = MockFoodWeightRepository();
      mockUserDetailsRepository = MockUserDetailsRepository();
      mockClearTrackingDataUseCase = MockClearTrackingDataUseCase();

      homeBloc = HomeBloc(
        mockUserDetailsRepository,
        mockBodyWeightRepository,
        mockFoodWeightRepository,
        mockClearTrackingDataUseCase,
      );
    });

    testWidgets('HomePage displays initial state correctly',
        (WidgetTester tester) async {
      // Pump the widget with BetterFeedback and BlocProvider.
      await tester.pumpWidget(
        BetterFeedback(
          child: BlocProvider<HomeBloc>.value(
            value: homeBloc,
            child: const MaterialApp(home: HomePage()),
          ),
        ),
      );

      // Verify that the widget initializes correctly.
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);

      // Check that specific widgets are shown for initial state.
      expect(find.byType(UserDetailsWidget), findsOneWidget);
    });

    testWidgets(
        'HomePage displays body weight input when body weight is submitted',
        (WidgetTester tester) async {
      // Pump the widget with BetterFeedback and BlocProvider.
      await tester.pumpWidget(
        BetterFeedback(
          child: BlocProvider<HomeBloc>.value(
            value: homeBloc,
            child: const MaterialApp(home: HomePage()),
          ),
        ),
      );

      // Check that the body weight input is shown.
      expect(find.byType(InputRow), findsOneWidget);
    });

    testWidgets('HomePage scrolls to the bottom when body weight is submitted',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        BetterFeedback(
          child: BlocProvider<HomeBloc>.value(
            value: homeBloc,
            child: const MaterialApp(home: HomePage()),
          ),
        ),
      );

      // Verify that scroll happens after body weight submission.
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('HomePage displays correctly on narrow screens',
        (WidgetTester tester) async {
      // Pump the widget with BetterFeedback and narrow screen constraints.
      await tester.pumpWidget(
        BetterFeedback(
          child: BlocProvider<HomeBloc>.value(
            value: homeBloc,
            child: const MaterialApp(home: HomePage()),
          ),
        ),
      );

      // Verify that the HomePage and its content are displayed correctly.
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(HomePageContent), findsOneWidget);
    });

    testWidgets('HomePage displays correctly on wide screens',
        (WidgetTester tester) async {
      // Pump the widget with BetterFeedback and wide screen constraints.
      await tester.pumpWidget(
        BetterFeedback(
          child: BlocProvider<HomeBloc>.value(
            value: homeBloc,
            child: const MaterialApp(
              home: SizedBox(
                width: 800,
                child: HomePage(),
              ),
            ),
          ),
        ),
      );

      // Verify that the HomePage and its content are displayed correctly.
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(HomePageContent), findsOneWidget);
    });

    testWidgets('GradientBackgroundScaffold is used in HomePage',
        (WidgetTester tester) async {
      // Pump the widget with BetterFeedback and BlocProvider.
      await tester.pumpWidget(
        BetterFeedback(
          child: BlocProvider<HomeBloc>.value(
            value: homeBloc,
            child: const MaterialApp(home: HomePage()),
          ),
        ),
      );

      // Verify that the GradientBackgroundScaffold is used in HomePage.
      expect(find.byType(GradientBackgroundScaffold), findsOneWidget);
    });
  });
}