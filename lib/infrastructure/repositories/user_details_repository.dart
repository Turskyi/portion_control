import 'package:portion_control/domain/repositories/i_user_details_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of user details repository using SharedPreferences
class UserDetailsRepository implements IUserDetailsRepository {
  UserDetailsRepository(this._sharedPreferences);

  static const String _heightKey = 'user_height';

  final SharedPreferences _sharedPreferences;

  /// The method is designed to return a `double?`, meaning it can either
  /// return a valid double value or null if no value exists.
  @override
  double? getHeight() => _sharedPreferences.getDouble(_heightKey);

  /// Returns whether the value was successfully saved to persistent storage.
  @override
  Future<bool> saveHeight(double height) {
    return _sharedPreferences.setDouble(_heightKey, height);
  }
}
