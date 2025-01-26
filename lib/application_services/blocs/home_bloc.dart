import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/repositories/i_body_weight_repository.dart';
import 'package:portion_control/extensions/date_time_extension.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const BodyWeightLoading()) {
    on<LoadBodyWeightEntries>(_loadBodyWeightEntries);
    on<UpdateBodyWeight>(_updateBodyWeightState);
    on<SubmitBodyWeight>(_submitBodyWeight);
    on<EditBodyWeight>(_setBodyWeightToEditMode);
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
            bodyWeightEntries: bodyWeightEntries,
          ),
        );
      }
    } catch (e) {
      emit(
        BodyWeightError(
          errorMessage: e.toString(),
          bodyWeight: state.bodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }

  FutureOr<void> _updateBodyWeightState(
    UpdateBodyWeight event,
    Emitter<HomeState> emit,
  ) {
    emit(
      BodyWeightUpdatedState(
        bodyWeight: event.bodyWeight,
        bodyWeightEntries: state.bodyWeightEntries,
      ),
    );
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
          await _repository
              .addOrUpdateBodyWeightEntry(
            weight: bodyWeight,
            date: DateTime.now(),
          )
              .whenComplete(() async {
            final List<BodyWeight> updatedBodyWeightEntries =
                await _repository.getAllBodyWeightEntries();
            final BodyWeight lastSavedBodyWeightEntry =
                updatedBodyWeightEntries.last;
            emit(
              BodyWeightSubmittedState(
                bodyWeight: '${lastSavedBodyWeightEntry.weight}',
                bodyWeightEntries: updatedBodyWeightEntries,
              ),
            );
          });
        } catch (e) {
          // Handle errors (e.g. database issues).
          emit(
            BodyWeightError(
              errorMessage: 'Failed to submit body weight: ${e.toString()}',
              bodyWeight: state.bodyWeight,
              bodyWeightEntries: state.bodyWeightEntries,
              foodWeight: state.foodWeight,
            ),
          );
        }
      } else {
        emit(
          BodyWeightError(
            errorMessage: 'Invalid body weight',
            bodyWeight: state.bodyWeight,
            bodyWeightEntries: state.bodyWeightEntries,
            foodWeight: state.foodWeight,
          ),
        );
      }
    } else {
      emit(
        BodyWeightError(
          errorMessage: 'Body weight cannot be empty',
          bodyWeight: state.bodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }

  FutureOr<void> _setBodyWeightToEditMode(
    _,
    Emitter<HomeState> emit,
  ) {
    emit(
      BodyWeightUpdatedState(
        bodyWeight: state.bodyWeight,
        bodyWeightEntries: state.bodyWeightEntries,
      ),
    );
  }
}
