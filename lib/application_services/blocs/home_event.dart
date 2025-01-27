part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {
  const HomeEvent();
}

class LoadEntries extends HomeEvent {
  const LoadEntries();
}

class UpdateHeight extends HomeEvent {
  const UpdateHeight(this.height);

  final String height;
}

class UpdateBodyWeight extends HomeEvent {
  const UpdateBodyWeight(this.bodyWeight);

  final String bodyWeight;
}

class SubmitHeight extends HomeEvent {
  const SubmitHeight();
}

class SubmitBodyWeight extends HomeEvent {
  const SubmitBodyWeight();
}

class EditHeight extends HomeEvent {
  const EditHeight();
}

class EditBodyWeight extends HomeEvent {
  const EditBodyWeight();
}

class SubmitFoodWeight extends HomeEvent {
  const SubmitFoodWeight();
}
