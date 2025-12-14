import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/services/repositories/i_food_weight_repository.dart';

part 'daily_food_log_history_event.dart';
part 'daily_food_log_history_state.dart';

class DailyFoodLogHistoryBloc
    extends Bloc<DailyFoodLogHistoryEvent, DailyFoodLogHistoryState> {
  DailyFoodLogHistoryBloc(this._foodWeightRepository)
    : super(DailyFoodLogHistoryInitial()) {
    on<LoadDailyFoodLogHistoryEvent>((
      LoadDailyFoodLogHistoryEvent _,
      Emitter<DailyFoodLogHistoryState> emit,
    ) async {
      emit(DailyFoodLogHistoryLoading());
      try {
        final List<FoodWeight> foodLogs = await _foodWeightRepository
            .getAllFoodEntries();
        emit(DailyFoodLogHistoryLoaded(foodLogs));
      } catch (e) {
        emit(
          const DailyFoodLogHistoryError('Failed to load food log history.'),
        );
      }
    });
  }

  final IFoodWeightRepository _foodWeightRepository;
}
