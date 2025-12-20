import 'package:flutter/material.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/domain/services/repositories/i_preferences_repository.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';

/// Implementation of user details repository using SharedPreferences
class UserPreferencesRepository implements IUserPreferencesRepository {
  const UserPreferencesRepository(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  double? getHeight() => _localDataSource.getHeight();

  @override
  int? getAge() => _localDataSource.getAge();

  @override
  String? getGender() => _localDataSource.getGender();

  /// Get Date of Birth from SharedPreferences.
  @override
  DateTime? getDateOfBirth() => _localDataSource.getDateOfBirth();

  @override
  Future<bool> saveHeight(double height) => _localDataSource.saveHeight(height);

  @override
  Future<bool> saveAge(int age) => _localDataSource.saveAge(age);

  @override
  Future<bool> saveGender(Gender gender) => _localDataSource.saveGender(gender);

  @override
  UserDetails getUserDetails() {
    final double? height = getHeight();
    final DateTime? dateOfBirth = getDateOfBirth();
    final String? gender = getGender();

    return UserDetails(
      heightInCm: height ?? 0,
      dateOfBirth: dateOfBirth,
      gender: gender != null
          ? Gender.fromString(gender)
          : Gender.preferNotToSay,
    );
  }

  @override
  Future<bool> saveUserDetails(UserDetails userDetails) async {
    final bool heightSaved = await saveHeight(userDetails.heightInCm);
    final bool ageSaved = await saveAge(userDetails.age);
    final Gender gender = userDetails.gender;
    final bool genderSaved = await saveGender(gender);
    final DateTime? dateOfBirth = userDetails.dateOfBirth;
    final bool dateOfBirthSaved = dateOfBirth == null
        ? false
        : await saveDateOfBirth(dateOfBirth);

    if (gender.isMaleOrFemale) {
      return heightSaved && ageSaved && genderSaved && dateOfBirthSaved;
    } else {
      return heightSaved;
    }
  }

  /// Save Date of Birth as an ISO8601 [String].
  @override
  Future<bool> saveDateOfBirth(DateTime dateOfBirth) {
    return _localDataSource.saveDateOfBirth(dateOfBirth);
  }

  @override
  Future<bool> saveMealsConfirmed() => _localDataSource.saveMealsConfirmed();

  @override
  bool get isMealsConfirmedForToday {
    return _localDataSource.isMealsConfirmedForToday;
  }

  @override
  double? getLastPortionControl() {
    return _localDataSource.getLastPortionControl();
  }

  @override
  Future<bool> savePortionControl(double portionControl) {
    return _localDataSource.savePortionControl(portionControl);
  }

  // Reminder API.
  @override
  bool isWeightReminderEnabled() => _localDataSource.isWeightReminderEnabled();

  @override
  Future<bool> saveWeightReminderEnabled(bool enabled) =>
      _localDataSource.saveWeightReminderEnabled(enabled);

  @override
  String? getWeightReminderTimeString() {
    final TimeOfDay? time = _localDataSource.getWeightReminderTime();
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Future<bool> saveWeightReminderTimeString(String timeString) {
    try {
      final List<String> parts = timeString.split(':');
      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      return _localDataSource.saveWeightReminderTime(
        TimeOfDay(
          hour: hour,
          minute: minute,
        ),
      );
    } catch (e) {
      debugPrint('Error in saveWeightReminderTimeString: $e');
      return Future<bool>.value(false);
    }
  }
}
