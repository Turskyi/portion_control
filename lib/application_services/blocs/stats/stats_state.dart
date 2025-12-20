import 'package:flutter/foundation.dart';

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
  });

  final double averageDailyIntake;
  final double weeklyWeightChange;
  final int limitExceededCount;
}

final class StatsError extends StatsState {
  const StatsError(this.message);

  final String message;
}
