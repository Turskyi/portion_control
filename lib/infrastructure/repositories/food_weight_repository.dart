import 'package:portion_control/domain/models/day_food_log.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/services/repositories/i_food_weight_repository.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';

class FoodWeightRepository implements IFoodWeightRepository {
  const FoodWeightRepository(this._localDataSource);

  final LocalDataSource _localDataSource;

  /// Insert a new food weight entry.
  @override
  Future<int> addFoodWeightEntry({
    required double weight,
    required DateTime date,
  }) {
    return _localDataSource.addFoodWeightEntry(weight: weight, date: date);
  }

  /// Retrieve food weight entries from today.
  @override
  Future<List<FoodWeight>> getTodayFoodEntries() {
    return _localDataSource.getTodayFoodEntries();
  }

  /// Retrieve food weight entries by a specific date.
  @override
  Future<List<FoodWeight>> getFoodEntriesByDate(DateTime date) {
    return _localDataSource.getFoodEntriesByDate(date);
  }

  @override
  Future<List<FoodWeight>> getAllFoodEntries() {
    return _localDataSource.getAllFoodEntries();
  }

  /// Delete a food weight entry by [id].
  @override
  Future<int> deleteFoodWeightEntry(int id) {
    return _localDataSource.deleteFoodWeightEntry(id);
  }

  /// Update an existing food weight entry.
  @override
  Future<int> updateFoodWeightEntry({
    required int foodEntryId,
    required double foodEntryValue,
  }) {
    return _localDataSource.updateFoodWeightEntry(
      foodEntryId: foodEntryId,
      foodEntryValue: foodEntryValue,
    );
  }

  @override
  Future<double> getTotalConsumedYesterday() {
    return _localDataSource.getTotalConsumedYesterday();
  }

  @override
  Future<int> clearFoodEntries() => _localDataSource.clearFoodEntries();

  @override
  Future<List<FoodWeight>> fetchYesterdayEntries() {
    return _localDataSource.fetchYesterdayEntries();
  }

  @override
  Future<List<DayFoodLog>> getDailyFoodLogHistory() {
    return _localDataSource.getDailyFoodLogHistory();
  }
}
