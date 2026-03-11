part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {
  const SettingsState({
    required this.language,
    required this.themeMode,
    required this.isOnboardingCompleted,
    this.version = '',
  });

  final Language language;
  final ThemeMode themeMode;
  final bool isOnboardingCompleted;
  final String version;

  bool get isEnglish => language == Language.en;

  bool get isUkrainian => language == Language.uk;

  String get locale => language.isoLanguageCode;

  bool get isDarkTheme => themeMode == ThemeMode.dark;
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial({
    required super.language,
    required super.themeMode,
    required super.isOnboardingCompleted,
    super.version,
  });

  SettingsInitial copyWith({
    Language? language,
    ThemeMode? themeMode,
    bool? isOnboardingCompleted,
    String? version,
  }) {
    return SettingsInitial(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      version: version ?? this.version,
    );
  }

  @override
  String toString() {
    return 'SettingsInitial{'
        '  language: $language,'
        '  themeMode: $themeMode,'
        '  isOnboardingCompleted: $isOnboardingCompleted,'
        '  version: $version,'
        '}';
  }
}

final class FeedbackState extends SettingsState {
  const FeedbackState({
    required this.errorMessage,
    required super.language,
    required super.themeMode,
    required super.isOnboardingCompleted,
    super.version,
  });

  final String errorMessage;

  @override
  String toString() => 'FeedbackState()';

  FeedbackState copyWith({
    String? errorMessage,
    Language? language,
    ThemeMode? themeMode,
    bool? isOnboardingCompleted,
    String? version,
  }) {
    return FeedbackState(
      errorMessage: errorMessage ?? this.errorMessage,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      version: version ?? this.version,
    );
  }
}

final class SettingsFeedbackSent extends SettingsState {
  const SettingsFeedbackSent({
    required super.language,
    required super.themeMode,
    required super.isOnboardingCompleted,
    super.version,
  });

  SettingsFeedbackSent copyWith({
    Language? language,
    ThemeMode? themeMode,
    bool? isOnboardingCompleted,
    String? version,
  }) {
    return SettingsFeedbackSent(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      version: version ?? this.version,
    );
  }

  @override
  String toString() => 'SettingsFeedbackSent()';
}

final class LoadingSettingsState extends SettingsState {
  const LoadingSettingsState({
    required super.language,
    required super.themeMode,
    required super.isOnboardingCompleted,
    super.version,
  });

  @override
  String toString() => 'LoadingSettingsState()';
}

final class SettingsError extends SettingsState {
  const SettingsError({
    required this.errorMessage,
    required super.language,
    required super.themeMode,
    required super.isOnboardingCompleted,
    super.version,
  });

  final String errorMessage;

  SettingsError copyWith({
    String? errorMessage,
    Language? language,
    ThemeMode? themeMode,
    bool? isOnboardingCompleted,
    String? version,
  }) {
    return SettingsError(
      errorMessage: errorMessage ?? this.errorMessage,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      version: version ?? this.version,
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
