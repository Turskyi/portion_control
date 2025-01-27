import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/repositories/i_body_weight_repository.dart';
import 'package:portion_control/domain/repositories/i_user_details_repository.dart';
import 'package:portion_control/extensions/date_time_extension.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    this._userDetailsRepository,
    this._bodyWeightRepository,
  ) : super(const HomeLoading()) {
    on<LoadEntries>(_loadEntries);
    on<UpdateHeight>(_updateHeightState);
    on<SubmitHeight>(_submitHeight);
    on<EditHeight>(_setHeightToEditMode);
    on<UpdateBodyWeight>(_updateBodyWeightState);
    on<SubmitBodyWeight>(_submitBodyWeight);
    on<EditBodyWeight>(_setBodyWeightToEditMode);
  }

  final IUserDetailsRepository _userDetailsRepository;
  final IBodyWeightRepository _bodyWeightRepository;

  FutureOr<void> _loadEntries(
    LoadEntries event,
    Emitter<HomeState> emit,
  ) async {
    final String userHeight = '${_userDetailsRepository.getHeight() ?? ''}';
    String lastBodyWeight = state.bodyWeight;
    if (userHeight.isNotEmpty) {
      try {
        final List<BodyWeight> bodyWeightEntries =
            await _bodyWeightRepository.getAllBodyWeightEntries();
        if (bodyWeightEntries.isNotEmpty) {
          final BodyWeight lastSavedBodyWeightEntry = bodyWeightEntries.last;
          final DateTime lastSavedBodyWeightDate =
              lastSavedBodyWeightEntry.date;
          final DateTime today = DateTime.now();

          lastBodyWeight = lastSavedBodyWeightDate.isSameDate(today)
              ? '${lastSavedBodyWeightEntry.weight}'
              : '';
        }
        if (lastBodyWeight.isEmpty) {
          emit(
            HeightSubmittedState(
              height: userHeight,
              bodyWeight: lastBodyWeight,
              bodyWeightEntries: bodyWeightEntries,
            ),
          );
        } else {
          emit(
            BodyWeightSubmittedState(
              height: userHeight,
              bodyWeight: lastBodyWeight,
              bodyWeightEntries: bodyWeightEntries,
            ),
          );
        }
      } catch (e) {
        emit(
          BodyWeightError(
            errorMessage: '$e',
            height: userHeight,
            bodyWeight: lastBodyWeight,
            bodyWeightEntries: state.bodyWeightEntries,
            foodWeight: state.foodWeight,
          ),
        );
      }
    } else {
      emit(
        HomeLoaded(
          height: userHeight,
          bodyWeight: lastBodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
        ),
      );
    }
  }

  FutureOr<void> _updateHeightState(
    UpdateHeight event,
    Emitter<HomeState> emit,
  ) {
    emit(
      HeightUpdatedState(
        height: event.height,
        bodyWeight: state.bodyWeight,
        bodyWeightEntries: state.bodyWeightEntries,
      ),
    );
  }

  FutureOr<void> _updateBodyWeightState(
    UpdateBodyWeight event,
    Emitter<HomeState> emit,
  ) {
    emit(
      BodyWeightUpdatedState(
        bodyWeight: event.bodyWeight,
        height: state.height,
        bodyWeightEntries: state.bodyWeightEntries,
      ),
    );
  }

  FutureOr<void> _submitHeight(
    _,
    Emitter<HomeState> emit,
  ) async {
    if (state.height.isNotEmpty) {
      final double? height = double.tryParse(state.height);
      if (height != null) {
        try {
          // Insert into the data store.
          final bool isHeightSaved = await _userDetailsRepository.saveHeight(
            height,
          );
          if (isHeightSaved) {
            emit(
              HeightSubmittedState(
                bodyWeight: state.bodyWeight,
                height: state.height,
                bodyWeightEntries: state.bodyWeightEntries,
              ),
            );
          } else {
            emit(
              HeightError(
                errorMessage: 'Failed to submit height',
                bodyWeight: state.bodyWeight,
                height: state.height,
                bodyWeightEntries: state.bodyWeightEntries,
                foodWeight: state.foodWeight,
              ),
            );
          }
        } catch (e) {
          // Handle errors (e.g. data store issues).
          emit(
            HeightError(
              errorMessage: 'Failed to submit height: $e',
              bodyWeight: state.bodyWeight,
              height: state.height,
              bodyWeightEntries: state.bodyWeightEntries,
              foodWeight: state.foodWeight,
            ),
          );
        }
      } else {
        emit(
          HeightError(
            errorMessage: 'Invalid height',
            bodyWeight: state.bodyWeight,
            height: state.height,
            bodyWeightEntries: state.bodyWeightEntries,
            foodWeight: state.foodWeight,
          ),
        );
      }
    } else {
      emit(
        HeightError(
          errorMessage: 'Height cannot be empty',
          bodyWeight: state.bodyWeight,
          height: state.height,
          bodyWeightEntries: state.bodyWeightEntries,
          foodWeight: state.foodWeight,
        ),
      );
    }
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
          await _bodyWeightRepository
              .addOrUpdateBodyWeightEntry(
            weight: bodyWeight,
            date: DateTime.now(),
          )
              .whenComplete(() async {
            final List<BodyWeight> updatedBodyWeightEntries =
                await _bodyWeightRepository.getAllBodyWeightEntries();
            final BodyWeight lastSavedBodyWeightEntry =
                updatedBodyWeightEntries.last;
            emit(
              BodyWeightSubmittedState(
                bodyWeight: '${lastSavedBodyWeightEntry.weight}',
                height: state.height,
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
              height: state.height,
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
            height: state.height,
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
          height: state.height,
          bodyWeightEntries: state.bodyWeightEntries,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }

  FutureOr<void> _setHeightToEditMode(
    _,
    Emitter<HomeState> emit,
  ) {
    emit(
      HeightUpdatedState(
        bodyWeight: state.bodyWeight,
        height: state.height,
        bodyWeightEntries: state.bodyWeightEntries,
      ),
    );
  }

  FutureOr<void> _setBodyWeightToEditMode(
    _,
    Emitter<HomeState> emit,
  ) {
    emit(
      BodyWeightUpdatedState(
        bodyWeight: state.bodyWeight,
        height: state.height,
        bodyWeightEntries: state.bodyWeightEntries,
      ),
    );
  }
}
