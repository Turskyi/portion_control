part of 'menu_bloc.dart';

@immutable
sealed class MenuState {
  const MenuState({
    required this.streakDays,
    this.language = Language.en,
  });

  final Language language;
  final int streakDays;

  bool get isUkrainian => language == Language.uk;

  String get localeCode => language.isoLanguageCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuState &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          streakDays == other.streakDays;

  @override
  int get hashCode => language.hashCode ^ streakDays.hashCode;

  @override
  String toString() {
    return 'ChatState('
        'language: $language,'
        'streakDays: $streakDays,'
        ')';
  }
}

final class MenuInitial extends MenuState {
  const MenuInitial({
    required super.streakDays,
    super.language,
  });

  MenuInitial copyWith({
    Language? language,
    int? streakDays,
  }) {
    return MenuInitial(
      language: language ?? this.language,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  @override
  String toString() {
    return 'MenuInitial('
        'language: $language,'
        'streakDays: $streakDays'
        ')';
  }
}

final class MenuFeedbackState extends MenuState {
  const MenuFeedbackState({
    required super.language,
    required super.streakDays,
  });

  MenuFeedbackState copyWith({
    Language? language,
    int? streakDays,
  }) {
    return MenuFeedbackState(
      language: language ?? this.language,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  @override
  String toString() {
    return 'MenuFeedbackState('
        'language: $language,'
        'streakDays: $streakDays'
        ')';
  }
}

final class MenuFeedbackSent extends MenuState {
  const MenuFeedbackSent({
    required super.streakDays,
    required super.language,
  });

  MenuFeedbackSent copyWith({
    Language? language,
    int? streakDays,
  }) {
    return MenuFeedbackSent(
      language: language ?? this.language,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  @override
  String toString() {
    return 'MenuFeedbackSent('
        'language: $language,'
        'streakDays: $streakDays'
        ')';
  }
}

final class LoadingMenuState extends MenuState {
  const LoadingMenuState({
    required super.streakDays,
    super.language,
  });

  LoadingMenuState copyWith({
    Language? language,
    int? streakDays,
  }) {
    return LoadingMenuState(
      streakDays: streakDays ?? this.streakDays,
      language: language ?? this.language,
    );
  }

  @override
  String toString() {
    return 'LoadingMenuState('
        'language: $language,'
        'streakDays: $streakDays,'
        ')';
  }
}
