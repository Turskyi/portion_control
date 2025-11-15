part of 'onboarding_bloc.dart';

@immutable
sealed class OnboardingState {
  const OnboardingState(this.language);
  final Language language;
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial(super.language);
}
