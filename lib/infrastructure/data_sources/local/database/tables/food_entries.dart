import 'package:drift/drift.dart';

class FoodEntries extends Table {
  const FoodEntries();

  IntColumn get id => integer().autoIncrement()();

  /// For storing [weight].
  RealColumn get weight => real()();

  /// The [date] the weight was recorded.
  DateTimeColumn get date => dateTime()();

  /// Index `date` for faster lookups
  List<Set<Column<Object>>> get indexes => <Set<Column<Object>>>[
    <Column<Object>>{date},
  ];
}
