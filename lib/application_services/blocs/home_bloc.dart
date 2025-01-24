import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:portion_control/domain/repositories/i_body_weight_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const HomeInitial()) {
    on<UpdateBodyWeight>(_updateBodyWeightState);
    on<SubmitBodyWeight>(_submitBodyWeight);
    on<LoadBodyWeightEntries>(_loadBodyWeightEntries);
  }

  final IBodyWeightRepository _repository;

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
          // Handle errors (e.g. database issues)
          emit(
            BodyWeightError(
              errorMessage: 'Failed to submit body weight: ${e.toString()}',
              bodyWeight: state.bodyWeight,
            ),
          );
        }
        emit(BodyWeightSubmittedState(bodyWeight: state.bodyWeight));
      } else {
        emit(
          BodyWeightError(
            errorMessage: 'Invalid body weight',
            bodyWeight: state.bodyWeight,
          ),
        );
      }
    } else {
      emit(
        BodyWeightError(
          errorMessage: 'Body weight cannot be empty',
          bodyWeight: state.bodyWeight,
        ),
      );
    }
  }

  FutureOr<void> _loadBodyWeightEntries(
    LoadBodyWeightEntries event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(BodyWeightLoading(bodyWeight: state.bodyWeight));
      //TODO: emit loaded state.
    } catch (e) {
      emit(
        BodyWeightError(
          errorMessage: e.toString(),
          bodyWeight: state.bodyWeight,
        ),
      );
    }
  }
}
