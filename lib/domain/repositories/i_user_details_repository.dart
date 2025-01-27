abstract class IUserDetailsRepository {
  /// The method is designed to return a `double?`, meaning it can either
  /// return a valid double value or null if no value exists.
  double? getHeight();

  /// Returns whether the value was successfully saved to persistent storage.
  Future<bool> saveHeight(double height);
}
