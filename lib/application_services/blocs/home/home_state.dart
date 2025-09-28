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
    this.language = Language.en,
  });

  final UserDetails userDetails;
  final double bodyWeight;
  final double yesterdayConsumedTotal;
  final List<BodyWeight> bodyWeightEntries;
  final List<FoodWeight> foodEntries;
  final double portionControl;
  final Language language;

  bool get isSafePortionControl =>
      portionControl > constants.safeMinimumFoodIntakeG &&
      portionControl < constants.maxDailyFoodLimit;

  // Helper getter to check if yesterday's consumption is positive AND
  // would be a safe portion size if used today.
  bool get _isYesterdayConsumedTotalASafePortion =>
      yesterdayConsumedTotal > constants.safeMinimumFoodIntakeG &&
      yesterdayConsumedTotal < constants.maxDailyFoodLimit;

  double get adjustedPortion {
    if (isSafePortionControl) {
      return portionControl;
    } else if (_isYesterdayConsumedTotalASafePortion) {
      return yesterdayConsumedTotal;
    } else if (isWeightDecreasingOrSame && isWeightBelowHealthy) {
      return constants.safeMinimumFoodIntakeG;
    } else {
      return constants.maxDailyFoodLimit;
    }
  }

  double get safePortionControl {
    if (portionControl > constants.safeMinimumFoodIntakeG &&
        portionControl < constants.maxDailyFoodLimit) {
      return portionControl;
    } else if (portionControl < constants.safeMinimumFoodIntakeG) {
      return constants.safeMinimumFoodIntakeG;
    } else {
      return constants.maxDailyFoodLimit;
    }
  }

  bool get isEmptyDetails =>
      userDetails.heightInCm < constants.minUserHeight &&
      userDetails.age < constants.minAge &&
      userDetails.gender == Gender.preferNotToSay &&
      userDetails.dateOfBirth == null;

  bool get isNotEmptyDetails => !isEmptyDetails;

  double get heightInCm => userDetails.heightInCm;

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
    return isWeightIncreasingOrSameFor(bodyWeightEntries);
  }

  bool isWeightIncreasingOrSameFor(List<BodyWeight> bodyWeightEntries) {
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

  bool get isWeightDecreasingOrSame {
    return isWeightDecreasingOrSameFor(bodyWeightEntries);
  }

  bool isWeightDecreasingOrSameFor(List<BodyWeight> bodyWeightEntries) {
    if (yesterdayConsumedTotal <= 0 || bodyWeightEntries.isEmpty) {
      return false;
    }
    if (bodyWeightEntries.length == 1) {
      return true;
    }
    return bodyWeightEntries.last.weight <=
        bodyWeightEntries[bodyWeightEntries.length - 2].weight;
  }

  bool get isWeightAboveHealthy => isWeightAboveHealthyFor(bodyWeight);

  bool isWeightAboveHealthyFor(double bodyWeight) {
    final double heightInMeters = heightInCm / 100;
    final double bmi = bodyWeight / (heightInMeters * heightInMeters);
    return bmi > constants.maxHealthyBmi;
  }

  bool get isWeightBelowHealthy => isWeightBelowHealthyFor(bodyWeight);

  bool isWeightBelowHealthyFor(double bodyWeight) {
    final double heightInMeters = heightInCm / 100;
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

  String get formattedRemainingFood => (adjustedPortion - totalConsumedToday)
      .toStringAsFixed(1)
      .replaceAll(RegExp(r'\.0$'), '');

  String get formattedTotalConsumedToday =>
      totalConsumedToday.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

  String get formattedPortionControl =>
      adjustedPortion.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

  /// Formats the safe minimum food intake constant consistently with
  /// [formattedPortionControl].
  String get formattedSafeMinimumFoodIntake => constants.safeMinimumFoodIntakeG
      .toStringAsFixed(1)
      .replaceAll(RegExp(r'\.0$'), '');

  String get formattedAdjustedPortion =>
      adjustedPortion.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

  String get formattedYesterdayConsumedTotal =>
      yesterdayConsumedTotal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

  String get previousPortionControlInfo {
    return (yesterdayConsumedTotal != adjustedPortion &&
            adjustedPortion != constants.maxDailyFoodLimit &&
            adjustedPortion != constants.safeMinimumFoodIntakeG)
        ? '\n${translate(
            'previous_portion_control',
            args: <String, Object?>{'adjustedPortion': adjustedPortion},
          )}'
        : '';
  }

  /// Body Mass Index (BMI) formula, as described on Wikipedia:
  /// https://en.wikipedia.org/wiki/Body_mass_index
  /// BMI = weight (kg) / [height (m)]^2
  double get bmi {
    final double weight = bodyWeight;
    final double heightInMeters = heightInCm / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String get bmiMessage {
    if (bmi < constants.bmiUnderweightThreshold) {
      return translate('healthy_weight.underweight_message');
    } else if (bmi >= constants.bmiUnderweightThreshold &&
        bmi <= constants.bmiHealthyUpperThreshold) {
      return translate('healthy_weight.healthy_message');
    } else if (bmi >= constants.bmiOverweightLowerThreshold &&
        bmi <= constants.bmiOverweightUpperThreshold) {
      return translate('healthy_weight.overweight_message');
    } else {
      return translate('healthy_weight.obese_message');
    }
  }

  List<BodyWeight> get lastTwoWeeksBodyWeightEntries =>
      bodyWeightEntries.takeLast(DateTime.daysPerWeek * 2).toList();
}

class HomeLoading extends HomeState {
  const HomeLoading({
    super.userDetails = const UserDetails(
      heightInCm: 0,
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
    required super.portionControl,
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
    required super.portionControl,
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
    required super.portionControl,
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
    required super.portionControl,
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
    required super.portionControl,
  });

  @override
  final String errorMessage;
}

final class HomeFeedbackState extends HomeState {
  const HomeFeedbackState({
    required super.userDetails,
    required super.bodyWeight,
    required super.yesterdayConsumedTotal,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.portionControl,
    super.language,
  });

  HomeFeedbackState copyWith({
    Language? language,
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
  }) {
    return HomeFeedbackState(
      language: language ?? this.language,
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
    );
  }
}

final class HomeFeedbackSent extends HomeState {
  const HomeFeedbackSent({
    required super.userDetails,
    required super.bodyWeight,
    required super.yesterdayConsumedTotal,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.portionControl,
    super.language,
  });
}
