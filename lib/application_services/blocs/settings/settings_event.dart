part of 'settings_bloc.dart';

@immutable
sealed class SettingsEvent {
  const SettingsEvent();
}

final class BugReportPressedEvent extends SettingsEvent {
  const BugReportPressedEvent(this.errorText);

  final String errorText;
}

final class SubmitFeedbackEvent extends SettingsEvent {
  const SubmitFeedbackEvent({
    required this.feedback,
    this.submissionType = FeedbackSubmissionType.manual,
  });

  final UserFeedback feedback;
  final FeedbackSubmissionType submissionType;
}

final class ClosingFeedbackEvent extends SettingsEvent {
  const ClosingFeedbackEvent();
}

final class SettingsErrorEvent extends SettingsEvent {
  const SettingsErrorEvent(this.error);

  final String error;
}

class SettingsChangeLanguageEvent extends SettingsEvent {
  const SettingsChangeLanguageEvent(this.language);

  final Language language;
}
