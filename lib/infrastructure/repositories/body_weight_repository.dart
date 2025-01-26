import 'package:drift/drift.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/repositories/i_body_weight_repository.dart';
import 'package:portion_control/infrastructure/database/data_mappers/body_weight_entries_mapper.dart';
import 'package:portion_control/infrastructure/database/database.dart';

class BodyWeightRepository implements IBodyWeightRepository {
  /// Constructor to inject the database instance.
  const BodyWeightRepository(this._database);

  final AppDatabase _database;

  /// Insert a new body weight entry.
  @override
  Future<int> addOrUpdateBodyWeightEntry({
    required double weight,
    required DateTime date,
  }) {
    return _database.insertOrUpdateBodyWeight(weight, date);
  }

  /// Retrieve all body weight entries, sorted by date.
  @override
  Future<List<BodyWeight>> getAllBodyWeightEntries() async {
    final List<BodyWeightEntry> bodyWeightEntries =
        await _database.getAllEntries();
    return bodyWeightEntries
        .map((BodyWeightEntry entry) => entry.toDomain())
        .toList();
  }

  /// Delete a body weight entry by id.
  @override
  Future<int> deleteBodyWeightEntry(int id) {
    return (_database.delete(_database.bodyWeightEntries)
          ..where(($BodyWeightEntriesTable tbl) => tbl.id.equals(id)))
        .go();
  }

  /// Update a body weight entry by id.
  @override
  Future<bool> updateBodyWeightEntry({
    required int id,
    required double weight,
    required DateTime date,
  }) async {
    final int updatedRows = await (_database.update(_database.bodyWeightEntries)
          ..where(($BodyWeightEntriesTable tbl) => tbl.id.equals(id)))
        .write(
      BodyWeightEntriesCompanion(
        weight: Value<double>(weight),
        date: Value<DateTime>(date),
      ),
    );
    // Return true if any row was updated.
    return updatedRows > 0;
  }
}
