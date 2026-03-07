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
    required this.language,
    required this.date,
    required this.hasWeightIncreaseProof,
  });

  final UserDetails userDetails;
  final double bodyWeight;
  final double yesterdayConsumedTotal;
  final List<BodyWeight> bodyWeightEntries;
  final List<FoodWeight> foodEntries;
  final double portionControl;
  final Language language;
  final DateTime date;
  final bool hasWeightIncreaseProof;

  bool get isSafePortionControl =>
      portionControl >= constants.kAbsoluteMinimumFoodIntakeG &&
      portionControl < constants.kMaxDailyFoodLimit &&
      hasWeightIncreaseProof;

  // Helper getter to check if yesterday's consumption is positive AND
  // would be a safe portion size if used today.
  bool get _isYesterdayConsumedTotalASafePortion =>
      yesterdayConsumedTotal >= constants.kAbsoluteMinimumFoodIntakeG &&
      yesterdayConsumedTotal < constants.kMaxDailyFoodLimit &&
      hasWeightIncreaseProof;

  double get adjustedPortion {
    // If we don't have enough data to prove a limit yet, we fallback to the
    // technical max value (effectively "no limit").
    if (hasWeightIncreaseProof) {
      if (isSafePortionControl) {
        return portionControl;
      } else if (_isYesterdayConsumedTotalASafePortion) {
        return yesterdayConsumedTotal;
      } else if (isWeightDecreasingOrSame && isWeightBelowHealthy) {
        return constants.kSafeMinimumFoodIntakeG;
      } else if (isWeightAboveHealthy || isWeightIncreasing) {
        // If we are above healthy weight or weight is increasing, we should not
        // default to the technical max limit (4000g).
        // Instead, we use the safe minimum as a floor.
        return constants.kSafeMinimumFoodIntakeG;
      } else {
        return constants.kMaxDailyFoodLimit;
      }
    } else {
      return constants.kMaxDailyFoodLimit;
    }
  }

  double get safePortionControl {
    if (portionControl >= constants.kAbsoluteMinimumFoodIntakeG &&
        portionControl < constants.kMaxDailyFoodLimit) {
      return portionControl;
    } else if (portionControl < constants.kAbsoluteMinimumFoodIntakeG) {
      return constants.kAbsoluteMinimumFoodIntakeG;
    } else {
      return constants.kMaxDailyFoodLimit;
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
    0.0,
    (double sum, FoodWeight entry) => sum + entry.weight,
  );

  double get totalConsumedYesterday => yesterdayConsumedTotal;

  bool get hasNoPortionControl {
    final BodyWeight? firstEntry = bodyWeightEntries.firstOrNull;
    final bool isSingleTodayEntry =
        bodyWeightEntries.length == 1 && firstEntry?.date.isToday == true;
    return isSingleTodayEntry ||
        (bodyWeightEntries.length > 1 &&
            (yesterdayConsumedTotal == 0 || !hasWeightIncreaseProof));
  }

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
      // No entries, means it is not decreasing, so it is kind of
      // "same weight as yesterday", no entries.
      return true;
    } else if (bodyWeightEntries.length == 1) {
      // Only one entry, so it is kind of "same as yesterday".
      return true;
    } else if (bodyWeightEntries.length > 1) {
      return (bodyWeightEntries.lastOrNull?.weight ?? 0) >=
          bodyWeightEntries[bodyWeightEntries.length - 2].weight;
    } else {
      debugPrint(
        'isWeightIncreasingOrSameFor: Unexpected state. '
        'Length: ${bodyWeightEntries.length}, '
        'yesterdayTotal: $yesterdayConsumedTotal',
      );
      // We assume it is same, because we definitely cannot assume that it is
      // decreasing, even though technically we should not be here.
      return true;
    }
  }

  bool get isWeightDecreasing {
    if (yesterdayConsumedTotal <= 0 || bodyWeightEntries.length < 2) {
      return false;
    } else {
      return bodyWeightEntries.last.weight <
          bodyWeightEntries[bodyWeightEntries.length - 2].weight;
    }
  }

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
    if (heightInMeters == 0) return false;
    final double bmi = bodyWeight / (heightInMeters * heightInMeters);
    return bmi > constants.maxHealthyBmi;
  }

  bool get isWeightBelowHealthy => isWeightBelowHealthyFor(bodyWeight);

  bool isWeightBelowHealthyFor(double bodyWeight) {
    final double heightInMeters = heightInCm / 100;
    if (heightInMeters == 0) return false;
    final double bmi = bodyWeight / (heightInMeters * heightInMeters);
    return bmi < constants.minHealthyBmi;
  }

  bool get isWeightNotSubmitted {
    final BodyWeight? lastEntry = bodyWeightEntries.lastOrNull;
    return this is DetailsSubmittedState &&
        this is! BodyWeightSubmittedState &&
        !(lastEntry?.date.isToday == true);
  }

  bool get isMealsConfirmedForToday {
    final HomeState state = this;
    if (state is BodyWeightSubmittedState) {
      return state.isConfirmedAllMealsLogged;
    }
    return false;
  }

  bool get areMealsNotConfirmed => !isMealsConfirmedForToday;

  bool get shouldAskForMealConfirmation =>
      isWeightIncreasingOrSame &&
      isWeightAboveHealthy &&
      !isMealsConfirmedForToday;

  String get formattedRemainingFood => (adjustedPortion - totalConsumedToday)
      .toStringAsFixed(1)
      .replaceAll(RegExp(r'\.0$'), '');

  String get formattedTotalConsumedToday =>
      totalConsumedToday.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

  String get formattedTotalConsumedYesterday {
    return totalConsumedYesterday
        .toStringAsFixed(1)
        .replaceAll(RegExp(r'\.0$'), '');
  }

  bool get hasNoFoodEntriesYesterday => formattedTotalConsumedYesterday == '0';

  bool get hasFoodEntriesYesterday => formattedTotalConsumedYesterday != '0';

  String get formattedPortionControl {
    return adjustedPortion.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  /// Formats the safe minimum food intake constant consistently with
  /// [formattedPortionControl].
  String get formattedSafeMinimumFoodIntake => constants.kSafeMinimumFoodIntakeG
      .toStringAsFixed(1)
      .replaceAll(RegExp(r'\.0$'), '');

  String get formattedAdjustedPortion {
    return adjustedPortion.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  String get formattedYesterdayConsumedTotal {
    return yesterdayConsumedTotal
        .toStringAsFixed(1)
        .replaceAll(RegExp(r'\.0$'), '');
  }

  String get previousPortionControlInfo {
    return (yesterdayConsumedTotal != adjustedPortion &&
            adjustedPortion != constants.kMaxDailyFoodLimit &&
            adjustedPortion != constants.kSafeMinimumFoodIntakeG)
        ? '\n${translate(
            'home_page.previous_portion_control',
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
    if (heightInMeters == 0) return 0.0;
    return weight / (heightInMeters * heightInMeters);
  }

  String get bmiMessage {
    if (bmi < constants.kMinValidBmi) {
      return '';
    } else if (bmi < constants.bmiUnderweightThreshold) {
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

  List<BodyWeight> get lastTwoWeeksBodyWeightEntries {
    return bodyWeightEntries.takeLast(DateTime.daysPerWeek * 2).toList();
  }
}

class HomeLoading extends HomeState {
  const HomeLoading({
    required super.language,
    required super.portionControl,
    required super.date,
    required super.userDetails,
    super.yesterdayConsumedTotal = 0,
    super.bodyWeight = 0,
    super.bodyWeightEntries = const <BodyWeight>[],
    super.foodEntries = const <FoodWeight>[],
    super.hasWeightIncreaseProof = false,
  });

  HomeLoading copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return HomeLoading(
      language: language ?? this.language,
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.portionControl,
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
  });

  HomeLoaded copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return HomeLoaded(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
}

class DetailsUpdateState extends HomeLoaded {
  const DetailsUpdateState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    required super.yesterdayConsumedTotal,
    required super.hasWeightIncreaseProof,
    required super.date,
    required super.portionControl,
  });

  @override
  DetailsUpdateState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return DetailsUpdateState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
}

class DateOfBirthUpdatedState extends HomeLoaded {
  const DateOfBirthUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
    required super.portionControl,
    required super.yesterdayConsumedTotal,
  });

  @override
  DateOfBirthUpdatedState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return DateOfBirthUpdatedState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
}

