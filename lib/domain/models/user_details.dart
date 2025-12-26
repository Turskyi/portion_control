import 'package:flutter/foundation.dart';
import 'package:portion_control/domain/enums/gender.dart';

class UserDetails {
  const UserDetails({
    required this.heightInCm,
    required this.gender,
    required this.dateOfBirth,
  });

  const UserDetails.empty()
    : heightInCm = 0,
      dateOfBirth = null,
      gender = Gender.preferNotToSay;

  /// Creates a [UserDetails] object from a [Map].
  factory UserDetails.fromMap(Map<String, Object?> map) {
    return UserDetails(
      heightInCm: (map['height'] is num)
          ? (map['height'] as num).toDouble()
          : 0.0,
      dateOfBirth: (map['dateOfBirth'] is String)
          ? DateTime.tryParse(map['dateOfBirth'] as String)
          : null,
      gender: (map['gender'] is String)
          ? Gender.fromString(map['gender'] as String)
          : Gender.preferNotToSay,
    );
  }

  /// Height in centimeters.
  final double heightInCm;
  final DateTime? dateOfBirth;
  final Gender gender;

  bool get isEmpty {
    return heightInCm == 0 &&
        age == 0 &&
        gender == Gender.preferNotToSay &&
        dateOfBirth == null;
  }

  bool get isNotEmpty => !isEmpty;

  /// Calculates age based on the date of birth
  int get age {
    if (dateOfBirth == null) return 0;
    final DateTime now = DateTime.now();
    final int year = dateOfBirth?.year ?? 0;
    final int month = dateOfBirth?.month ?? 0;
    final int day = dateOfBirth?.day ?? 0;
    int calculatedAge = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      // Adjust if birthday hasn’t occurred yet this year.
      calculatedAge--;
    }
    return calculatedAge;
  }

  /// Converts the UserDetails object to a map (for saving to SharedPreferences)
  Map<String, dynamic> toMap() {
    return <String, Object?>{
      'height': heightInCm,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender.displayName,
    };
  }

  /// For easy debugging
  @override
  String toString() {
    if (kDebugMode) {
      return 'UserDetails('
          'height: $heightInCm, '
          'dateOfBirth: ${dateOfBirth?.toIso8601String()}, '
          'age: $age, '
          'gender: ${gender.displayName},'
          ')';
    } else {
      return super.toString();
    }
  }

  /// Returns a new instance with updated values
  UserDetails copyWith({
    double? heightInCm,
    DateTime? dateOfBirth,
    Gender? gender,
  }) {
    return UserDetails(
      heightInCm: heightInCm ?? this.heightInCm,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }
}
