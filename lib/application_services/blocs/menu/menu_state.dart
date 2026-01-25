part of 'menu_bloc.dart';

@immutable
sealed class MenuState {
  const MenuState({
    required this.streakDays,
    this.language = Language.en,
    this.appVersion = '',
    this.isWeightReminderEnabled = false,
    this.weightReminderTime = const TimeOfDay(hour: 8, minute: 0),
  });

  final Language language;
  final int streakDays;
  final String appVersion;
  final bool isWeightReminderEnabled;
  final TimeOfDay weightReminderTime;

  bool get isUkrainian => language == Language.uk;

  bool get isFrench => language == Language.fr;

  String get localeCode => language.isoLanguageCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuState &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          streakDays == other.streakDays &&
          appVersion == other.appVersion &&
          isWeightReminderEnabled == other.isWeightReminderEnabled &&
          weightReminderTime == other.weightReminderTime;

  @override
  int get hashCode =>
      language.hashCode ^
      streakDays.hashCode ^
      appVersion.hashCode ^
      isWeightReminderEnabled.hashCode ^
      weightReminderTime.hashCode;

  @override
  String toString() {
    return 'MenuState('
        'language: $language,'
        'streakDays: $streakDays,'
        'appVersion: $appVersion,'
        'isWeightReminderEnabled: $isWeightReminderEnabled,'
        'weightReminderTime: $weightReminderTime'
        ')';
  }
}

final class MenuInitial extends MenuState {
  const MenuInitial({
    required super.streakDays,
    super.language,
    super.appVersion,
    super.isWeightReminderEnabled,
    super.weightReminderTime,
  });

  MenuInitial copyWith({
    Language? language,
    int? streakDays,
    String? appVersion,
    bool? isWeightReminderEnabled,
    TimeOfDay? weightReminderTime,
  }) {
    return MenuInitial(
      language: language ?? this.language,
      streakDays: streakDays ?? this.streakDays,
      appVersion: appVersion ?? this.appVersion,
      isWeightReminderEnabled:
          isWeightReminderEnabled ?? this.isWeightReminderEnabled,
      weightReminderTime: weightReminderTime ?? this.weightReminderTime,
    );
  }

  @override
  String toString() {
    return 'MenuInitial('
        'language: $language,'
        'streakDays: $streakDays,'
        'appVersion: $appVersion,'
        'isWeightReminderEnabled: $isWeightReminderEnabled,'
        'weightReminderTime: $weightReminderTime'
        ')';
  }
}

final class MenuFeedbackState extends MenuState {
  const MenuFeedbackState({
    required super.language,
    required super.streakDays,
    super.appVersion,
    super.isWeightReminderEnabled,
    super.weightReminderTime,
  });

  MenuFeedbackState copyWith({
    Language? language,
    int? streakDays,
    String? appVersion,
    bool? isWeightReminderEnabled,
    TimeOfDay? weightReminderTime,
  }) {
    return MenuFeedbackState(
      language: language ?? this.language,
      streakDays: streakDays ?? this.streakDays,
      appVersion: appVersion ?? this.appVersion,
      isWeightReminderEnabled:
          isWeightReminderEnabled ?? this.isWeightReminderEnabled,
      weightReminderTime: weightReminderTime ?? this.weightReminderTime,
    );
  }

  @override
  String toString() {
    return 'MenuFeedbackState('
        'language: $language,'
        'streakDays: $streakDays,'
        'appVersion: $appVersion,'
        'isWeightReminderEnabled: $isWeightReminderEnabled,'
        'weightReminderTime: $weightReminderTime'
        ')';
  }
}

final class MenuFeedbackSent extends MenuState {
  const MenuFeedbackSent({
    required super.streakDays,
    required super.language,
    super.appVersion,
    super.isWeightReminderEnabled,
    super.weightReminderTime,
  });

  MenuFeedbackSent copyWith({
    Language? language,
    int? streakDays,
    String? appVersion,
    bool? isWeightReminderEnabled,
    TimeOfDay? weightReminderTime,
  }) {
    return MenuFeedbackSent(
      language: language ?? this.language,
      streakDays: streakDays ?? this.streakDays,
      appVersion: appVersion ?? this.appVersion,
      isWeightReminderEnabled:
          isWeightReminderEnabled ?? this.isWeightReminderEnabled,
      weightReminderTime: weightReminderTime ?? this.weightReminderTime,
    );
  }

  @override
  String toString() {
    return 'MenuFeedbackSent('
        'language: $language,'
        'streakDays: $streakDays,'
        'appVersion: $appVersion,'
        'isWeightReminderEnabled: $isWeightReminderEnabled,'
        'weightReminderTime: $weightReminderTime'
        ')';
  }
}

final class LoadingMenuState extends MenuState {
  const LoadingMenuState({
    required super.streakDays,
    super.language,
    super.appVersion,
    super.isWeightReminderEnabled,
    super.weightReminderTime,
  });

  LoadingMenuState copyWith({
    Language? language,
    int? streakDays,
    String? appVersion,
    bool? isWeightReminderEnabled,
    TimeOfDay? weightReminderTime,
  }) {
    return LoadingMenuState(
      streakDays: streakDays ?? this.streakDays,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      isWeightReminderEnabled:
          isWeightReminderEnabled ?? this.isWeightReminderEnabled,
      weightReminderTime: weightReminderTime ?? this.weightReminderTime,
    );
  }

  @override
  String toString() {
    return 'LoadingMenuState('
        'language: $language,'
        'streakDays: $streakDays,'
        'appVersion: $appVersion,'
        'isWeightReminderEnabled: $isWeightReminderEnabled,'
        'weightReminderTime: $weightReminderTime'
        ')';
  }
}