class GenderUpdatedState extends HomeLoaded {
  const GenderUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
    required super.portionControl,
    required super.yesterdayConsumedTotal,
  });

  @override
  GenderUpdatedState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return GenderUpdatedState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
}

class DetailsSubmittedState extends HomeLoaded {
  const DetailsSubmittedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
    required super.portionControl,
    required super.yesterdayConsumedTotal,
  });

  @override
  DetailsSubmittedState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return DetailsSubmittedState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
}

class LoadingTodayBodyWeightState extends DetailsSubmittedState
    implements HomeLoading {
  const LoadingTodayBodyWeightState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.portionControl,
    required super.date,
    required super.yesterdayConsumedTotal,
  });

  @override
  LoadingTodayBodyWeightState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return LoadingTodayBodyWeightState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
}

class LoadingConsumedYesterdayState extends DetailsSubmittedState
    implements HomeLoading {
  const LoadingConsumedYesterdayState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
    required super.portionControl,
    required super.yesterdayConsumedTotal,
  });

  @override
  LoadingConsumedYesterdayState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return LoadingConsumedYesterdayState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
}

class LoadingBodyWeightEntriesState extends DetailsSubmittedState
    implements HomeLoading {
  const LoadingBodyWeightEntriesState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
    required super.portionControl,
    required super.yesterdayConsumedTotal,
  });

  @override
  LoadingBodyWeightEntriesState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return LoadingBodyWeightEntriesState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
}

