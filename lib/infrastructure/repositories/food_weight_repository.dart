import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/repositories/i_food_weight_repository.dart';

class FoodWeightRepository implements IFoodWeightRepository {
  const FoodWeightRepository();

  /// Insert a new body weight entry.
  @override
  Future<int> addOrUpdateFoodWeightEntry({
    required double weight,
    required DateTime date,
  }) {
    throw UnimplementedError();
  }

  /// Retrieve all body weight entries, sorted by date.
  @override
  Future<List<FoodWeight>> getAllFoodWeightEntries() async {
    throw UnimplementedError();
  }

  /// Delete a body weight entry by id.
  @override
  Future<int> deleteFoodWeightEntry(int id) {
    throw UnimplementedError();
  }

  /// Update a body weight entry by id.
  @override
  Future<bool> updateFoodWeightEntry({
    required int id,
    required double weight,
    required DateTime date,
  }) async {
    throw UnimplementedError();
  }
}
