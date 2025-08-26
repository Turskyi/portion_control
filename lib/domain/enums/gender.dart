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

  //FIXME: I do not remember how this method should work. Needs a better
  // dartdoc and example of use.
  static Gender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      case 'prefer not to say':
      case 'prefer_not_to_say':
        return Gender.preferNotToSay;
      default:
        return Gender.preferNotToSay;
    }
  }
}
