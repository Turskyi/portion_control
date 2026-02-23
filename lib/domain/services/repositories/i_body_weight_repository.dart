import 'package:portion_control/domain/models/body_weight.dart';

abstract interface class IBodyWeightRepository {
  const IBodyWeightRepository();

  /// Returns the `rowid` of the inserted row.
  Future<int> addOrUpdateBodyWeightEntry({
    required double weight,
    required DateTime date,
  });

  Future<List<BodyWeight>> getAllBodyWeightEntries();

  Future<int> deleteBodyWeightEntry(int id);

  Future<bool> updateBodyWeightEntry({
    required int id,
    required double weight,
    required DateTime date,
  });

  Future<int> clearBodyWeightEntries();

  Future<BodyWeight> getTodayBodyWeight();

  Future<BodyWeight> getLastBodyWeight();

  Future<int> getBodyWeightStreak();
}
