part of 'onboarding_bloc.dart';

@immutable
sealed class OnboardingEvent {
  const OnboardingEvent();
}

class ChangeLanguageEvent extends OnboardingEvent {
  const ChangeLanguageEvent(this.language);

  final Language language;
}
