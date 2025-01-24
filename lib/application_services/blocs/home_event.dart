part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {
  const HomeEvent();
}

class UpdateBodyWeight extends HomeEvent {
  const UpdateBodyWeight(this.bodyWeight);

  final String bodyWeight;
}

class SubmitBodyWeight extends HomeEvent {
  const SubmitBodyWeight();
}

class LoadBodyWeightEntries extends HomeEvent {
  const LoadBodyWeightEntries();
}
