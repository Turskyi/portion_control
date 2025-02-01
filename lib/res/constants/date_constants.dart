// date_constants.dart
const int _minAllowedAge = 16;
const int _maxAllowedAge = 120;

/// Returns the latest allowed birth date for a user to be at least
/// [_minAllowedAge] years old.
final DateTime minAllowedBirthDate = DateTime.now().subtract(
  const Duration(days: _minAllowedAge * 365),
);

/// Returns the earliest allowed birth date for a user to be at most
/// [_maxAllowedAge] years old.
final DateTime maxAllowedBirthDate = DateTime.now().subtract(
  const Duration(days: _maxAllowedAge * 365),
);
