part of 'daily_food_log_history_bloc.dart';

abstract class DailyFoodLogHistoryState extends Equatable {
  const DailyFoodLogHistoryState();

  @override
  List<Object> get props => <Object>[];
}

class DailyFoodLogHistoryInitial extends DailyFoodLogHistoryState {}

class DailyFoodLogHistoryLoading extends DailyFoodLogHistoryState {}

class DailyFoodLogHistoryLoaded extends DailyFoodLogHistoryState {
  const DailyFoodLogHistoryLoaded(this.foodLogs);

  final List<FoodWeight> foodLogs;

  @override
  List<Object> get props => <Object>[foodLogs];
}

class DailyFoodLogHistoryError extends DailyFoodLogHistoryState {
  const DailyFoodLogHistoryError(this.message);

  final String message;

  @override
  List<Object> get props => <Object>[message];
}
