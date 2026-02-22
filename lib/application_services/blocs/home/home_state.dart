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
    required this.dataDate,
  });

  final UserDetails userDetails;
  final double bodyWeight;
  final double yesterdayConsumedTotal;
  final List<BodyWeight> bodyWeightEntries;
  final List<FoodWeight> foodEntries;
  final double portionControl;
  final Language language;
  final DateTime dataDate;

  bool get isSafePortionControl =>
      portionControl >= constants.kAbsoluteMinimumFoodIntakeG &&
      portionControl < constants.kMaxDailyFoodLimit;

  // Helper getter to check if yesterday's consumption is positive AND
  // would be a safe portion size if used today.
  bool get _isYesterdayConsumedTotalASafePortion =>
      yesterdayConsumedTotal >= constants.kAbsoluteMinimumFoodIntakeG &&
      yesterdayConsumedTotal < constants.kMaxDailyFoodLimit;

  double get adjustedPortion {
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
        (bodyWeightEntries.length > 1 && yesterdayConsumedTotal == 0);
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
      return false;
    }
    if (bodyWeightEntries.length == 1) {
      return true;
    }

    return bodyWeightEntries.last.weight >=
        bodyWeightEntries[bodyWeightEntries.length - 2].weight;
  }

  bool get isWeightDecreasing {
    if (yesterdayConsumedTotal <= 0 || bodyWeightEntries.length < 2) {
      return false;
    }
    return bodyWeightEntries.last.weight <
        bodyWeightEntries[bodyWeightEntries.length - 2].weight;
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
  HomeLoading({
    required super.language,
    super.userDetails = const UserDetails(
      heightInCm: 0,
      gender: Gender.preferNotToSay,
      dateOfBirth: null,
    ),
    super.bodyWeight = 0,
    super.yesterdayConsumedTotal = 0,
    super.bodyWeightEntries = const <BodyWeight>[],
    super.foodEntries = const <FoodWeight>[],
    super.portionControl = 0.0,
    DateTime? dataDate,
  }) : super(dataDate: dataDate ?? DateTime.now());

  HomeLoading copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class HomeLoaded extends HomeState {
  HomeLoaded({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.portionControl,
    required super.language,
    DateTime? dataDate,
  }) : super(dataDate: dataDate ?? DateTime.now());

  HomeLoaded copyWith({
    UserDetails? userDetails,
    double? bodyWeight,
    double? yesterdayConsumedTotal,
    List<BodyWeight>? bodyWeightEntries,
    List<FoodWeight>? foodEntries,
    double? portionControl,
    Language? language,
    bool? isConfirmedAllMealsLogged,
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class DetailsUpdateState extends HomeLoaded {
  DetailsUpdateState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    required super.yesterdayConsumedTotal,
    super.portionControl = 0,
    super.dataDate,
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
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class DateOfBirthUpdatedState extends HomeLoaded {
  DateOfBirthUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
    super.dataDate,
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
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class GenderUpdatedState extends HomeLoaded {
  GenderUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
    super.dataDate,
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
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class DetailsSubmittedState extends HomeLoaded {
  DetailsSubmittedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
    super.dataDate,
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
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class LoadingTodayBodyWeightState extends DetailsSubmittedState
    implements HomeLoading {
  LoadingTodayBodyWeightState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
    super.dataDate,
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
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class LoadingConsumedYesterdayState extends DetailsSubmittedState
    implements HomeLoading {
  LoadingConsumedYesterdayState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
    super.dataDate,
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
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class LoadingBodyWeightEntriesState extends DetailsSubmittedState
    implements HomeLoading {
  LoadingBodyWeightEntriesState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
    super.dataDate,
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
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class BodyWeightUpdatedState extends DetailsSubmittedState {
  BodyWeightUpdatedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.language,
    super.yesterdayConsumedTotal = 0,
    super.dataDate,
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
    DateTime? dataDate,
  }) {
    return BodyWeightUpdatedState(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      language: language ?? this.language,
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class BodyWeightSubmittedState extends DetailsSubmittedState {
  BodyWeightSubmittedState({
    required this.isConfirmedAllMealsLogged,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.portionControl,
    required super.language,
    super.dataDate,
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
    int? foodEntryId,
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class FoodWeightUpdateState extends BodyWeightSubmittedState {
  FoodWeightUpdateState({
    required this.foodEntryId,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.isConfirmedAllMealsLogged,
    required super.portionControl,
    required super.language,
    super.dataDate,
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
    int? foodEntryId,
    DateTime? dataDate,
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
      foodEntryId: foodEntryId ?? this.foodEntryId,
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class FoodWeightSubmittedState extends BodyWeightSubmittedState {
  FoodWeightSubmittedState({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.isConfirmedAllMealsLogged,
    required super.portionControl,
    required super.language,
    super.dataDate,
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
    int? foodEntryId,
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class FoodWeightUpdatedState extends BodyWeightSubmittedState {
  FoodWeightUpdatedState({
    required this.foodEntryId,
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.isConfirmedAllMealsLogged,
    required super.portionControl,
    required super.language,
    super.dataDate,
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
    int? foodEntryId,
    DateTime? dataDate,
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
      foodEntryId: foodEntryId ?? this.foodEntryId,
      dataDate: dataDate ?? this.dataDate,
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
    required this.errorMessage,
    required super.dataDate,
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
    String? errorMessage,
    DateTime? dataDate,
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
      errorMessage: errorMessage ?? this.errorMessage,
      dataDate: dataDate ?? this.dataDate,
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
    required super.dataDate,
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
    required super.dataDate,
    super.foodEntries = const <FoodWeight>[],
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
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
    String? errorMessage,
    DateTime? dataDate,
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
      errorMessage: errorMessage ?? this.errorMessage,
      dataDate: dataDate ?? this.dataDate,
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
    required super.dataDate,
    super.foodEntries = const <FoodWeight>[],
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
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
    String? errorMessage,
    DateTime? dataDate,
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
      errorMessage: errorMessage ?? this.errorMessage,
      dataDate: dataDate ?? this.dataDate,
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
    required super.dataDate,
    super.foodEntries = const <FoodWeight>[],
    super.yesterdayConsumedTotal = 0,
    super.portionControl = 0,
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
    String? errorMessage,
    DateTime? dataDate,
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
      errorMessage: errorMessage ?? this.errorMessage,
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class BodyWeightError extends DetailsSubmittedState implements ErrorState {
  BodyWeightError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.language,
    required this.errorMessage,
    super.dataDate,
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
    String? errorMessage,
    DateTime? dataDate,
  }) {
    return BodyWeightError(
      userDetails: userDetails ?? this.userDetails,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      yesterdayConsumedTotal:
          yesterdayConsumedTotal ?? this.yesterdayConsumedTotal,
      bodyWeightEntries: bodyWeightEntries ?? this.bodyWeightEntries,
      foodEntries: foodEntries ?? this.foodEntries,
      language: language ?? this.language,
      errorMessage: errorMessage ?? this.errorMessage,
      dataDate: dataDate ?? this.dataDate,
    );
  }
}

class FoodWeightError extends BodyWeightSubmittedState implements ErrorState {
  FoodWeightError({
    required super.userDetails,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodEntries,
    required super.yesterdayConsumedTotal,
    required super.isConfirmedAllMealsLogged,
    required super.portionControl,
    required super.language,
    required this.errorMessage,
    super.dataDate,
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
    required super.dataDate,
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
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
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
    required super.dataDate,
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
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
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
    required super.dataDate,
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
    DateTime? dataDate,
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
      dataDate: dataDate ?? this.dataDate,
    );
  }
}
