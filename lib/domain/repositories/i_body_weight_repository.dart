import 'package:portion_control/domain/models/body_weight.dart';

abstract interface class IBodyWeightRepository {
  const IBodyWeightRepository();

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
}
