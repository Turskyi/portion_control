import 'package:portion_control/domain/services/repositories/i_tracking_repository.dart';
import 'package:portion_control/infrastructure/database/database.dart';

class TrackingRepository implements ITrackingRepository {
  const TrackingRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> clearTrackingData() {
    return _database.transaction(() async {
      await _database.clearBodyWeightEntries();
      await _database.clearBodyWeightEntries();
    });
  }
}
