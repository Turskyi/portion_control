import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/domain/repositories/i_body_weight_repository.dart';
import 'package:portion_control/domain/repositories/i_food_weight_repository.dart';
import 'package:portion_control/domain/repositories/i_user_details_repository.dart';
import 'package:portion_control/extensions/date_time_extension.dart';
import 'package:portion_control/res/constants/constants.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    this._userDetailsRepository,
    this._bodyWeightRepository,
    this._foodWeightRepository,
  ) : super(const HomeLoading()) {
    on<LoadEntries>(_loadEntries);
    on<UpdateHeight>(_updateHeight);
    on<UpdateDateOfBirth>(_updateDateOfBirth);
    on<UpdateGender>(_updateGender);
    on<SubmitDetails>(_submitDetails);
    on<EditDetails>(_setHeightToEditMode);
    on<UpdateBodyWeight>(_updateBodyWeightState);
    on<UpdateFoodWeight>(_updateFoodWeightState);
    on<SubmitBodyWeight>(_submitBodyWeight);
    on<AddFoodEntry>(_submitFoodWeight);
    on<EditBodyWeight>(_setBodyWeightToEditMode);
    on<EditFoodEntry>(_setFoodWeightToEditMode);
    on<DeleteFoodEntry>(_deleteFoodEntry);
  }

  final IUserDetailsRepository _userDetailsRepository;
  final IBodyWeightRepository _bodyWeightRepository;
  final IFoodWeightRepository _foodWeightRepository;

  FutureOr<void> _loadEntries(
    LoadEntries event,
    Emitter<HomeState> emit,
  ) async {
    final UserDetails userDetails = _userDetailsRepository.getUserDetails();
    double lastBodyWeight = 0;

    if (userDetails.isNotEmpty) {
      try {
        final List<BodyWeight> bodyWeightEntries =
            await _bodyWeightRepository.getAllBodyWeightEntries();

        if (bodyWeightEntries.isNotEmpty) {
          final BodyWeight lastSavedBodyWeightEntry = bodyWeightEntries.last;
          final DateTime lastSavedBodyWeightDate =
              lastSavedBodyWeightEntry.date;
          final DateTime today = DateTime.now();

          lastBodyWeight = lastSavedBodyWeightDate.isSameDate(today)
              ? lastSavedBodyWeightEntry.weight
              : 0;
        }
        if (lastBodyWeight == 0) {
          emit(
            DetailsSubmittedState(
              userDetails: userDetails,
              bodyWeight: lastBodyWeight,
              bodyWeightEntries: bodyWeightEntries,
              foodEntries: state.foodEntries,
              foodWeight: state.foodWeight,
            ),
          );
        } else if (lastBodyWeight > 0) {
          final List<FoodWeight> foodWeightEntries =
              await _foodWeightRepository.getTodayFoodEntries();
          if (foodWeightEntries.isNotEmpty) {
            emit(
              FoodWeightSubmittedState(
                userDetails: userDetails,
                bodyWeight: lastBodyWeight,
                bodyWeightEntries: bodyWeightEntries,
                foodEntries: foodWeightEntries,
                foodWeight: state.foodWeight,
              ),
            );
          } else {
            emit(
              BodyWeightSubmittedState(
                userDetails: userDetails,
                bodyWeight: lastBodyWeight,
                bodyWeightEntries: bodyWeightEntries,
                foodEntries: foodWeightEntries,
                foodWeight: state.foodWeight,
              ),
            );
          }
        }
      } catch (e) {
        emit(
          LoadingError(
            errorMessage: '$e',
            userDetails: state.userDetails,
            bodyWeight: lastBodyWeight,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            foodWeight: state.foodWeight,
            portionControl: state.portionControl,
          ),
        );
      }
    } else {
      emit(
        HomeLoaded(
          userDetails: state.userDetails,
          bodyWeight: lastBodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          foodWeight: state.foodWeight,
          portionControl: state.portionControl,
        ),
      );
    }
  }

  FutureOr<void> _updateDateOfBirth(
    UpdateDateOfBirth event,
    Emitter<HomeState> emit,
  ) {
    final DateTime dateOfBirth = event.dateOfBirth;
    //Let's not allow minors to mess with their health.
    if (dateOfBirth.isOlderThanMinimumAge) {
      emit(
        DateOfBirthUpdatedState(
          userDetails: state.userDetails.copyWith(dateOfBirth: dateOfBirth),
          bodyWeight: state.bodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          foodWeight: state.foodWeight,
        ),
      );
    } else {
      emit(
        DateOfBirthError(
          errorMessage: 'Invalid date of birth',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }

  FutureOr<void> _updateHeight(
    UpdateHeight event,
    Emitter<HomeState> emit,
  ) {
    final double? height = double.tryParse(event.height);
    if (height != null) {
      emit(
        HeightUpdatedState(
          userDetails: state.userDetails.copyWith(height: height),
          bodyWeight: state.bodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          foodWeight: state.foodWeight,
        ),
      );
    } else {
      emit(
        HeightError(
          errorMessage: 'Invalid height',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }

  FutureOr<void> _updateGender(
    UpdateGender event,
    Emitter<HomeState> emit,
  ) {
    final Gender gender = event.gender;
    emit(
      HeightUpdatedState(
        userDetails: state.userDetails.copyWith(gender: gender),
        bodyWeight: state.bodyWeight,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
        foodWeight: state.foodWeight,
      ),
    );
  }

  FutureOr<void> _updateBodyWeightState(
    UpdateBodyWeight event,
    Emitter<HomeState> emit,
  ) {
    final double? bodyWeight = double.tryParse(event.bodyWeight);
    if (bodyWeight != null) {
      emit(
        BodyWeightUpdatedState(
          bodyWeight: bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          foodWeight: state.foodWeight,
        ),
      );
    } else {
      emit(
        BodyWeightError(
          errorMessage: 'Invalid body weight',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }

  FutureOr<void> _updateFoodWeightState(
    UpdateFoodWeight event,
    Emitter<HomeState> emit,
  ) {
    final double? foodWeight = double.tryParse(event.foodWeight);
    if (foodWeight != null) {
      final int foodEntryId = event.foodEntryId;
      _foodWeightRepository.updateFoodWeightEntry(
        foodEntryId: foodEntryId,
        foodEntryValue: foodWeight,
      );
      emit(
        FoodWeightUpdatedState(
          foodEntryId: event.foodEntryId,
          foodWeight: foodWeight,
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
        ),
      );
    } else {
      emit(
        FoodWeightError(
          errorMessage: 'Invalid food weight',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }

  FutureOr<void> _submitDetails(
    _,
    Emitter<HomeState> emit,
  ) async {
    if (state.isNotEmptyDetails) {
      final double height = state.height;
      final DateTime? dateOfBirth = state.dateOfBirth;
      final Gender gender = state.gender;

      if (height < minHeight || height > maxHeight) {
        emit(
          HeightError(
            errorMessage:
                'Height must be between $minHeight cm and $maxHeight cm.',
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            foodWeight: state.foodWeight,
          ),
        );
        // Exit early if height validation fails.
        return;
      }

      try {
        // Insert into the data store.
        final bool isDetailsSaved =
            await _userDetailsRepository.saveUserDetails(
          UserDetails(height: height, dateOfBirth: dateOfBirth, gender: gender),
        );

        if (isDetailsSaved) {
          emit(
            DetailsSubmittedState(
              bodyWeight: state.bodyWeight,
              userDetails: state.userDetails,
              bodyWeightEntries: state.bodyWeightEntries,
              foodEntries: state.foodEntries,
            ),
          );
        } else {
          emit(
            HeightError(
              errorMessage: 'Failed to submit user details',
              bodyWeight: state.bodyWeight,
              userDetails: state.userDetails,
              bodyWeightEntries: state.bodyWeightEntries,
              foodEntries: state.foodEntries,
              foodWeight: state.foodWeight,
            ),
          );
        }
      } catch (e) {
        // Handle errors (e.g. data store issues).
        emit(
          HeightError(
            errorMessage: 'Failed to submit details: $e',
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            foodWeight: state.foodWeight,
          ),
        );
      }
    } else {
      emit(
        HeightError(
          errorMessage: 'Details cannot be empty',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }

  FutureOr<void> _submitBodyWeight(
    _,
    Emitter<HomeState> emit,
  ) async {
    if (state.bodyWeight > 0) {
      final double bodyWeight = state.bodyWeight;

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
              bodyWeight: lastSavedBodyWeightEntry.weight,
              userDetails: state.userDetails,
              bodyWeightEntries: updatedBodyWeightEntries,
              foodEntries: state.foodEntries,
            ),
          );
        });
      } catch (e) {
        // Handle errors (e.g. database issues).
        emit(
          BodyWeightError(
            errorMessage: 'Failed to submit body weight: ${e.toString()}',
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            foodWeight: state.foodWeight,
          ),
        );
      }
    } else {
      emit(
        BodyWeightError(
          errorMessage: 'Body weight cannot be empty',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }

  FutureOr<void> _submitFoodWeight(AddFoodEntry event,
    Emitter<HomeState> emit,
  ) async {
    final double? foodWeight = double.tryParse(event.foodWeight);
    if (foodWeight != null) {
      try {
        // Insert into the database.
        await _foodWeightRepository
            .addFoodWeightEntry(
          weight: foodWeight,
          date: DateTime.now(),
        )
            .whenComplete(() async {
          final List<FoodWeight> updatedFoodWeightEntries =
              await _foodWeightRepository.getTodayFoodEntries();

          emit(
            FoodWeightSubmittedState(
              bodyWeight: state.bodyWeight,
              userDetails: state.userDetails,
              bodyWeightEntries: state.bodyWeightEntries,
              foodEntries: updatedFoodWeightEntries,
              foodWeight: foodWeight,
            ),
          );
        });
      } catch (e) {
        // Handle errors (e.g. database issues).
        emit(
          FoodWeightError(
            errorMessage: 'Failed to submit food weight: $e',
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            foodWeight: state.foodWeight,
          ),
        );
      }
    } else {
      emit(
        FoodWeightError(
          errorMessage: 'Food weight is invalid',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          foodWeight: state.foodWeight,
        ),
      );
    }
  }

  FutureOr<void> _deleteFoodEntry(
    DeleteFoodEntry event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _foodWeightRepository
          .deleteFoodWeightEntry(event.foodEntryId)
          .whenComplete(() async {
        final List<FoodWeight> updatedFoodWeightEntries =
            await _foodWeightRepository.getTodayFoodEntries();

        emit(
          FoodWeightSubmittedState(
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: updatedFoodWeightEntries,
            foodWeight: state.foodWeight,
          ),
        );
      });
    } catch (e) {
      // Handle errors (e.g. database issues).
      emit(
        FoodWeightError(
          errorMessage: 'Failed to delete food entry: $e',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
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
        userDetails: state.userDetails,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
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
        userDetails: state.userDetails,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
      ),
    );
  }

  FutureOr<void> _setFoodWeightToEditMode(EditFoodEntry event,
    Emitter<HomeState> emit,
  ) {
    emit(
      FoodWeightUpdateState(
        foodEntryId: event.foodEntryId,
        foodWeight: state.foodWeight,
        bodyWeight: state.bodyWeight,
        userDetails: state.userDetails,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
      ),
    );
  }
}
