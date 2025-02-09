import 'package:mocktail/mocktail.dart';
import 'package:portion_control/infrastructure/repositories/body_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/food_weight_repository.dart';
import 'package:portion_control/infrastructure/repositories/tracking_repository.dart';
import 'package:portion_control/infrastructure/repositories/user_details_repository.dart';

class MockBodyWeightRepository extends Mock implements BodyWeightRepository {}

class MockFoodWeightRepository extends Mock implements FoodWeightRepository {}

class MockUserDetailsRepository extends Mock implements UserDetailsRepository {}

class MockTrackingRepository extends Mock implements TrackingRepository {}
