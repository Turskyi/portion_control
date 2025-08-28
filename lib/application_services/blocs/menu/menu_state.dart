part of 'menu_bloc.dart';

@immutable
sealed class MenuState {
  const MenuState({this.language = Language.en});

  final Language language;

  bool get isUkrainian => language == Language.uk;

  String get localeCode => language.isoLanguageCode;

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

final class MenuFeedbackState extends MenuState {
  const MenuFeedbackState({required super.language});

  MenuFeedbackState copyWith({
    Language? language,
  }) {
    return MenuFeedbackState(language: language ?? this.language);
  }

  @override
  String toString() => 'MenuFeedbackState(language: $language)';
}

final class MenuFeedbackSent extends MenuState {
  const MenuFeedbackSent({required super.language});

  MenuFeedbackSent copyWith({
    Language? language,
  }) {
    return MenuFeedbackSent(
      language: language ?? this.language,
    );
  }

  @override
  String toString() => 'MenuFeedbackSent(language: $language)';
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
