part of 'home_bloc.dart';

@immutable
sealed class HomeState {
  const HomeState({
    required this.bodyWeight,
    required this.foodWeight,
    required this.bodyWeightEntries,
  });

  final String bodyWeight;
  final String foodWeight;
  final List<BodyWeight> bodyWeightEntries;
}

class BodyWeightLoading extends HomeState {
  const BodyWeightLoading({
    super.bodyWeight = '',
    super.foodWeight = '',
    super.bodyWeightEntries = const <BodyWeight>[],
  });
}

class BodyWeightLoaded extends HomeState {
  const BodyWeightLoaded({
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = '',
  });
}

class BodyWeightUpdatedState extends HomeState {
  const BodyWeightUpdatedState({
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = '',
  });
}

class BodyWeightSubmittedState extends HomeState {
  const BodyWeightSubmittedState({
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = '',
  });
}

class BodyWeightError extends HomeState {
  const BodyWeightError({
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodWeight,
    required this.errorMessage,
  });

  final String errorMessage;
}
