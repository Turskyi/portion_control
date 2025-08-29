import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/services/repositories/i_food_weight_repository.dart';

part 'yesterday_entries_event.dart';
part 'yesterday_entries_state.dart';

class YesterdayEntriesBloc
    extends Bloc<YesterdayEntriesEvent, YesterdayEntriesState> {
  YesterdayEntriesBloc(this._foodRepository)
      : super(const YesterdayEntriesInitial()) {
    on<LoadYesterdayEntries>(_onLoadYesterdayEntries);
  }

  final IFoodWeightRepository _foodRepository;

  Future<void> _onLoadYesterdayEntries(
    LoadYesterdayEntries _,
    Emitter<YesterdayEntriesState> emit,
  ) async {
    emit(const YesterdayEntriesLoading());
    try {
      final List<FoodWeight> foodEntries =
          await _foodRepository.fetchYesterdayEntries();
      emit(YesterdayEntriesLoaded(foodEntries));
    } catch (e) {
      debugPrint('Error loading yesterday entries: $e');
      emit(YesterdayEntriesError('Failed to load yesterday entries: $e'));
    }
  }
}
