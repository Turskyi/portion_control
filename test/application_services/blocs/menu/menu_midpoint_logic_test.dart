import 'package:flutter_test/flutter_test.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/domain/enums/midpoint_portion_control_action.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;

void main() {
  group('MenuBloc midpoint portion control logic', () {
    const double midpointWeight = 63.5;

    test('returns decrease when weight is above midpoint + buffer', () {
      final MidpointPortionControlAction action =
          MenuBloc.resolveMidpointPortionControlAction(
            bodyWeight: midpointWeight + constants.kMidpointBuffer + 0.1,
            midpointWeight: midpointWeight,
            buffer: constants.kMidpointBuffer,
          );

      expect(action, MidpointPortionControlAction.decrease);
    });

    test('returns increase when weight is below midpoint - buffer', () {
      final MidpointPortionControlAction action =
          MenuBloc.resolveMidpointPortionControlAction(
            bodyWeight: midpointWeight - constants.kMidpointBuffer - 0.1,
            midpointWeight: midpointWeight,
            buffer: constants.kMidpointBuffer,
          );

      expect(action, MidpointPortionControlAction.increase);
    });

    test('returns maintain when weight is within midpoint buffer band', () {
      final MidpointPortionControlAction actionAtMidpoint =
          MenuBloc.resolveMidpointPortionControlAction(
            bodyWeight: midpointWeight,
            midpointWeight: midpointWeight,
            buffer: constants.kMidpointBuffer,
          );

      final MidpointPortionControlAction actionAtUpperBoundary =
          MenuBloc.resolveMidpointPortionControlAction(
            bodyWeight: midpointWeight + constants.kMidpointBuffer,
            midpointWeight: midpointWeight,
            buffer: constants.kMidpointBuffer,
          );

      final MidpointPortionControlAction actionAtLowerBoundary =
          MenuBloc.resolveMidpointPortionControlAction(
            bodyWeight: midpointWeight - constants.kMidpointBuffer,
            midpointWeight: midpointWeight,
            buffer: constants.kMidpointBuffer,
          );

      expect(actionAtMidpoint, MidpointPortionControlAction.maintain);
      expect(actionAtUpperBoundary, MidpointPortionControlAction.maintain);
      expect(actionAtLowerBoundary, MidpointPortionControlAction.maintain);
    });
  });
}
