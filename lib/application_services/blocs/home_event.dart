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

class UpdateDateOfBirth extends HomeEvent {
  const UpdateDateOfBirth(this.dateOfBirth);

  final DateTime dateOfBirth;
}

class UpdateGender extends HomeEvent {
  const UpdateGender(this.gender);

  final Gender gender;
}

class UpdateBodyWeight extends HomeEvent {
  const UpdateBodyWeight(this.bodyWeight);

  final String bodyWeight;
}

class UpdateFoodWeight extends HomeEvent {
  const UpdateFoodWeight(this.foodWeight);

  final String foodWeight;
}

class SubmitDetails extends HomeEvent {
  const SubmitDetails();
}

class SubmitBodyWeight extends HomeEvent {
  const SubmitBodyWeight();
}

class EditDetails extends HomeEvent {
  const EditDetails();
}

class EditBodyWeight extends HomeEvent {
  const EditBodyWeight();
}

class SubmitFoodWeight extends HomeEvent {
  const SubmitFoodWeight();
}

class EditFoodWeight extends HomeEvent {
  const EditFoodWeight();
}
