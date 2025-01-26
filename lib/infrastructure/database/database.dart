import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portion_control/infrastructure/database/tables/body_weight_entries.dart';

part 'database.g.dart';

@DriftDatabase(tables: <Type>[BodyWeightEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 1;

  /// Insert or update a body weight entry for the same date.
  /// Returns the `rowid` of the inserted row.
  Future<int> insertOrUpdateBodyWeight(double weight, DateTime date) async {
    // Normalize the date to ensure only the day is considered.
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);

    // Check if an entry for the same date already exists.
    final BodyWeightEntry? existingEntry = await (select(bodyWeightEntries)
          ..where(
            ($BodyWeightEntriesTable entry) =>
                entry.date.equals(normalizedDate),
          ))
        .getSingleOrNull();

    if (existingEntry != null) {
      // If an entry exists, update it.
      return (update(bodyWeightEntries)
            ..where(
              ($BodyWeightEntriesTable entry) =>
                  entry.date.equals(normalizedDate),
            ))
          .write(
        BodyWeightEntriesCompanion(
          weight: Value<double>(weight),
        ),
      );
    } else {
      // If no entry exists, insert a new one.
      return into(bodyWeightEntries).insert(
        BodyWeightEntriesCompanion(
          weight: Value<double>(weight),
          date: Value<DateTime>(normalizedDate),
        ),
      );
    }
  }

  /// Retrieve all entries, sorted by date.
  Future<List<BodyWeightEntry>> getAllEntries() {
    return (select(bodyWeightEntries)
          ..orderBy(<OrderClauseGenerator<$BodyWeightEntriesTable>>[
            ($BodyWeightEntriesTable t) => OrderingTerm(expression: t.date),
          ]))
        .get();
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'portion_control_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
        onResult: (WasmDatabaseResult result) {
          if (result.missingFeatures.isNotEmpty && kDebugMode) {
            debugPrint(
              'Using ${result.chosenImplementation} due to '
              'unsupported browser features: '
              '${result.missingFeatures}',
            );
          }
        },
      ),
    );
  }
}