class BodyWeightUpdatedState extends DetailsSubmittedState {
  const BodyWeightUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
    required super.portionControl,
    required super.yesterdayConsumedTotal,
  });

  @override
  BodyWeightUpdatedState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return BodyWeightUpdatedState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
      portionControl: portionControl ?? this.portionControl,
    );
  }
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
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
  });

  final bool isConfirmedAllMealsLogged;

  @override
  BodyWeightSubmittedState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    int? foodEntryId,
    DateTime? date,
  }) {
    return BodyWeightSubmittedState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      isConfirmedAllMealsLogged:
          isConfirmedAllMealsLogged ?? this.isConfirmedAllMealsLogged,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
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
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
  });

  final int foodEntryId;

  @override
  FoodWeightUpdateState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    int? foodEntryId,
    DateTime? date,
  }) {
    return FoodWeightUpdateState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      isConfirmedAllMealsLogged:
          isConfirmedAllMealsLogged ?? this.isConfirmedAllMealsLogged,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      foodEntryId: foodEntryId ?? this.foodEntryId,
      date: date ?? this.date,
    );
  }
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
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
  });

  @override
  FoodWeightSubmittedState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    int? foodEntryId,
    DateTime? date,
  }) {
    return FoodWeightSubmittedState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      isConfirmedAllMealsLogged:
          isConfirmedAllMealsLogged ?? this.isConfirmedAllMealsLogged,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
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
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
  });

  final int foodEntryId;

  @override
  FoodWeightUpdatedState copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    int? foodEntryId,
    DateTime? date,
  }) {
    return FoodWeightUpdatedState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      isConfirmedAllMealsLogged:
          isConfirmedAllMealsLogged ?? this.isConfirmedAllMealsLogged,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      foodEntryId: foodEntryId ?? this.foodEntryId,
      date: date ?? this.date,
    );
  }
}

