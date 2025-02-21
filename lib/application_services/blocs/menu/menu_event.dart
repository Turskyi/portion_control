part of 'menu_bloc.dart';

@immutable
sealed class MenuEvent {
  const MenuEvent();
}

final class BugReportPressedEvent extends MenuEvent {
  const BugReportPressedEvent();
}

final class SubmitFeedbackEvent extends MenuEvent {
  const SubmitFeedbackEvent(this.feedback);

  final UserFeedback feedback;
}

final class ClosingFeedbackEvent extends MenuEvent {
  const ClosingFeedbackEvent();
}

final class LoadingInitialMenuStateEvent extends MenuEvent {
  const LoadingInitialMenuStateEvent();
}

final class ErrorEvent extends MenuEvent {
  const ErrorEvent(this.error);

  final String error;
}
