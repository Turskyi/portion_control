import 'package:drift/drift.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/repositories/i_food_weight_repository.dart';
import 'package:portion_control/infrastructure/database/data_mappers/food_entries_mapper.dart';
import 'package:portion_control/infrastructure/database/database.dart';

class FoodWeightRepository implements IFoodWeightRepository {
  const FoodWeightRepository(this._database);

  final AppDatabase _database;

  /// Insert a new food weight entry.
  @override
  Future<int> addFoodWeightEntry({
    required double weight,
    required DateTime date,
  }) {
    final FoodEntriesCompanion entry = FoodEntriesCompanion(
      weight: Value<double>(weight),
      date: Value<DateTime>(date),
    );

    return _database.insertFoodEntry(entry);
  }

  /// Retrieve food weight entries from today.
  @override
  Future<List<FoodWeight>> getTodayFoodEntries() async {
    final List<FoodEntry> foodEntries =
        await _database.getFoodEntriesByDate(DateTime.now());

    return foodEntries
        .map((FoodEntry weightEntry) => weightEntry.toDomain())
        .toList();
  }

  /// Retrieve food weight entries by a specific date.
  @override
  Future<List<FoodWeight>> getFoodEntriesByDate(DateTime date) async {
    final List<FoodEntry> foodEntries =
        await _database.getFoodEntriesByDate(date);
    return foodEntries
        .map((FoodEntry weightEntry) => weightEntry.toDomain())
        .toList();
  }

  /// Delete a food weight entry by [id].
  @override
  Future<int> deleteFoodWeightEntry(int id) async {
    return _database.deleteFoodEntry(id);
  }

  /// Update an existing food weight entry.
  @override
  Future<int> updateFoodWeightEntry({
    required int foodEntryId,
    required double foodEntryValue,
  }) {
    return _database.updateFoodEntry(id: foodEntryId, weight: foodEntryValue);
  }
}
