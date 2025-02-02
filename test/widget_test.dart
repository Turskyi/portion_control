import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portion_control/application_services/blocs/home_bloc.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/infrastructure/repositories/body_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/food_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/user_details_repository.dart';
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/app.dart';
import 'package:portion_control/ui/home/home_page.dart';

class MockBodyWeightRepository extends Mock implements BodyWeightRepository {}

class MockFoodWeightRepository extends Mock implements FoodWeightRepository {}

class MockUserDetailsRepository extends Mock implements UserDetailsRepository {}

void main() {
  testWidgets('HomePage has correct layout and placeholders',
      (WidgetTester tester) async {
    // Create a mock instance of BodyWeightRepository.
    final MockBodyWeightRepository mockBodyWeightRepository =
        MockBodyWeightRepository();
    final MockFoodWeightRepository mockFoodWeightRepository =
        MockFoodWeightRepository();
    final MockUserDetailsRepository mockUserDetailsRepository =
        MockUserDetailsRepository();

    // Stub the `loadBodyWeightEntries` call to return an empty list or desired
    // data.
    when(() => mockBodyWeightRepository.getAllBodyWeightEntries())
        .thenAnswer((_) async => <BodyWeight>[]);

    // Stub the `loadFoodWeightEntries` call to return an empty list or desired
    // data.
    when(() => mockFoodWeightRepository.getAllFoodWeightEntries())
        .thenAnswer((_) async => <FoodWeight>[]);

    // Define routeMap with the mock repository
    final Map<String, WidgetBuilder> routeMap = <String, WidgetBuilder>{
      AppRoute.home.path: (_) => BlocProvider<HomeBloc>(
            create: (_) => HomeBloc(
              mockUserDetailsRepository,
              mockBodyWeightRepository,
              mockFoodWeightRepository,
            )..add(const LoadEntries()),
            child: const HomePage(),
          ),
    };

    // Build the app with the mock repository
    await tester.pumpWidget(App(routeMap: routeMap));

    // Verify the "Enter Your Details" text is present
    expect(find.text('Enter Your Details'), findsOneWidget);

    // Verify the text next to input fields
    expect(find.text('kg'), findsOneWidget);
  });
}
