enum Gender {
  male('Male', '♂️'),
  female('Female', '♀️'),
  other('Other', '🌈'),
  preferNotToSay('Prefer not to say', '🤐');

  const Gender(this.displayName, this.emoji);

  final String displayName;
  final String emoji;

  // Convert a string to a Gender enum
  static Gender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      case 'prefer not to say':
        return Gender.preferNotToSay;
      default:
        return Gender.preferNotToSay;
    }
  }
}
