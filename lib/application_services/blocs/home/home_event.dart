part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {
  const HomeEvent();
}

final class LoadEntries extends HomeEvent {
  const LoadEntries();
}

final class UpdateHeight extends HomeEvent {
  const UpdateHeight(this.height);

  final String height;
}

final class UpdateDateOfBirth extends HomeEvent {
  const UpdateDateOfBirth(this.dateOfBirth);

  final DateTime dateOfBirth;
}

final class UpdateGender extends HomeEvent {
  const UpdateGender(this.gender);

  final Gender gender;
}

final class UpdateBodyWeight extends HomeEvent {
  const UpdateBodyWeight(this.bodyWeight);

  final String bodyWeight;
}

final class UpdateFoodWeight extends HomeEvent {
  const UpdateFoodWeight({
    required this.foodEntryId,
    required this.foodWeight,
  });

  final String foodWeight;
  final int foodEntryId;
}

final class SubmitDetails extends HomeEvent {
  const SubmitDetails();
}

final class SubmitBodyWeight extends HomeEvent {
  const SubmitBodyWeight(this.bodyWeight);

  final double bodyWeight;
}

final class EditDetails extends HomeEvent {
  const EditDetails();
}

final class EditBodyWeight extends HomeEvent {
  const EditBodyWeight();
}

final class AddFoodEntry extends HomeEvent {
  const AddFoodEntry(this.foodWeight);

  final String foodWeight;
}

final class EditFoodEntry extends HomeEvent {
  const EditFoodEntry(this.foodEntryId);

  final int foodEntryId;
}

final class DeleteFoodEntry extends HomeEvent {
  const DeleteFoodEntry(this.foodEntryId);

  final int foodEntryId;
}

final class ClearUserData extends HomeEvent {
  /// Reset all user data (body weight, food intake, etc.).
  const ClearUserData();
}

final class ConfirmMealsLogged extends HomeEvent {
  const ConfirmMealsLogged();
}

final class ResetFoodEntries extends HomeEvent {
  /// Reset all user'` food intake.
  const ResetFoodEntries();
}

final class HomeBugReportPressedEvent extends HomeEvent {
  const HomeBugReportPressedEvent();
}

final class HomeClosingFeedbackEvent extends HomeEvent {
  const HomeClosingFeedbackEvent();
}

final class HomeSubmitFeedbackEvent extends HomeEvent {
  const HomeSubmitFeedbackEvent(this.feedback);

  final UserFeedback feedback;
}

final class ErrorEvent extends HomeEvent {
  const ErrorEvent(this.error);

  final String error;
}
