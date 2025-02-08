part of 'home_bloc.dart';

@immutable
sealed class HomeState {
  const HomeState({
    required this.userDetails,
    required this.bodyWeight,
    required this.foodWeight,
    required this.bodyWeightEntries,
    required this.foodEntries,
    required this.portionControl,
  });

  final UserDetails userDetails;
  final double bodyWeight;
  final double foodWeight;
  final List<BodyWeight> bodyWeightEntries;
  final List<FoodWeight> foodEntries;
  final double portionControl;

  bool get isEmptyDetails =>
      userDetails.height == 0 &&
      userDetails.age == 0 &&
      userDetails.gender == Gender.preferNotToSay &&
      userDetails.dateOfBirth == null;

  bool get isNotEmptyDetails => !isEmptyDetails;

  double get height => userDetails.height;

  DateTime? get dateOfBirth => userDetails.dateOfBirth;

  Gender get gender => userDetails.gender;

  int get age => userDetails.age;

  double get totalConsumed => foodEntries.fold(
        0,
        (double sum, FoodWeight entry) => sum + entry.weight,
      );

  bool get hasNoPortionControl =>
      bodyWeightEntries.length == 1 && bodyWeightEntries.first.date.isToday;
}

class HomeLoading extends HomeState {
  const HomeLoading({
    super.userDetails = const UserDetails(
      height: 0,
      gender: Gender.preferNotToSay,
    ),
    super.bodyWeight = 0,
    super.foodWeight = 0,
    super.bodyWeightEntries = const <BodyWeight>[],
    super.foodEntries = const <FoodWeight>[],
    super.portionControl = 0.0,
  });
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.foodWeight,
    required super.portionControl,
  });
}

class HeightUpdatedState extends HomeLoaded {
  const HeightUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    super.foodWeight = 0,
    super.portionControl = 0,
  });
}

class DateOfBirthUpdatedState extends HomeLoaded {
  const DateOfBirthUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    super.foodWeight = 0,
    super.portionControl = 0,
  });
}

class GenderUpdatedState extends HomeLoaded {
  const GenderUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    super.foodWeight = 0,
    super.portionControl = 0,
  });
}

class DetailsSubmittedState extends HomeLoaded {
  const DetailsSubmittedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    super.foodWeight = 0,
    super.portionControl = 0,
  });
}

class BodyWeightUpdatedState extends DetailsSubmittedState {
  const BodyWeightUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    super.foodWeight = 0,
  });
}

class BodyWeightSubmittedState extends DetailsSubmittedState {
  const BodyWeightSubmittedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    super.foodWeight = 0,
  });
}

class FoodWeightUpdateState extends BodyWeightSubmittedState {
  const FoodWeightUpdateState({
    required this.foodEntryId,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.foodWeight,
  });

  final int foodEntryId;
}

class FoodWeightSubmittedState extends BodyWeightSubmittedState {
  const FoodWeightSubmittedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.foodWeight,
    this.foodEntryId,
  });

  final int? foodEntryId;
}

class FoodWeightUpdatedState extends BodyWeightSubmittedState {
  const FoodWeightUpdatedState({
    required this.foodEntryId,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.foodWeight,
  });

  final int foodEntryId;
}

class LoadingError extends HomeState {
  const LoadingError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.foodWeight,
    required super.portionControl,
    required this.errorMessage,
  });

  final String errorMessage;
}

class HeightError extends HomeState {
  const HeightError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required this.errorMessage,
    super.foodEntries = const <FoodWeight>[],
    super.foodWeight = 0,
    super.portionControl = 0,
  });

  final String errorMessage;
}

class DateOfBirthError extends HomeState {
  const DateOfBirthError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required this.errorMessage,
    super.foodEntries = const <FoodWeight>[],
    super.foodWeight = 0,
    super.portionControl = 0,
  });

  final String errorMessage;
}

class GenderError extends HomeState {
  const GenderError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required this.errorMessage,
    super.foodEntries = const <FoodWeight>[],
    super.foodWeight = 0,
    super.portionControl = 0,
  });

  final String errorMessage;
}

class BodyWeightError extends DetailsSubmittedState {
  const BodyWeightError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.foodWeight,
    required this.errorMessage,
  });

  final String errorMessage;
}

class FoodWeightError extends BodyWeightSubmittedState {
  const FoodWeightError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.foodWeight,
    required this.errorMessage,
  });

  final String errorMessage;
}
