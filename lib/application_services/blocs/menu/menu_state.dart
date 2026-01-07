part of 'menu_bloc.dart';

@immutable
sealed class MenuState {
  const MenuState({
    required this.streakDays,
    this.language = Language.en,
    this.appVersion = '',
  });

  final Language language;
  final int streakDays;
  final String appVersion;

  bool get isUkrainian => language == Language.uk;

  String get localeCode => language.isoLanguageCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuState &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          streakDays == other.streakDays &&
          appVersion == other.appVersion;

  @override
  int get hashCode =>
      language.hashCode ^ streakDays.hashCode ^ appVersion.hashCode;

  @override
  String toString() {
    return 'ChatState('
        'language: $language,'
        'streakDays: $streakDays,'
        'appVersion: $appVersion,'
        ')';
  }
}

final class MenuInitial extends MenuState {
  const MenuInitial({
    required super.streakDays,
    super.language,
    super.appVersion,
  });

  MenuInitial copyWith({
    Language? language,
    int? streakDays,
    String? appVersion,
  }) {
    return MenuInitial(
      language: language ?? this.language,
      streakDays: streakDays ?? this.streakDays,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  String toString() {
    return 'MenuInitial('
        'language: $language,'
        'streakDays: $streakDays,'
        'appVersion: $appVersion'
        ')';
  }
}

final class MenuFeedbackState extends MenuState {
  const MenuFeedbackState({
    required super.language,
    required super.streakDays,
    super.appVersion,
  });

  MenuFeedbackState copyWith({
    Language? language,
    int? streakDays,
    String? appVersion,
  }) {
    return MenuFeedbackState(
      language: language ?? this.language,
      streakDays: streakDays ?? this.streakDays,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  String toString() {
    return 'MenuFeedbackState('
        'language: $language,'
        'streakDays: $streakDays,'
        'appVersion: $appVersion'
        ')';
  }
}

final class MenuFeedbackSent extends MenuState {
  const MenuFeedbackSent({
    required super.streakDays,
    required super.language,
    super.appVersion,
  });

  MenuFeedbackSent copyWith({
    Language? language,
    int? streakDays,
    String? appVersion,
  }) {
    return MenuFeedbackSent(
      language: language ?? this.language,
      streakDays: streakDays ?? this.streakDays,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  String toString() {
    return 'MenuFeedbackSent('
        'language: $language,'
        'streakDays: $streakDays,'
        'appVersion: $appVersion'
        ')';
  }
}

final class LoadingMenuState extends MenuState {
  const LoadingMenuState({
    required super.streakDays,
    super.language,
    super.appVersion,
  });

  LoadingMenuState copyWith({
    Language? language,
    int? streakDays,
    String? appVersion,
  }) {
    return LoadingMenuState(
      streakDays: streakDays ?? this.streakDays,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  String toString() {
    return 'LoadingMenuState('
        'language: $language,'
        'streakDays: $streakDays,'
        'appVersion: $appVersion'
        ')';
  }
}
