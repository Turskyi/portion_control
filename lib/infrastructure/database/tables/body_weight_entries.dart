import 'package:drift/drift.dart';

class BodyWeightEntries extends Table {
  const BodyWeightEntries();

  IntColumn get id => integer().autoIncrement()();

  /// For storing [weight] (in kilograms or pounds).
  RealColumn get weight => real()();

  /// The [date] the weight was recorded.
  DateTimeColumn get date => dateTime()();
}
