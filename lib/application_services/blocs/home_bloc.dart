import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:portion_control/application_services/extensions/date_time_extension.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/repositories/i_body_weight_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const BodyWeightLoading()) {
    on<LoadBodyWeightEntries>(_loadBodyWeightEntries);
    on<UpdateBodyWeight>(_updateBodyWeightState);
    on<SubmitBodyWeight>(_submitBodyWeight);
  }

  final IBodyWeightRepository _repository;

  FutureOr<void> _loadBodyWeightEntries(
    LoadBodyWeightEntries event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final List<BodyWeight> bodyWeightEntries =
          await _repository.getAllBodyWeightEntries();
      String lastBodyWeight = state.bodyWeight;
      if (bodyWeightEntries.isNotEmpty) {
        final BodyWeight lastSavedBodyWeightEntry = bodyWeightEntries.last;
        final DateTime lastSavedBodyWeightDate = lastSavedBodyWeightEntry.date;
        final DateTime today = DateTime.now();

        lastBodyWeight = lastSavedBodyWeightDate.isSameDate(today)
            ? '${lastSavedBodyWeightEntry.weight}'
            : '';
      }
      if (lastBodyWeight.isEmpty) {
        emit(
          BodyWeightLoaded(
            bodyWeight: lastBodyWeight,
            bodyWeightEntries: bodyWeightEntries,
          ),
        );
      } else {
        emit(
          BodyWeightSubmittedState(
            bodyWeight: lastBodyWeight,
          ),
        );
      }
    } catch (e) {
      emit(
        BodyWeightError(
          errorMessage: e.toString(),
          bodyWeight: state.bodyWeight,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }

  FutureOr<void> _updateBodyWeightState(
    UpdateBodyWeight event,
    Emitter<HomeState> emit,
  ) {
    emit(BodyWeightUpdatedState(bodyWeight: event.bodyWeight));
  }

  FutureOr<void> _submitBodyWeight(
    _,
    Emitter<HomeState> emit,
  ) async {
    if (state.bodyWeight.isNotEmpty) {
      final double? bodyWeight = double.tryParse(state.bodyWeight);
      if (bodyWeight != null) {
        try {
          // Insert into the database.
          await _repository.addBodyWeightEntry(
            weight: bodyWeight,
            date: DateTime.now(),
          );
        } catch (e) {
          // Handle errors (e.g. database issues).
          emit(
            BodyWeightError(
              errorMessage: 'Failed to submit body weight: ${e.toString()}',
              bodyWeight: state.bodyWeight,
              foodWeight: state.foodWeight,
            ),
          );
        }
        emit(BodyWeightSubmittedState(bodyWeight: state.bodyWeight));
      } else {
        emit(
          BodyWeightError(
            errorMessage: 'Invalid body weight',
            bodyWeight: state.bodyWeight,
            foodWeight: state.foodWeight,
          ),
        );
      }
    } else {
      emit(
        BodyWeightError(
          errorMessage: 'Body weight cannot be empty',
          bodyWeight: state.bodyWeight,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }
}
