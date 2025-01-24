part of 'home_bloc.dart';

@immutable
sealed class HomeState {
  const HomeState({required this.bodyWeight});

  final String bodyWeight;
}

final class HomeInitial extends HomeState {
  const HomeInitial({super.bodyWeight = ''});
}

class BodyWeightUpdatedState extends HomeState {
  const BodyWeightUpdatedState({required super.bodyWeight});
}

class BodyWeightSubmittedState extends HomeState {
  const BodyWeightSubmittedState({required super.bodyWeight});
}

class BodyWeightLoading extends HomeState {
  const BodyWeightLoading({required super.bodyWeight});
}

class BodyWeightLoaded extends HomeState {
  const BodyWeightLoaded({required super.bodyWeight});
}

class BodyWeightError extends HomeState {
  const BodyWeightError({
    required super.bodyWeight,
    required this.errorMessage,
  });

  final String errorMessage;
}
