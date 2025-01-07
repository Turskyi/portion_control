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
