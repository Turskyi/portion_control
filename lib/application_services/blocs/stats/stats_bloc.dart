import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/stats/stats_state.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/day_food_log.dart';
import 'package:portion_control/domain/services/repositories/i_body_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_food_weight_repository.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;

part 'stats_event.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc(
    this._foodWeightRepository,
    this._bodyWeightRepository,
  ) : super(const StatsInitial()) {
    on<LoadStatsEvent>(_onLoadStats);
  }

  final IFoodWeightRepository _foodWeightRepository;
  final IBodyWeightRepository _bodyWeightRepository;

  Future<void> _onLoadStats(
    LoadStatsEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(const StatsLoading());
    try {
      final List<DayFoodLog> foodLogs = await _foodWeightRepository
          .getDailyFoodLogHistory();
      final List<BodyWeight> weightLogs = await _bodyWeightRepository
          .getAllBodyWeightEntries();

      // 1. Average Daily Intake
      double averageDailyIntake = 0;
      if (foodLogs.isNotEmpty) {
        final double totalIntake = foodLogs.fold(
          0,
          (double sum, DayFoodLog log) => sum + log.totalConsumed,
        );
        averageDailyIntake = totalIntake / foodLogs.length;
      }

      // 2. Weight Change per Week.
      double weeklyWeightChange = 0;
      if (weightLogs.length >= 2) {
        final BodyWeight currentWeight = weightLogs.last;
        // Find entry closest to 7 days ago
        final DateTime targetDate = currentWeight.date.subtract(
          const Duration(days: 7),
        );

        BodyWeight? pastWeight;
        // Since logs are sorted by date
        // (as per `getAllBodyWeightEntries` implementation), we can search.
        // Or simply iterate backwards to find the first entry <= targetDate.
        for (int i = weightLogs.length - 2; i >= 0; i--) {
          if (weightLogs[i].date.isBefore(targetDate) ||
              weightLogs[i].date.isAtSameMomentAs(targetDate)) {
            pastWeight = weightLogs[i];
            break;
          }
        }
        // If no entry found exactly 7 days ago or before, use the oldest one
        // if it's within reasonable time, or just the first one.
        pastWeight ??= weightLogs.first;

        weeklyWeightChange = currentWeight.weight - pastWeight.weight;
      }

      // 3. How often limit was exceeded.
      int limitExceededCount = 0;
      for (final DayFoodLog log in foodLogs) {
        // Assuming dailyLimit 0 means no limit or not set, so we skip it.
        // Also skipping if consumption is 0 (empty day).
        if (log.dailyLimit > 0 &&
            log.totalConsumed > 0 &&
            log.totalConsumed > log.dailyLimit &&
            log.dailyLimit < constants.kMaxDailyFoodLimit) {
          limitExceededCount++;
        }
      }

      emit(
        StatsLoaded(
          averageDailyIntake: averageDailyIntake,
          weeklyWeightChange: weeklyWeightChange,
          limitExceededCount: limitExceededCount,
          lastSevenDaysIntake: foodLogs.take(DateTime.daysPerWeek).toList(),
          lastTwoWeeksBodyWeightEntries: weightLogs
              .take(DateTime.daysPerWeek * 2)
              .toList(),
        ),
      );
    } catch (e) {
      debugPrint('Error in _onLoadStats: $e');
      emit(StatsError(e.toString()));
    }
  }
}
