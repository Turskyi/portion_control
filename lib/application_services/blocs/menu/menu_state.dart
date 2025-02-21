part of 'menu_bloc.dart';

@immutable
sealed class MenuState {
  const MenuState({this.language = Language.en});

  final Language language;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuState &&
          runtimeType == other.runtimeType &&
          language == other.language;

  @override
  int get hashCode => language.hashCode;

  @override
  String toString() => 'ChatState(language: $language)';
}

final class MenuInitial extends MenuState {
  const MenuInitial({super.language});

  MenuInitial copyWith({
    Language? language,
  }) =>
      MenuInitial(
        language: language ?? this.language,
      );

  @override
  String toString() => 'MenuInitial(language: $language)';
}

final class FeedbackState extends MenuState {
  const FeedbackState({required super.language});

  FeedbackState copyWith({
    Language? language,
  }) =>
      FeedbackState(language: language ?? this.language);

  @override
  String toString() => 'FeedbackState(language: $language)';
}

final class FeedbackSent extends MenuState {
  const FeedbackSent({required super.language});

  FeedbackSent copyWith({
    Language? language,
  }) =>
      FeedbackSent(
        language: language ?? this.language,
      );

  @override
  String toString() => 'FeedbackSent(language: $language)';
}

final class LoadingMenuState extends MenuState {
  const LoadingMenuState({super.language});

  LoadingMenuState copyWith({
    Language? language,
  }) =>
      LoadingMenuState(
        language: language ?? this.language,
      );

  @override
  String toString() => 'LoadingMenuState(language: $language)';
}
