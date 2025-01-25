part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {
  const HomeEvent();
}

class LoadBodyWeightEntries extends HomeEvent {
  const LoadBodyWeightEntries();
}

class UpdateBodyWeight extends HomeEvent {
  const UpdateBodyWeight(this.bodyWeight);

  final String bodyWeight;
}

class SubmitBodyWeight extends HomeEvent {
  const SubmitBodyWeight();
}

class SubmitFoodWeight extends HomeEvent {
  const SubmitFoodWeight();
}