class LoadingError extends HomeState {
  const LoadingError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.portionControl,
    required super.language,
    required super.hasWeightIncreaseProof,
    required this.errorMessage,
    required super.date,
  });

  final String errorMessage;

  LoadingError copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    String? errorMessage,
    DateTime? date,
  }) {
    return LoadingError(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      errorMessage: errorMessage ?? this.errorMessage,
      date: date ?? this.date,
    );
  }
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
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
  });

  final String errorMessage;
}

class DetailsError extends ErrorState {
  const DetailsError({
    required super.errorMessage,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
    required super.yesterdayConsumedTotal,
    required super.portionControl,
    super.foodEntries = const <FoodWeight>[],
  });

  DetailsError copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    String? errorMessage,
    DateTime? date,
  }) {
    return DetailsError(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      errorMessage: errorMessage ?? this.errorMessage,
      date: date ?? this.date,
    );
  }
}

class DateOfBirthError extends ErrorState {
  const DateOfBirthError({
    required super.errorMessage,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
    required super.yesterdayConsumedTotal,
    required super.portionControl,
    super.foodEntries = const <FoodWeight>[],
  });

  DateOfBirthError copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    String? errorMessage,
    DateTime? date,
  }) {
    return DateOfBirthError(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      errorMessage: errorMessage ?? this.errorMessage,
      date: date ?? this.date,
    );
  }
}

class GenderError extends ErrorState {
  const GenderError({
    required super.errorMessage,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
    required super.yesterdayConsumedTotal,
    required super.portionControl,
    super.foodEntries = const <FoodWeight>[],
  });

  GenderError copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    String? errorMessage,
    DateTime? date,
  }) {
    return GenderError(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      errorMessage: errorMessage ?? this.errorMessage,
      date: date ?? this.date,
    );
  }
}

class BodyWeightError extends DetailsSubmittedState implements ErrorState {
  const BodyWeightError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.language,
    required super.hasWeightIncreaseProof,
    required this.errorMessage,
    required super.date,
    required super.portionControl,
  });

  @override
  final String errorMessage;

  @override
  BodyWeightError copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    String? errorMessage,
    DateTime? date,
  }) {
    return BodyWeightError(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      language: language ?? this.language,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      errorMessage: errorMessage ?? this.errorMessage,
      date: date ?? this.date,
      portionControl: portionControl ?? this.portionControl,
    );
  }
}

class FoodWeightError extends BodyWeightSubmittedState implements ErrorState {
  const FoodWeightError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.isConfirmedAllMealsLogged,
    required super.portionControl,
    required super.language,
    required super.hasWeightIncreaseProof,
    required this.errorMessage,
    required super.date,
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
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
  });

  HomeFeedbackState copyWith({
    Language? language,
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
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
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
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
    required super.language,
    required super.hasWeightIncreaseProof,
    required super.date,
  });

  HomeFeedbackSent copyWith({
    Language? language,
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return HomeFeedbackSent(
      language: language ?? this.language,
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
}

class FeedbackHomeLoading extends HomeState {
  const FeedbackHomeLoading({
    required super.language,
    required super.userDetails,
    required super.bodyWeight,
    required super.yesterdayConsumedTotal,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.portionControl,
    required super.hasWeightIncreaseProof,
    required super.date,
  });

  FeedbackHomeLoading copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    bool? hasWeightIncreaseProof,
    DateTime? date,
  }) {
    return FeedbackHomeLoading(
      language: language ?? this.language,
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      portionControl: portionControl ?? this.portionControl,
      hasWeightIncreaseProof:
          hasWeightIncreaseProof ?? this.hasWeightIncreaseProof,
      date: date ?? this.date,
    );
  }
}
