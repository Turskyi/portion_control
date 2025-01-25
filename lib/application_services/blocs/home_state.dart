part of 'home_bloc.dart';

@immutable
sealed class HomeState {
  const HomeState({required this.bodyWeight, required this.foodWeight});

  final String bodyWeight;
  final String foodWeight;
}

class BodyWeightLoading extends HomeState {
  const BodyWeightLoading({super.bodyWeight = '', super.foodWeight = ''});
}

class BodyWeightLoaded extends HomeState {
  const BodyWeightLoaded({
    required super.bodyWeight,
    required this.bodyWeightEntries,
    super.foodWeight = '',
  });

  final List<BodyWeight> bodyWeightEntries;
}

class BodyWeightUpdatedState extends HomeState {
  const BodyWeightUpdatedState({
    required super.bodyWeight,
    super.foodWeight = '',
  });
}

class BodyWeightSubmittedState extends HomeState {
  const BodyWeightSubmittedState({
    required super.bodyWeight,
    super.foodWeight = '',
  });
}

class BodyWeightError extends HomeState {
  const BodyWeightError({
    required super.bodyWeight,
    required super.foodWeight,
    required this.errorMessage,
  });

  final String errorMessage;
}
