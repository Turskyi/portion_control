import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/domain/models/day_food_log.dart';
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
      emit(DailyFoodLogHistoryLoading(days: state.days));
      try {
        final List<DayFoodLog> foodLogs = await _foodWeightRepository
            .getDailyFoodLogHistory();
        emit(DailyFoodLogHistoryLoaded(days: foodLogs));
      } catch (e) {
        emit(
          DailyFoodLogHistoryError(
            message: translate('error.failed_to_load_food_log_history'),
            days: state.days,
          ),
        );
      }
    });
  }

  final IFoodWeightRepository _foodWeightRepository;
}
