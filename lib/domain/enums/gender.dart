import 'package:flutter_translate/flutter_translate.dart';

enum Gender {
  male('male', '♂️'),
  female('female', '♀️'),
  other('other', '🌈'),
  preferNotToSay('prefer_not_to_say', '🤐');

  const Gender(this.translationKey, this.emoji);

  final String translationKey;
  final String emoji;

  /// Getter for the translated display name.
  String get displayName => translate(translationKey);

  /// Getter to check if [Gender] is [male] or [female].
  bool get isMaleOrFemale => this == Gender.male || this == Gender.female;

  /// Parses a persisted gender value into a [Gender].
  ///
  /// This is intended for deserializing values stored in preferences or maps.
  /// It accepts the stable identifiers used by the app, such as enum names and
  /// translation keys, and also supports legacy English labels with spaces.
  ///
  /// Unknown or empty values fall back to [Gender.preferNotToSay].
  ///
  /// Example:
  /// ```dart
  /// final Gender gender = Gender.fromString('prefer not to say');
  /// assert(gender == Gender.preferNotToSay);
  /// ```
  static Gender fromString(String value) {
    final String normalizedValue = _normalizePersistedValue(value);

    if (normalizedValue.isEmpty) {
      return Gender.preferNotToSay;
    }

    for (final Gender gender in Gender.values) {
      if (_normalizePersistedValue(gender.name) == normalizedValue ||
          _normalizePersistedValue(gender.translationKey) == normalizedValue) {
        return gender;
      }
    }

    return Gender.preferNotToSay;
  }

  static String _normalizePersistedValue(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[-\s]+'), '_');
  }
}
