import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/domain/services/repositories/i_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of user details repository using SharedPreferences
class UserPreferencesRepository implements IUserPreferencesRepository {
  const UserPreferencesRepository(this._sharedPreferences);

  static const String _heightKey = 'user_height';
  static const String _ageKey = 'user_age';
  static const String _genderKey = 'user_gender';
  static const String _dateOfBirthKey = 'user_date_of_birth';
  static const String _mealsConfirmedKey = 'meals_confirmed';
  static const String _mealsConfirmedDateKey = 'meals_confirmed_date';
  static const String _portionControlKey = 'portion_control';

  final SharedPreferences _sharedPreferences;

  @override
  double? getHeight() => _sharedPreferences.getDouble(_heightKey);

  @override
  int? getAge() => _sharedPreferences.getInt(_ageKey);

  @override
  String? getGender() => _sharedPreferences.getString(_genderKey);

  /// Get Date of Birth from SharedPreferences.
  @override
  DateTime? getDateOfBirth() {
    final String? dobString = _sharedPreferences.getString(_dateOfBirthKey);
    return dobString != null ? DateTime.parse(dobString) : null;
  }

  @override
  Future<bool> saveHeight(double height) {
    return _sharedPreferences.setDouble(_heightKey, height);
  }

  @override
  Future<bool> saveAge(int age) {
    return _sharedPreferences.setInt(_ageKey, age);
  }

  @override
  Future<bool> saveGender(Gender gender) {
    return _sharedPreferences.setString(_genderKey, gender.name);
  }

  @override
  UserDetails getUserDetails() {
    final double? height = getHeight();
    final DateTime? dateOfBirth = getDateOfBirth();
    final String? gender = getGender();

    return UserDetails(
      height: height ?? 0,
      dateOfBirth: dateOfBirth,
      gender:
          gender != null ? Gender.fromString(gender) : Gender.preferNotToSay,
    );
  }

  @override
  Future<bool> saveUserDetails(UserDetails userDetails) async {
    final bool heightSaved = await saveHeight(userDetails.height);
    final bool ageSaved = await saveAge(userDetails.age);
    final Gender gender = userDetails.gender;
    final bool genderSaved = await saveGender(gender);
    final DateTime? dateOfBirth = userDetails.dateOfBirth;
    final bool dateOfBirthSaved =
        dateOfBirth == null ? false : await saveDateOfBirth(dateOfBirth);

    if (gender.isMaleOrFemale) {
      return heightSaved && ageSaved && genderSaved && dateOfBirthSaved;
    } else {
      return heightSaved;
    }
  }

  /// Save Date of Birth as an ISO8601 [String].
  @override
  Future<bool> saveDateOfBirth(DateTime dateOfBirth) {
    return _sharedPreferences.setString(
      _dateOfBirthKey,
      dateOfBirth.toIso8601String(),
    );
  }

  @override
  Future<bool> saveMealsConfirmed() async {
    final DateTime today = DateTime.now();
    final bool confirmedSaved = await _sharedPreferences.setBool(
      _mealsConfirmedKey,
      true,
    );
    final bool dateSaved = await _sharedPreferences.setString(
      _mealsConfirmedDateKey,
      today.toIso8601String(),
    );
    return confirmedSaved && dateSaved;
  }

  @override
  bool get isMealsConfirmedForToday {
    final bool? isConfirmed = _sharedPreferences.getBool(_mealsConfirmedKey);

    final String? savedDateString =
        _sharedPreferences.getString(_mealsConfirmedDateKey);

    if (isConfirmed == true && savedDateString != null) {
      final DateTime savedDate = DateTime.parse(savedDateString);
      final DateTime today = DateTime.now();

      return savedDate.year == today.year &&
          savedDate.month == today.month &&
          savedDate.day == today.day;
    }

    return false;
  }

  @override
  double? getPortionControl() {
    return _sharedPreferences.getDouble(_portionControlKey);
  }

  @override
  Future<bool> savePortionControl(double portionControl) {
    return _sharedPreferences.setDouble(_portionControlKey, portionControl);
  }
}
