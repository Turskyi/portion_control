part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {
  const SettingsState({required this.language});

  final Language language;

  bool get isEnglish => language == Language.en;

  bool get isUkrainian => language == Language.uk;

  String get locale => language.isoLanguageCode;
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial({required super.language});

  SettingsState copyWith({Language? language}) {
    return SettingsInitial(language: language ?? this.language);
  }

  @override
  String toString() {
    return 'SettingsInitial{'
        '  language: $language,'
        '}';
  }
}

final class FeedbackState extends SettingsState {
  const FeedbackState({required this.errorMessage, required super.language});

  final String errorMessage;

  @override
  String toString() => 'FeedbackState()';

  FeedbackState copyWith({String? errorMessage, Language? language}) {
    return FeedbackState(
      errorMessage: errorMessage ?? this.errorMessage,
      language: language ?? this.language,
    );
  }
}

final class SettingsFeedbackSent extends SettingsState {
  const SettingsFeedbackSent({required super.language});

  SettingsFeedbackSent copyWith({Language? language}) {
    return SettingsFeedbackSent(language: language ?? this.language);
  }

  @override
  String toString() => 'SettingsFeedbackSent()';
}

final class LoadingSettingsState extends SettingsState {
  const LoadingSettingsState({required super.language});

  @override
  String toString() => 'LoadingSettingsState()';
}

final class SettingsError extends SettingsState {
  const SettingsError({required this.errorMessage, required super.language});

  final String errorMessage;

  SettingsError copyWith({String? errorMessage, Language? language}) {
    return SettingsError(
      errorMessage: errorMessage ?? this.errorMessage,
      language: language ?? this.language,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsError && other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => errorMessage.hashCode;

  @override
  String toString() => 'SettingsError(errorMessage: $errorMessage)';
}
