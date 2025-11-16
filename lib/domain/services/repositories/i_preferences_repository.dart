import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/models/user_details.dart';

abstract interface class IUserPreferencesRepository {
  const IUserPreferencesRepository();

  /// The method is designed to return a `double?`, meaning it can either
  /// return a valid double value or null if no value exists.
  double? getHeight();

  int? getAge();

  String? getGender();

  UserDetails getUserDetails();

  /// Get Date of Birth.
  DateTime? getDateOfBirth();

  Future<bool> saveDateOfBirth(DateTime dateOfBirth);

  /// Returns whether the value was successfully saved to persistent storage.
  Future<bool> saveHeight(double height);

  Future<bool> saveAge(int height);

  Future<bool> saveGender(Gender gender);

  Future<bool> saveUserDetails(UserDetails userDetails);

  Future<bool> saveMealsConfirmed();

  bool get isMealsConfirmedForToday;

  double? getPortionControl();

  Future<bool> savePortionControl(double height);
}
