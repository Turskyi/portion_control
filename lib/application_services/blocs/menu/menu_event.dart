part of 'menu_bloc.dart';

@immutable
sealed class MenuEvent {
  const MenuEvent();
}

final class BugReportPressedEvent extends MenuEvent {
  const BugReportPressedEvent();
}

final class MenuSubmitFeedbackEvent extends MenuEvent {
  const MenuSubmitFeedbackEvent({
    required this.feedback,
    this.submissionType = FeedbackSubmissionType.manual,
  });

  final UserFeedback feedback;
  final FeedbackSubmissionType submissionType;
}

final class MenuClosingFeedbackEvent extends MenuEvent {
  const MenuClosingFeedbackEvent();
}

final class LoadingInitialMenuStateEvent extends MenuEvent {
  const LoadingInitialMenuStateEvent();
}

final class MenuErrorEvent extends MenuEvent {
  const MenuErrorEvent(this.error);

  final String error;
}

class ChangeLanguageEvent extends MenuEvent {
  const ChangeLanguageEvent(this.language);

  final Language language;
}

class OpenWebVersionEvent extends MenuEvent {
  const OpenWebVersionEvent();
}

class PinWidgetEvent extends MenuEvent {
  const PinWidgetEvent();
}
