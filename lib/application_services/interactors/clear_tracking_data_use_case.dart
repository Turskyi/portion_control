import 'package:portion_control/domain/services/interactors/i_clear_tracking_data_use_case.dart';
import 'package:portion_control/domain/services/repositories/i_tracking_repository.dart';

class ClearTrackingDataUseCase implements IClearTrackingDataUseCase {
  const ClearTrackingDataUseCase(this._trackingRepository);

  final ITrackingRepository _trackingRepository;

  @override
  Future<void> execute() => _trackingRepository.clearTrackingData();
}
