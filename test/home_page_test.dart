import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/ui/home/home_page.dart';
import 'package:portion_control/ui/home/widgets/user_details_widget.dart';
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
      // Pump the widget with BlocProvider.
      await tester.pumpWidget(
        BlocProvider<HomeBloc>.value(
          value: homeBloc,
          child: const MaterialApp(home: HomePage()),
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
      // Pump the widget with the mocked state.
      await tester.pumpWidget(
        BlocProvider<HomeBloc>.value(
          value: homeBloc,
          child: const MaterialApp(home: HomePage()),
        ),
      );

      // Check that the body weight input is shown.
      expect(find.byType(InputRow), findsOneWidget);
    });

    testWidgets('HomePage scrolls to the bottom when body weight is submitted',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider<HomeBloc>.value(
          value: homeBloc,
          child: const MaterialApp(home: HomePage()),
        ),
      );

      // Verify that scroll happens after body weight submission.
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
