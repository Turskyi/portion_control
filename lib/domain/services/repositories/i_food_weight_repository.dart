import 'package:portion_control/domain/models/food_weight.dart';

abstract interface class IFoodWeightRepository {
  const IFoodWeightRepository();

  /// Inserts a new food [weight] entry and returns the `rowid` of the inserted
  /// row.
  Future<int> addFoodWeightEntry({
    required double weight,
    required DateTime date,
  });

  /// Returns all food weight entries for today.
  Future<List<FoodWeight>> getTodayFoodEntries();

  /// Returns food weight entries for a specific [date].
  Future<List<FoodWeight>> getFoodEntriesByDate(DateTime date);

  /// Deletes a food weight entry by [id] and returns the number of affected
  /// rows.
  Future<int> deleteFoodWeightEntry(int id);

  /// Updates a [foodEntry] and returns the number of rows affected (should be
  /// `1` if the entry exists, `0` if no matching entry was found).
  Future<int> updateFoodWeightEntry({
    required int foodEntryId,
    required double foodEntryValue,
  });

  Future<double> getTotalConsumedYesterday();

  Future<int> clearAllTrackingData();
}
