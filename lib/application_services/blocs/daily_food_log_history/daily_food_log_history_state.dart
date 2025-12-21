part of 'daily_food_log_history_bloc.dart';

abstract class DailyFoodLogHistoryState extends Equatable {
  const DailyFoodLogHistoryState({required this.days});

  final List<DayFoodLog> days;

  @override
  List<Object> get props => <Object>[days];
}

class DailyFoodLogHistoryInitial extends DailyFoodLogHistoryState {
  DailyFoodLogHistoryInitial() : super(days: <DayFoodLog>[]);
}

class DailyFoodLogHistoryLoading extends DailyFoodLogHistoryState {
  const DailyFoodLogHistoryLoading({required super.days});
}

class DailyFoodLogHistoryLoaded extends DailyFoodLogHistoryState {
  const DailyFoodLogHistoryLoaded({required super.days});

  // The list of days is already in the base class,
  // so no need to redeclare it here.
}

class DailyFoodLogHistoryError extends DailyFoodLogHistoryState {
  const DailyFoodLogHistoryError({
    required this.message,
    required super.days,
  });

  final String message;

  @override
  List<Object> get props => <Object>[message, days];
}
