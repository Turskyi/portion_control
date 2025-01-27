part of 'home_bloc.dart';

@immutable
sealed class HomeState {
  const HomeState({
    required this.height,
    required this.bodyWeight,
    required this.foodWeight,
    required this.bodyWeightEntries,
  });

  final String height;
  final String bodyWeight;
  final String foodWeight;
  final List<BodyWeight> bodyWeightEntries;
}

class HomeLoading extends HomeState {
  const HomeLoading({
    super.height = '',
    super.bodyWeight = '',
    super.foodWeight = '',
    super.bodyWeightEntries = const <BodyWeight>[],
  });
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required super.height,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = '',
  });
}

class HeightUpdatedState extends HomeLoaded {
  const HeightUpdatedState({
    required super.height,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = '',
  });
}

class HeightSubmittedState extends HomeLoaded {
  const HeightSubmittedState({
    required super.height,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = '',
  });
}

class BodyWeightUpdatedState extends HeightSubmittedState {
  const BodyWeightUpdatedState({
    required super.height,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = '',
  });
}

class BodyWeightSubmittedState extends HeightSubmittedState {
  const BodyWeightSubmittedState({
    required super.height,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    super.foodWeight = '',
  });
}

class HeightError extends HomeState {
  const HeightError({
    required super.height,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodWeight,
    required this.errorMessage,
  });

  final String errorMessage;
}

class BodyWeightError extends HeightError {
  const BodyWeightError({
    required super.height,
    required super.bodyWeight,
    required super.bodyWeightEntries,
    required super.foodWeight,
    required super.errorMessage,
  });
}
