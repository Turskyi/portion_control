import 'package:portion_control/domain/services/repositories/i_tracking_repository.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';

class TrackingRepository implements ITrackingRepository {
  const TrackingRepository(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  Future<void> clearTrackingData() => _localDataSource.clearTrackingData();
}
