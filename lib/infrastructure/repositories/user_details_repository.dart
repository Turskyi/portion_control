import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/domain/repositories/i_user_details_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of user details repository using SharedPreferences
class UserDetailsRepository implements IUserDetailsRepository {
  UserDetailsRepository(this._sharedPreferences);

  static const String _heightKey = 'user_height';
  static const String _ageKey = 'user_age';
  static const String _genderKey = 'user_gender';
  static const String _dateOfBirthKey = 'user_date_of_birth';

  final SharedPreferences _sharedPreferences;

  // Getters
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

  // Setters
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
    final bool genderSaved = await saveGender(userDetails.gender);
    final DateTime? dateOfBirth = userDetails.dateOfBirth;
    final bool dateOfBirthSaved =
        dateOfBirth == null ? false : await saveDateOfBirth(dateOfBirth);

    return heightSaved && ageSaved && genderSaved && dateOfBirthSaved;
  }

  /// Save Date of Birth as an ISO8601 [String].
  @override
  Future<bool> saveDateOfBirth(DateTime dateOfBirth) {
    return _sharedPreferences.setString(
      _dateOfBirthKey,
      dateOfBirth.toIso8601String(),
    );
  }
}
