import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/services/repositories/i_body_weight_repository.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/data_mappers/body_weight_entries_mapper.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/database.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';

class BodyWeightRepository implements IBodyWeightRepository {
  /// Constructor to inject the local data source instance.
  const BodyWeightRepository(this._localDataSource);

  final LocalDataSource _localDataSource;

  /// Insert a new body weight entry.
  @override
  Future<int> addOrUpdateBodyWeightEntry({
    required double weight,
    required DateTime date,
  }) {
    return _localDataSource.insertOrUpdateBodyWeight(weight, date);
  }

  /// Retrieve all body weight entries, sorted by date.
  @override
  Future<List<BodyWeight>> getAllBodyWeightEntries() async {
    final List<BodyWeightEntry> bodyWeightEntries = await _localDataSource
        .getAllBodyWeightEntries();
    return bodyWeightEntries
        .map((BodyWeightEntry entry) => entry.toDomain())
        .toList();
  }

  /// Delete a body weight entry by id.
  @override
  Future<int> deleteBodyWeightEntry(int id) {
    return _localDataSource.deleteBodyWeightEntry(id);
  }

  /// Update a body weight entry by id.
  @override
  Future<bool> updateBodyWeightEntry({
    required int id,
    required double weight,
    required DateTime date,
  }) {
    return _localDataSource.updateBodyWeightEntry(
      id: id,
      weight: weight,
      date: date,
    );
  }

  @override
  Future<int> clearAllTrackingData() => _localDataSource.clearAllTrackingData();

  @override
  Future<BodyWeight> getTodayBodyWeight() {
    return _localDataSource.getTodayBodyWeight();
  }

  @override
  Future<BodyWeight> getLastBodyWeight() {
    return _localDataSource.getLastBodyWeight();
  }
}
