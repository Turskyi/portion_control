part of 'home_bloc.dart';

@immutable
sealed class HomeState {
  const HomeState({
    required this.userDetails,
    required this.bodyWeight,
    required this.foodWeight,
    required this.bodyWeightEntries,
  });

  final UserDetails userDetails;
  final double bodyWeight;
  final double foodWeight;
  final List<BodyWeight> bodyWeightEntries;

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
  });
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = 0,
  });
}

class HeightUpdatedState extends HomeLoaded {
  const HeightUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = 0,
  });
}

class DateOfBirthUpdatedState extends HomeLoaded {
  const DateOfBirthUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = 0,
  });
}

class GenderUpdatedState extends HomeLoaded {
  const GenderUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = 0,
  });
}

class DetailsSubmittedState extends HomeLoaded {
  const DetailsSubmittedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = 0,
  });
}

class BodyWeightUpdatedState extends DetailsSubmittedState {
  const BodyWeightUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = 0,
  });
}

class BodyWeightSubmittedState extends DetailsSubmittedState {
  const BodyWeightSubmittedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = 0,
  });
}

class LoadingError extends HeightError {
  const LoadingError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodWeight,
    required super.errorMessage,
  });
}

class HeightError extends HomeState {
  const HeightError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodWeight,
    required this.errorMessage,
  });

  final String errorMessage;
}

class DateOfBirthError extends HomeState {
  const DateOfBirthError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodWeight,
    required this.errorMessage,
  });

  final String errorMessage;
}

class GenderError extends HomeState {
  const GenderError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodWeight,
    required this.errorMessage,
  });

  final String errorMessage;
}

class BodyWeightError extends HeightError {
  const BodyWeightError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodWeight,
    required super.errorMessage,
  });
}
