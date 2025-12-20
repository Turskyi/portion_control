import 'package:drift/drift.dart';

class PortionControlEntries extends Table {
  const PortionControlEntries();

  IntColumn get id => integer().autoIncrement()();

  /// When this portion control value became active.
  DateTimeColumn get date => dateTime()();

  /// Portion control value in grams.
  RealColumn get value => real()();
}
