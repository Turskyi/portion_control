import 'package:portion_control/domain/models/food_weight.dart';

abstract interface class IFoodWeightRepository {
  const IFoodWeightRepository();

  /// Returns the `rowid` of the inserted row.
  Future<int> addOrUpdateFoodWeightEntry({
    required double weight,
    required DateTime date,
  });

  Future<List<FoodWeight>> getAllFoodWeightEntries();

  Future<int> deleteFoodWeightEntry(int id);

  Future<bool> updateFoodWeightEntry({
    required int id,
    required double weight,
    required DateTime date,
  });
}
