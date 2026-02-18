import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/home/widgets/meal_confirmation_card.dart';
import 'package:portion_control/ui/home/widgets/message_with_info.dart';

class PortionControlMessage extends StatelessWidget {
  const PortionControlMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? titleMediumStyle = textTheme.titleMedium;
    final String gramsSuffix = translate('portion_control_status.grams_suffix');
    final String useAsReferenceSuffix = translate(
      'portion_control_status.use_as_reference_suffix',
    );

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final bool isWeightAboveHealthy = state.isWeightAboveHealthy;
        final bool isWeightBelowHealthy = state.isWeightBelowHealthy;
        final bool isWeightDecreasing = state.isWeightDecreasing;
        final bool isWeightIncreasing = state.isWeightIncreasing;
        final double portionControl = state.adjustedPortion;
        final double yesterdayTotal = state.yesterdayConsumedTotal;

        if (state.hasNoPortionControl) {
          return Text(
            translate('portion_control_status.no_portion_control_today'),
            style: titleMediumStyle,
          );
        } else if (state.isWeightIncreasingOrSame && isWeightAboveHealthy) {
          if (state.isMealsConfirmedForToday) {
            final String limitValue =
                (portionControl > constants.kSafeMinimumFoodIntakeG &&
                    portionControl != constants.kMaxDailyFoodLimit)
                ? state.formattedPortionControl
                : state.formattedSafeMinimumFoodIntake;

            final String prefix = translate(
              'portion_control_status.portion_control_for_today_prefix',
            );
            final String suffix = translate(
              'portion_control_status.grams_suffix_with_emoji',
            );

            return MessageWithInfo(
              text: '$prefix$limitValue$suffix',
              style: titleMediumStyle,
            );
          } else if (!state.isMealsConfirmedForToday) {
            return MealConfirmationCard(yesterdayTotal: yesterdayTotal);
          }
        } else if (isWeightDecreasing && isWeightAboveHealthy) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: <Widget>[
              Text(
                translate('portion_control_status.weight_decreasing_celebrate'),
                style: titleMediumStyle,
              ),
              if (yesterdayTotal > 0)
                Text(
                  '${translate('portion_control_status.yesterday_prefix')}'
                  '$yesterdayTotal$gramsSuffix'
                  '${state.previousPortionControlInfo}\n'
                  '$useAsReferenceSuffix',
                  style: textTheme.bodyMedium,
                )
              else if (portionControl > constants.kSafeMinimumFoodIntakeG &&
                  portionControl < constants.kMaxDailyFoodLimit)
                Text(
                  '${state.previousPortionControlInfo}\n'
                  '$useAsReferenceSuffix',
                  style: textTheme.bodyMedium,
                ),
            ],
          );
        } else if (isWeightIncreasing && isWeightBelowHealthy) {
          return Text(
            translate('portion_control_status.weight_increasing_good'),
            style: titleMediumStyle,
          );
        } else if (state.isWeightDecreasingOrSame && isWeightBelowHealthy) {
          if (state.isMealsConfirmedForToday &&
              portionControl > constants.kSafeMinimumFoodIntakeG) {
            if (portionControl != constants.kMaxDailyFoodLimit &&
                portionControl != constants.kSafeMinimumFoodIntakeG) {
              final String prefix = translate(
                'portion_control_status.warning_weight_dropping_prefix',
              );
              final String suffix = translate(
                'portion_control_status.grams_suffix_with_emoji',
              );

              return MessageWithInfo(
                text: '$prefix${state.formattedPortionControl}$suffix',
                style: titleMediumStyle,
              );
            }
          } else if (!state.isMealsConfirmedForToday) {
            return MealConfirmationCard(yesterdayTotal: yesterdayTotal);
          } else {
            return Text(
              translate(
                'portion_control_status.warning_weight_dropping_general',
              ),
              style: titleMediumStyle,
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
