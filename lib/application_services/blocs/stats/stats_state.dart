import 'package:flutter/foundation.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/day_food_log.dart';

@immutable
sealed class StatsState {
  const StatsState();
}

final class StatsInitial extends StatsState {
  const StatsInitial();
}

final class StatsLoading extends StatsState {
  const StatsLoading();
}

final class StatsLoaded extends StatsState {
  const StatsLoaded({
    required this.averageDailyIntake,
    required this.weeklyWeightChange,
    required this.limitExceededCount,
    required this.lastSevenDaysIntake,
    required this.lastTwoWeeksBodyWeightEntries,
  });

  final double averageDailyIntake;
  final double weeklyWeightChange;
  final int limitExceededCount;
  final List<DayFoodLog> lastSevenDaysIntake;
  final List<BodyWeight> lastTwoWeeksBodyWeightEntries;
}

final class StatsError extends StatsState {
  const StatsError(this.message);

  final String message;
}
