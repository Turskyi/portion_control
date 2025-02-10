part of 'home_bloc.dart';

@immutable
sealed class HomeState {
  const HomeState({
    required this.userDetails,
    required this.bodyWeight,
    required this.yesterdayConsumedTotal,
    required this.bodyWeightEntries,
    required this.foodEntries,
    required this.portionControl,
  });

  final UserDetails userDetails;
  final double bodyWeight;
  final double yesterdayConsumedTotal;
  final List<BodyWeight> bodyWeightEntries;
  final List<FoodWeight> foodEntries;
  final double portionControl;

  bool get isEmptyDetails =>
      userDetails.height < constants.minHeight &&
      userDetails.age < constants.minAge &&
      userDetails.gender == Gender.preferNotToSay &&
      userDetails.dateOfBirth == null;

  bool get isNotEmptyDetails => !isEmptyDetails;

  double get height => userDetails.height;

  DateTime? get dateOfBirth => userDetails.dateOfBirth;

  Gender get gender => userDetails.gender;

  int get age => userDetails.age;

  double get totalConsumedToday => foodEntries.fold(
        0,
        (double sum, FoodWeight entry) => sum + entry.weight,
      );

  bool get hasNoPortionControl =>
      (bodyWeightEntries.length == 1 && bodyWeightEntries.first.date.isToday) ||
      (bodyWeightEntries.length > 1 && yesterdayConsumedTotal == 0);

  bool get isWeightIncreasing {
    if (bodyWeightEntries.length < 2 || yesterdayConsumedTotal <= 0) {
      return false;
    }
    final BodyWeight last = bodyWeightEntries.last;
    final BodyWeight previous = bodyWeightEntries[bodyWeightEntries.length - 2];
    return last.weight > previous.weight;
  }

  bool get isWeightIncreasingOrSame {
    if (yesterdayConsumedTotal <= 0 || bodyWeightEntries.isEmpty) {
      return false;
    }
    if (bodyWeightEntries.length == 1) {
      return true;
    }
    return bodyWeightEntries.last.weight >=
        bodyWeightEntries[bodyWeightEntries.length - 2].weight;
  }

  bool get isWeightDecreasing =>
      yesterdayConsumedTotal > 0 &&
      bodyWeightEntries.length > 1 &&
      bodyWeightEntries.last.weight <
          bodyWeightEntries[bodyWeightEntries.length - 2].weight;

  bool get isWeightAboveHealthy {
    final double heightInMeters = height / 100;
    final double bmi = bodyWeight / (heightInMeters * heightInMeters);
    return bmi > constants.maxHealthyBmi;
  }

  bool get isWeightBelowHealthy {
    final double heightInMeters = height / 100;
    final double bmi = bodyWeight / (heightInMeters * heightInMeters);
    return bmi < constants.minHealthyBmi;
  }

  bool get isWeightNotSubmitted =>
      this is DetailsSubmittedState &&
      this is! BodyWeightSubmittedState &&
      !(bodyWeightEntries.lastOrNull?.date.isToday == true);

  bool get isMealsConfirmedForToday =>
      this is BodyWeightSubmittedState &&
      (this as BodyWeightSubmittedState).isConfirmedAllMealsLogged;

  bool get shouldAskForMealConfirmation =>
      isWeightIncreasingOrSame &&
      isWeightAboveHealthy &&
      !isMealsConfirmedForToday;
}

class HomeLoading extends HomeState {
  const HomeLoading({
    super.userDetails = const UserDetails(
      height: 0,
      gender: Gender.preferNotToSay,
    ),
    super.bodyWeight = 0,
    super.yesterdayConsumedTotal = 0,
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
    required super.yesterdayConsumedTotal,
    required super.portionControl,
  });
}

class DetailsUpdateState extends HomeLoaded {
  const DetailsUpdateState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
  });
}

class DateOfBirthUpdatedState extends HomeLoaded {
  const DateOfBirthUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
  });
}

class GenderUpdatedState extends HomeLoaded {
  const GenderUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
  });
}

class DetailsSubmittedState extends HomeLoaded {
  const DetailsSubmittedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
  });
}

class BodyWeightUpdatedState extends DetailsSubmittedState {
  const BodyWeightUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    super.yesterdayConsumedTotal = 0,
  });
}

class BodyWeightSubmittedState extends DetailsSubmittedState {
  const BodyWeightSubmittedState({
    required this.isConfirmedAllMealsLogged,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
  });

  final bool isConfirmedAllMealsLogged;
}

class FoodWeightUpdateState extends BodyWeightSubmittedState {
  const FoodWeightUpdateState({
    required this.foodEntryId,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.isConfirmedAllMealsLogged,
  });

  final int foodEntryId;
}

class FoodWeightSubmittedState extends BodyWeightSubmittedState {
  const FoodWeightSubmittedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.isConfirmedAllMealsLogged,
  });
}

class FoodWeightUpdatedState extends BodyWeightSubmittedState {
  const FoodWeightUpdatedState({
    required this.foodEntryId,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.isConfirmedAllMealsLogged,
  });

  final int foodEntryId;
}

class LoadingError extends HomeState {
  const LoadingError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.portionControl,
    required this.errorMessage,
  });

  final String errorMessage;
}

abstract class ErrorState extends HomeState {
  const ErrorState({
    required this.errorMessage,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.portionControl,
  });

  final String errorMessage;
}

class DetailsError extends ErrorState {
  const DetailsError({
    required super.errorMessage,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodEntries = const <FoodWeight>[],
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
  });
}

class DateOfBirthError extends ErrorState {
  const DateOfBirthError({
    required super.errorMessage,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodEntries = const <FoodWeight>[],
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
  });
}

class GenderError extends ErrorState {
  const GenderError({
    required super.errorMessage,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodEntries = const <FoodWeight>[],
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
  });
}

class BodyWeightError extends DetailsSubmittedState implements ErrorState {
  const BodyWeightError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required this.errorMessage,
  });

  @override
  final String errorMessage;
}

class FoodWeightError extends BodyWeightSubmittedState implements ErrorState {
  const FoodWeightError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required this.errorMessage,
    required super.isConfirmedAllMealsLogged,
  });

  @override
  final String errorMessage;
}
