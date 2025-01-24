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

  /// Insert a new body weight entry.
  Future<int> insertBodyWeight(double weight, DateTime date) {
    return into(bodyWeightEntries).insert(
      BodyWeightEntriesCompanion(
        weight: Value<double>(weight),
        date: Value<DateTime>(date),
      ),
    );
  }

  /// Retrieve all entries, sorted by date.
  Future<List<BodyWeightEntry>> getAllEntries() {
    return (select(bodyWeightEntries)
          ..orderBy(<OrderClauseGenerator<$BodyWeightEntriesTable>>[
            ($BodyWeightEntriesTable t) {
              return OrderingTerm(expression: t.date, mode: OrderingMode.desc);
            },
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
