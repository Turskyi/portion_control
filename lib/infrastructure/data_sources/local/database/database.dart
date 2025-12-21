import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/tables/body_weight_entries.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/tables/food_entries.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/tables/portion_control_entries.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;

part 'database.g.dart';

@DriftDatabase(
  tables: <Type>[BodyWeightEntries, FoodEntries, PortionControlEntries],
)
class AppDatabase extends _$AppDatabase {
  /// The database class for the application.
  ///
  /// This class is named `AppDatabase` to follow the convention in the official
  /// Drift example, even though the filename is `database.dart`.
  /// See: https://github.com/simolus3/drift/tree/develop/examples/app/lib/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (Migrator migrator, int from, int to) async {
        if (from < 2) {
          await migrator.createTable(portionControlEntries);
        }
      },
    );
  }

  /// Insert or update a body weight entry for the same date.
  /// Returns the `rowid` of the inserted row.
  Future<int> insertOrUpdateBodyWeight(double weight, DateTime date) async {
    // Normalize the date to ensure only the day is considered.
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);

    // Check if an entry for the same date already exists.
    final BodyWeightEntry? existingEntry =
        await (select(bodyWeightEntries)..where(
              ($BodyWeightEntriesTable entry) =>
                  entry.date.equals(normalizedDate),
            ))
            .getSingleOrNull();

    if (existingEntry != null) {
      // If an entry exists, update it.
      return (update(bodyWeightEntries)..where(
            ($BodyWeightEntriesTable entry) =>
                entry.date.equals(normalizedDate),
          ))
          .write(BodyWeightEntriesCompanion(weight: Value<double>(weight)));
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

  /// Retrieve all body weight entries, sorted by date.
  Future<List<BodyWeightEntry>> getAllBodyWeightEntries() {
    return (select(bodyWeightEntries)
          ..orderBy(<OrderClauseGenerator<$BodyWeightEntriesTable>>[
            ($BodyWeightEntriesTable t) => OrderingTerm(expression: t.date),
          ]))
        .get();
  }

  /// Retrieve all food entries, sorted by date.
  Future<List<FoodEntry>> getAllFoodEntries() {
    return (select(foodEntries)
          ..orderBy(<OrderClauseGenerator<$FoodEntriesTable>>[
            ($FoodEntriesTable t) => OrderingTerm(expression: t.date),
          ]))
        .get();
  }

  Future<int> insertFoodEntry(FoodEntriesCompanion entry) {
    return into(foodEntries).insert(entry);
  }

  /// Updates the [weight] of a food entry identified by [id].
  ///
  /// Returns the number of rows affected (should be `1` if the entry exists,
  /// `0` if no matching entry was found).
  Future<int> updateFoodEntry({required int id, required double weight}) {
    return (update(foodEntries)
          ..where(($FoodEntriesTable tbl) => tbl.id.equals(id)))
        .write(FoodEntriesCompanion(weight: Value<double>(weight)));
  }

  Future<int> deleteFoodEntry(int id) {
    return (delete(
      foodEntries,
    )..where(($FoodEntriesTable tbl) => tbl.id.equals(id))).go();
  }

  Future<List<FoodEntry>> getFoodEntriesByDate(DateTime date) {
    final DateTime startOfDay = DateTime(date.year, date.month, date.day);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(foodEntries)..where(
          ($FoodEntriesTable tbl) =>
              tbl.date.isBiggerOrEqualValue(startOfDay) &
              tbl.date.isSmallerThanValue(endOfDay),
        ))
        .get();
  }

  Future<int> getTodayBodyWeightEntriesCount() async {
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);

    final SimpleSelectStatement<$BodyWeightEntriesTable, BodyWeightEntry>
    query = select(bodyWeightEntries)
      ..where(
        ($BodyWeightEntriesTable tbl) =>
            tbl.date.isBiggerOrEqualValue(startOfDay),
      );

    return query.get().then((List<BodyWeightEntry> entries) => entries.length);
  }

  Future<double> getTotalConsumedYesterday() async {
    final DateTime now = DateTime.now();
    final DateTime yesterdayStart = DateTime(now.year, now.month, now.day - 1);
    final DateTime yesterdayEnd = yesterdayStart.add(const Duration(days: 1));

    try {
      final List<FoodEntry> result =
          await (select(foodEntries)..where(
                ($FoodEntriesTable tbl) =>
                    tbl.date.isBiggerOrEqualValue(yesterdayStart) &
                    tbl.date.isSmallerThanValue(yesterdayEnd),
              ))
              .get();

      return result.fold<double>(
        0.0,
        (double sum, FoodEntry entry) => sum + entry.weight,
      );
    } catch (error, stackTrace) {
      debugPrint('Error while accessing food_entries table: $error.');
      debugPrint('Stack trace: $stackTrace');
      return 0.0;
    }
  }

  /// Returns the amount of rows that were deleted by this statement directly
  /// (not including additional rows that might be affected through triggers or
  /// foreign key constraints).
  Future<int> clearFoodEntries() => delete(foodEntries).go();

  /// Returns the amount of rows that were deleted by this statement directly
  /// (not including additional rows that might be affected through triggers or
  /// foreign key constraints).
  Future<int> clearBodyWeightEntries() => delete(bodyWeightEntries).go();

  Future<BodyWeightEntry?> getTodayBodyWeight() {
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(bodyWeightEntries)..where(
          ($BodyWeightEntriesTable table) =>
              table.date.isBiggerOrEqualValue(startOfDay) &
              table.date.isSmallerThanValue(endOfDay),
        ))
        .getSingleOrNull();
  }

  /// Retrieve all food entries from yesterday.
  Future<List<FoodEntry>> fetchYesterdayEntries() async {
    final DateTime now = DateTime.now();
    final DateTime yesterdayStart = DateTime(now.year, now.month, now.day - 1);
    final DateTime yesterdayEnd = yesterdayStart.add(const Duration(days: 1));

    try {
      return await (select(foodEntries)..where(
            ($FoodEntriesTable tbl) =>
                tbl.date.isBiggerOrEqualValue(yesterdayStart) &
                tbl.date.isSmallerThanValue(yesterdayEnd),
          ))
          .get();
    } catch (error, stackTrace) {
      debugPrint('Error while fetching yesterday\'s entries: $error.');
      debugPrint('Stack trace: $stackTrace');
      return <FoodEntry>[];
    }
  }

  Future<BodyWeightEntry?> getLastBodyWeight() async {
    final List<BodyWeightEntry> entries = await getAllBodyWeightEntries();
    return entries.isNotEmpty ? entries.last : null;
  }

  /// Returns the number of consecutive days with at least one body weight
  /// entry.
  ///
  /// The streak is calculated backwards starting from **today if present,
  /// otherwise from yesterday**. The streak stops at the first missing day.
  ///
  /// This means:
  /// - If the user logged weight yesterday but not yet today, the streak is
  /// preserved.
  /// - If the user skipped yesterday, the streak resets to 0.
  Future<int> getBodyWeightStreak() async {
    final List<BodyWeightEntry> entries = await getAllBodyWeightEntries();

    if (entries.isEmpty) {
      return 0;
    }

    // Normalize all entry dates to day precision
    final Set<DateTime> entryDays = entries.map(
      (BodyWeightEntry entry) {
        return DateTime(entry.date.year, entry.date.month, entry.date.day);
      },
    ).toSet();

    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    // Start from today if present, otherwise from yesterday
    DateTime dayCursor = entryDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));

    // If neither today nor yesterday has an entry, streak is broken.
    if (!entryDays.contains(dayCursor)) {
      return 0;
    }

    int streak = 0;

    while (entryDays.contains(dayCursor)) {
      streak++;
      dayCursor = dayCursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<double> getMaxConsumptionWhenWeightDecreased() async {
    final List<BodyWeightEntry> bodyWeights = await getAllBodyWeightEntries();
    if (bodyWeights.length < 2) {
      return constants.maxDailyFoodLimit;
    }

    final List<FoodEntry> foodEntries = await getAllFoodEntries();
    if (foodEntries.isEmpty) {
      return constants.maxDailyFoodLimit;
    }

    // Map date to total consumption.
    final Map<DateTime, double> dailyConsumption = <DateTime, double>{};
    for (final FoodEntry entry in foodEntries) {
      final DateTime date = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      dailyConsumption[date] = (dailyConsumption[date] ?? 0.0) + entry.weight;
    }

    double maxConsumption = constants.maxDailyFoodLimit;

    for (int i = 1; i < bodyWeights.length; i++) {
      final BodyWeightEntry current = bodyWeights[i];
      final BodyWeightEntry previous = bodyWeights[i - 1];

      // Check if weight decreased.
      if (current.weight < previous.weight) {
        // Find consumption for the day before the weight measurement
        // Assuming weight is measured in the morning.
        final DateTime weightDate = current.date;
        final DateTime consumptionDate = DateTime(
          weightDate.year,
          weightDate.month,
          weightDate.day,
        ).subtract(const Duration(days: 1));

        final double? consumption = dailyConsumption[consumptionDate];
        if (consumption != null && consumption > maxConsumption) {
          maxConsumption = consumption;
        }
      }
    }
    return maxConsumption;
  }

  Future<void> insertPortionControl({
    required double value,
    required DateTime date,
  }) async {
    await into(portionControlEntries).insert(
      PortionControlEntriesCompanion.insert(
        value: value,
        date: date,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<double?> getLatestPortionControl() async {
    final PortionControlEntry? row =
        await (select(portionControlEntries)
              ..orderBy(<OrderClauseGenerator<$PortionControlEntriesTable>>[
                ($PortionControlEntriesTable t) => OrderingTerm(
                  expression: t.date,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();

    return row?.value;
  }

  Future<double?> getPortionControlForDate(DateTime day) async {
    final DateTime start = DateTime(day.year, day.month, day.day);
    final DateTime end = start.add(const Duration(days: 1));

    final PortionControlEntry? row =
        await (select(portionControlEntries)
              ..where(
                ($PortionControlEntriesTable t) =>
                    t.date.isSmallerThanValue(end),
              )
              ..orderBy(<OrderClauseGenerator<$PortionControlEntriesTable>>[
                ($PortionControlEntriesTable t) => OrderingTerm(
                  expression: t.date,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();

    return row?.value;
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

  Future<List<PortionControlEntry>> getAllPortionControls() {
    return select(portionControlEntries).get();
  }
}
