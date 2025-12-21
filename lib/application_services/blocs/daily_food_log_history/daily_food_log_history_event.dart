part of 'daily_food_log_history_bloc.dart';

abstract class DailyFoodLogHistoryEvent extends Equatable {
  const DailyFoodLogHistoryEvent();

  @override
  List<Object> get props => <Object>[];
}

class LoadDailyFoodLogHistoryEvent extends DailyFoodLogHistoryEvent {}
