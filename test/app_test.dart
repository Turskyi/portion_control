import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/app.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/localization/localization_delelegate_getter.dart'
    as localization;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/feedback/feedback_form.dart';
import 'package:portion_control/ui/home/home_page.dart';

import 'mock_interactors.dart';
import 'mock_repositories.dart';

void main() {
  testWidgets('App initializes and shows HomePage',
      (WidgetTester tester) async {
    // Create a mock instance of BodyWeightRepository.
    final MockBodyWeightRepository mockBodyWeightRepository =
        MockBodyWeightRepository();
    final MockFoodWeightRepository mockFoodWeightRepository =
        MockFoodWeightRepository();
    final MockUserDetailsRepository mockUserDetailsRepository =
        MockUserDetailsRepository();

    final MockClearTrackingDataUseCase mockClearTrackingDataUseCase =
        MockClearTrackingDataUseCase();

    final LocalizationDelegate localizationDelegate =
        await localization.getLocalizationDelegate();
    // Create a simple route map for testing.
    final Map<String, WidgetBuilder> testRoutes = <String, WidgetBuilder>{
      AppRoute.home.path: (_) => const HomePage(),
    };

    // Provide the HomeBloc using a BlocProvider.
    await tester.pumpWidget(
      LocalizedApp(
        localizationDelegate,
        BetterFeedback(
          feedbackBuilder: (
            _,
            OnSubmit onSubmit,
            ScrollController? scrollController,
          ) =>
              FeedbackForm(
            onSubmit: onSubmit,
            scrollController: scrollController,
          ),
          child: BlocProvider<HomeBloc>(
            create: (_) => HomeBloc(
              mockUserDetailsRepository,
              mockBodyWeightRepository,
              mockFoodWeightRepository,
              mockClearTrackingDataUseCase,
            ),
            child: App(routeMap: testRoutes),
          ),
        ),
      ),
    );

    // Verify that the MaterialApp is present.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that the HomePage is shown.
    expect(find.byType(HomePage), findsOneWidget);
  });
}
