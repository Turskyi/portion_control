import 'package:mocktail/mocktail.dart';
import 'package:portion_control/application_services/interactors/calculate_portion_control_use_case.dart';
import 'package:portion_control/application_services/interactors/clear_tracking_data_use_case.dart';

class MockCalculatePortionControlUseCase extends Mock
    implements CalculatePortionControlUseCase {}

class MockClearTrackingDataUseCase extends Mock
    implements ClearTrackingDataUseCase {}
