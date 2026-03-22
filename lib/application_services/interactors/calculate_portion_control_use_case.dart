import 'package:portion_control/domain/enums/midpoint_portion_control_action.dart';
import 'package:portion_control/domain/models/bmi_category.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/domain/services/interactors/i_calculate_portion_control_use_case.dart';
import 'package:portion_control/domain/services/repositories/i_body_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_food_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_preferences_repository.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;

class CalculatePortionControlUseCase
    implements ICalculatePortionControlUseCase {
  const CalculatePortionControlUseCase(
    this._bodyWeightRepository,
    this._foodWeightRepository,
    this._userPreferencesRepository,
  );

  final IBodyWeightRepository _bodyWeightRepository;
  final IFoodWeightRepository _foodWeightRepository;
  final IUserPreferencesRepository _userPreferencesRepository;

  static MidpointPortionControlAction resolveMidpointPortionControlAction({
    required double bodyWeight,
    required double midpointWeight,
    required double buffer,
  }) {
    if (bodyWeight > midpointWeight + buffer) {
      return MidpointPortionControlAction.decrease;
    }
    if (bodyWeight < midpointWeight - buffer) {
      return MidpointPortionControlAction.increase;
    }
    return MidpointPortionControlAction.maintain;
  }

  @override
  Future<double> call() async {
    final BodyWeight bodyWeightEntry = await _bodyWeightRepository
        .getLastBodyWeight();
    double portionControl = constants.kMaxDailyFoodLimit;

    if (bodyWeightEntry.weight > 0) {
      final double bodyWeight = bodyWeightEntry.weight;
      final UserDetails userDetails = _userPreferencesRepository
          .getUserDetails();
      final bool hasValidHeight =
          userDetails.heightInCm > constants.kMinUserHeight;
      final double midpointWeight = hasValidHeight
          ? BmiCategory.midpointWeight(userDetails.heightInCm)
          : bodyWeight;
      final MidpointPortionControlAction midpointAction = hasValidHeight
          ? resolveMidpointPortionControlAction(
              bodyWeight: bodyWeight,
              midpointWeight: midpointWeight,
              buffer: constants.kMidpointBuffer,
            )
          : MidpointPortionControlAction.maintain;
      final bool isWeightAboveMidpoint =
          midpointAction == MidpointPortionControlAction.decrease;
      final bool isWeightBelowMidpoint =
          midpointAction == MidpointPortionControlAction.increase;

      if (isWeightAboveMidpoint) {
        portionControl = await _userPreferencesRepository
            .getMinConsumptionWhenWeightIncreased();
      } else if (isWeightBelowMidpoint) {
        portionControl = await _userPreferencesRepository
            .getMaxConsumptionWhenWeightDecreased();
      }

      final double savedPortionControl = _userPreferencesRepository
          .getLastPortionControl();

      if (isWeightAboveMidpoint) {
        if (portionControl == constants.kMaxDailyFoodLimit) {
          if (savedPortionControl != constants.kMaxDailyFoodLimit) {
            portionControl = savedPortionControl;
          } else {
            final double yesterdayTotal = await _foodWeightRepository
                .getTotalConsumedYesterday();
            if (yesterdayTotal > constants.kSafeMinimumFoodIntakeG) {
              portionControl = yesterdayTotal;
            }
          }
        } else if (savedPortionControl != constants.kMaxDailyFoodLimit &&
            savedPortionControl < portionControl) {
          portionControl = savedPortionControl;
        }
      } else if (isWeightBelowMidpoint) {
        if (portionControl == constants.kSafeMinimumFoodIntakeG) {
          if (savedPortionControl != constants.kMaxDailyFoodLimit) {
            portionControl = savedPortionControl;
          }
        } else if (savedPortionControl != constants.kMaxDailyFoodLimit &&
            savedPortionControl > portionControl) {
          portionControl = savedPortionControl;
        }
      } else if (savedPortionControl != constants.kMaxDailyFoodLimit) {
        portionControl = savedPortionControl;
      }
    }
    return portionControl;
  }
}
