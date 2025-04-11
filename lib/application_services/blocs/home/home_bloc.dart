import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portion_control/domain/enums/feedback_rating.dart';
import 'package:portion_control/domain/enums/feedback_type.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/domain/services/interactors/i_clear_tracking_data_use_case.dart';
import 'package:portion_control/domain/services/repositories/i_body_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_food_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_preferences_repository.dart';
import 'package:portion_control/extensions/date_time_extension.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:url_launcher/url_launcher.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    this._userPreferencesRepository,
    this._bodyWeightRepository,
    this._foodWeightRepository,
    this._clearTrackingDataUseCase,
  ) : super(const HomeLoading()) {
    on<LoadEntries>(_loadEntries);
    on<UpdateHeight>(_updateHeight);
    on<UpdateDateOfBirth>(_updateDateOfBirth);
    on<UpdateGender>(_updateGender);
    on<SubmitDetails>(_submitDetails);
    on<EditDetails>(_setDetailsToEditMode);
    on<UpdateBodyWeight>(_updateBodyWeightState);
    on<UpdateFoodWeight>(_updateFoodWeightState);
    on<SubmitBodyWeight>(_submitBodyWeight);
    on<AddFoodEntry>(_submitFoodWeight);
    on<EditBodyWeight>(_setBodyWeightToEditMode);
    on<EditFoodEntry>(_setFoodWeightToEditMode);
    on<DeleteFoodEntry>(_deleteFoodEntry);
    on<ClearUserData>(_clearUserData);
    on<ResetFoodEntries>(_clearAllFoodEntries);
    on<ConfirmMealsLogged>(_saveMealsConfirmation);
    on<HomeBugReportPressedEvent>(_onFeedbackRequested);
    on<HomeClosingFeedbackEvent>(_onFeedbackDialogDismissed);
    on<HomeSubmitFeedbackEvent>(_sendUserFeedback);
    on<ErrorEvent>(_handleError);
  }

  final IUserPreferencesRepository _userPreferencesRepository;
  final IBodyWeightRepository _bodyWeightRepository;
  final IFoodWeightRepository _foodWeightRepository;
  final IClearTrackingDataUseCase _clearTrackingDataUseCase;

  // Store the previous state.
  HomeState? _previousState;

  FutureOr<void> _loadEntries(
    LoadEntries event,
    Emitter<HomeState> emit,
  ) async {
    final UserDetails userDetails = _userPreferencesRepository.getUserDetails();
    double todayBodyWeight = 0;

    if (userDetails.isNotEmpty) {
      try {
        final List<BodyWeight> bodyWeightEntries =
            await _bodyWeightRepository.getAllBodyWeightEntries();
        double portionControl = constants.maxDailyFoodLimit;
        final double totalConsumedYesterday =
            await _foodWeightRepository.getTotalConsumedYesterday();
        if (bodyWeightEntries.isNotEmpty) {
          final BodyWeight lastSavedBodyWeightEntry = bodyWeightEntries.last;
          final DateTime lastSavedBodyWeightDate =
              lastSavedBodyWeightEntry.date;
          final DateTime today = DateTime.now();

          todayBodyWeight = lastSavedBodyWeightDate.isSameDate(today)
              ? lastSavedBodyWeightEntry.weight
              : 0;

          final bool isWeightIncreasingOrSame =
              state.isWeightIncreasingOrSameFor(
            bodyWeightEntries,
          );

          final bool isWeightAboveHealthy = state.isWeightAboveHealthyFor(
            lastSavedBodyWeightEntry.weight,
          );
          final bool isWeightDecreasingOrSame =
              state.isWeightDecreasingOrSameFor(
            bodyWeightEntries,
          );
          final bool isWeightBelowHealthy = state.isWeightBelowHealthyFor(
            lastSavedBodyWeightEntry.weight,
          );

          final double? savedPortionControl =
              _userPreferencesRepository.getPortionControl();
          if (isWeightIncreasingOrSame && isWeightAboveHealthy) {
            if (savedPortionControl == null) {
              portionControl = totalConsumedYesterday;
            } else if (savedPortionControl < totalConsumedYesterday) {
              portionControl = savedPortionControl;
            } else if (savedPortionControl > totalConsumedYesterday) {
              portionControl = totalConsumedYesterday;
            }
          } else if (isWeightDecreasingOrSame && isWeightBelowHealthy) {
            portionControl = constants.safeMinimumFoodIntakeG;
            if (savedPortionControl == null) {
              portionControl = totalConsumedYesterday;
            } else if (savedPortionControl > totalConsumedYesterday) {
              portionControl = savedPortionControl;
            } else if (savedPortionControl < totalConsumedYesterday) {
              portionControl = totalConsumedYesterday;
            }
          }
        }

        if (todayBodyWeight == 0) {
          emit(
            DetailsSubmittedState(
              userDetails: userDetails,
              bodyWeight: todayBodyWeight,
              bodyWeightEntries: bodyWeightEntries,
              foodEntries: state.foodEntries,
              yesterdayConsumedTotal: totalConsumedYesterday,
            ),
          );
        } else if (todayBodyWeight > constants.minBodyWeight) {
          final List<FoodWeight> todayFoodWeightEntries =
              await _foodWeightRepository.getTodayFoodEntries();
          final bool isMealsConfirmed =
              _userPreferencesRepository.isMealsConfirmedForToday;
          if (todayFoodWeightEntries.isNotEmpty) {
            emit(
              FoodWeightSubmittedState(
                userDetails: userDetails,
                bodyWeight: todayBodyWeight,
                bodyWeightEntries: bodyWeightEntries,
                foodEntries: todayFoodWeightEntries,
                yesterdayConsumedTotal: totalConsumedYesterday,
                isConfirmedAllMealsLogged: isMealsConfirmed,
                portionControl: portionControl,
              ),
            );
          } else {
            emit(
              BodyWeightSubmittedState(
                userDetails: userDetails,
                bodyWeight: todayBodyWeight,
                bodyWeightEntries: bodyWeightEntries,
                foodEntries: todayFoodWeightEntries,
                yesterdayConsumedTotal: totalConsumedYesterday,
                isConfirmedAllMealsLogged: isMealsConfirmed,
                portionControl: portionControl,
              ),
            );
          }
        } else {
          emit(
            LoadingError(
              errorMessage: 'Error: Entered body weight is below the '
                  'biologically possible limit. Please verify your input.',
              userDetails: state.userDetails,
              bodyWeight: todayBodyWeight,
              bodyWeightEntries: state.bodyWeightEntries,
              foodEntries: state.foodEntries,
              yesterdayConsumedTotal: state.yesterdayConsumedTotal,
              portionControl: state.portionControl,
            ),
          );
        }
      } catch (e) {
        emit(
          LoadingError(
            errorMessage: '$e',
            userDetails: state.userDetails,
            bodyWeight: todayBodyWeight,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            yesterdayConsumedTotal: state.yesterdayConsumedTotal,
            portionControl: state.portionControl,
          ),
        );
      }
    } else {
      emit(
        HomeLoaded(
          userDetails: state.userDetails,
          bodyWeight: todayBodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
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
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
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
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
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
        DetailsUpdateState(
          userDetails: state.userDetails.copyWith(height: height),
          bodyWeight: state.bodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
        ),
      );
    } else {
      emit(
        DetailsError(
          errorMessage: 'Invalid details',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
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
      DetailsUpdateState(
        userDetails: state.userDetails.copyWith(gender: gender),
        bodyWeight: state.bodyWeight,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
        yesterdayConsumedTotal: state.yesterdayConsumedTotal,
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
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
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
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
        ),
      );
    }
  }

  FutureOr<void> _updateFoodWeightState(
    UpdateFoodWeight event,
    Emitter<HomeState> emit,
  ) {
    final double? foodWeight = double.tryParse(event.foodWeight);
    final bool isMealsConfirmed =
        _userPreferencesRepository.isMealsConfirmedForToday;
    if (foodWeight != null) {
      final int foodEntryId = event.foodEntryId;
      _foodWeightRepository.updateFoodWeightEntry(
        foodEntryId: foodEntryId,
        foodEntryValue: foodWeight,
      );
      emit(
        FoodWeightUpdatedState(
          foodEntryId: event.foodEntryId,
          yesterdayConsumedTotal: foodWeight,
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          isConfirmedAllMealsLogged: isMealsConfirmed,
          portionControl: state.portionControl,
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
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          isConfirmedAllMealsLogged: isMealsConfirmed,
          portionControl: state.portionControl,
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

      if (height < constants.minUserHeight ||
          height > constants.maxUserHeight) {
        emit(
          DetailsError(
            errorMessage:
                'Height must be between ${constants.minUserHeight} cm and '
                '${constants.maxUserHeight} cm.',
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          ),
        );
        // Exit early if height validation fails.
        return;
      }

      try {
        // Insert into the data store.
        final bool isDetailsSaved =
            await _userPreferencesRepository.saveUserDetails(
          UserDetails(height: height, dateOfBirth: dateOfBirth, gender: gender),
        );

        if (isDetailsSaved) {
          if (state.bodyWeight > constants.minBodyWeight) {
            final bool isMealsConfirmed =
                _userPreferencesRepository.isMealsConfirmedForToday;
            emit(
              BodyWeightSubmittedState(
                bodyWeight: state.bodyWeight,
                userDetails: state.userDetails,
                bodyWeightEntries: state.bodyWeightEntries,
                foodEntries: state.foodEntries,
                yesterdayConsumedTotal: state.yesterdayConsumedTotal,
                isConfirmedAllMealsLogged: isMealsConfirmed,
                portionControl: state.portionControl,
              ),
            );
          } else {
            emit(
              DetailsSubmittedState(
                bodyWeight: state.bodyWeight,
                userDetails: state.userDetails,
                bodyWeightEntries: state.bodyWeightEntries,
                foodEntries: state.foodEntries,
              ),
            );
          }
        } else {
          emit(
            DetailsError(
              errorMessage: 'Failed to submit user details',
              bodyWeight: state.bodyWeight,
              userDetails: state.userDetails,
              bodyWeightEntries: state.bodyWeightEntries,
              foodEntries: state.foodEntries,
              yesterdayConsumedTotal: state.yesterdayConsumedTotal,
            ),
          );
        }
      } catch (e) {
        // Handle errors (e.g. data store issues).
        emit(
          DetailsError(
            errorMessage: 'Failed to submit details: $e',
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          ),
        );
      }
    } else {
      emit(
        DetailsError(
          errorMessage: 'Details cannot be empty',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
        ),
      );
    }
  }

  FutureOr<void> _submitBodyWeight(
    SubmitBodyWeight event,
    Emitter<HomeState> emit,
  ) async {
    if (event.bodyWeight > constants.minBodyWeight) {
      final double bodyWeight = state.bodyWeight;

      try {
        await _bodyWeightRepository.addOrUpdateBodyWeightEntry(
          weight: bodyWeight,
          date: DateTime.now(),
        );
        final List<BodyWeight> updatedBodyWeightEntries =
            await _bodyWeightRepository.getAllBodyWeightEntries();
        // We have just saved one body weight entry, so we know that
        // `updatedBodyWeightEntries` is not empty.
        final double lastSavedBodyWeight = updatedBodyWeightEntries.last.weight;

        final double totalConsumedYesterday = state.yesterdayConsumedTotal;

        final bool isWeightIncreasingOrSame = state.isWeightIncreasingOrSameFor(
          updatedBodyWeightEntries,
        );

        final bool isWeightDecreasingOrSame = state.isWeightDecreasingOrSameFor(
          updatedBodyWeightEntries,
        );

        final bool isWeightBelowHealthy = state.isWeightBelowHealthyFor(
          lastSavedBodyWeight,
        );

        final bool isWeightAboveHealthy = state.isWeightAboveHealthyFor(
          lastSavedBodyWeight,
        );
        final bool isMealsConfirmed =
            _userPreferencesRepository.isMealsConfirmedForToday;

        double portionControl = constants.maxDailyFoodLimit;
        final double? savedPortionControl =
            _userPreferencesRepository.getPortionControl();
        if (isWeightIncreasingOrSame && isWeightAboveHealthy) {
          if (savedPortionControl == null) {
            if (totalConsumedYesterday > constants.safeMinimumFoodIntakeG &&
                totalConsumedYesterday < constants.maxDailyFoodLimit) {
              portionControl = totalConsumedYesterday;
              await _userPreferencesRepository.savePortionControl(
                totalConsumedYesterday,
              );
            }
          } else if (savedPortionControl < totalConsumedYesterday &&
              savedPortionControl > constants.safeMinimumFoodIntakeG) {
            portionControl = savedPortionControl;
          } else if (savedPortionControl > totalConsumedYesterday &&
              totalConsumedYesterday > constants.safeMinimumFoodIntakeG &&
              totalConsumedYesterday < constants.maxDailyFoodLimit) {
            portionControl = totalConsumedYesterday;
            await _userPreferencesRepository.savePortionControl(
              totalConsumedYesterday,
            );
          }
        } else if (isWeightDecreasingOrSame && isWeightBelowHealthy) {
          portionControl = constants.safeMinimumFoodIntakeG;
          if (savedPortionControl == null) {
            if (totalConsumedYesterday > constants.safeMinimumFoodIntakeG &&
                totalConsumedYesterday < constants.maxDailyFoodLimit) {
              portionControl = totalConsumedYesterday;
              await _userPreferencesRepository.savePortionControl(
                totalConsumedYesterday,
              );
            }
          } else if (savedPortionControl > totalConsumedYesterday &&
              savedPortionControl > constants.safeMinimumFoodIntakeG) {
            portionControl = savedPortionControl;
          } else if (savedPortionControl < totalConsumedYesterday &&
              totalConsumedYesterday > constants.safeMinimumFoodIntakeG &&
              totalConsumedYesterday < constants.maxDailyFoodLimit) {
            portionControl = totalConsumedYesterday;
            await _userPreferencesRepository.savePortionControl(
              totalConsumedYesterday,
            );
          }
        }
        emit(
          BodyWeightSubmittedState(
            bodyWeight: lastSavedBodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: updatedBodyWeightEntries,
            foodEntries: state.foodEntries,
            yesterdayConsumedTotal: totalConsumedYesterday,
            isConfirmedAllMealsLogged: isMealsConfirmed,
            portionControl: portionControl,
          ),
        );
      } catch (error, stackTrace) {
        // Handle errors (e.g. database issues).
        debugPrint('Error while submitting body weight: $error');
        debugPrint('Stack trace: $stackTrace');
        emit(
          BodyWeightError(
            errorMessage: 'Failed to submit body weight: $error',
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          ),
        );
      }
    } else {
      emit(
        BodyWeightError(
          errorMessage:
              'Body weight should not be below the ${constants.minBodyWeight} '
              'kg',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
        ),
      );
    }
  }

  FutureOr<void> _submitFoodWeight(
    AddFoodEntry event,
    Emitter<HomeState> emit,
  ) async {
    final double? foodWeight = double.tryParse(event.foodWeight);
    final bool isMealsConfirmed =
        _userPreferencesRepository.isMealsConfirmedForToday;

    if (foodWeight != null) {
      try {
        // Insert into the database.
        await _foodWeightRepository.addFoodWeightEntry(
          weight: foodWeight,
          date: DateTime.now(),
        );

        final List<FoodWeight> updatedFoodWeightEntries =
            await _foodWeightRepository.getTodayFoodEntries();

        emit(
          FoodWeightSubmittedState(
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: updatedFoodWeightEntries,
            yesterdayConsumedTotal: state.yesterdayConsumedTotal,
            isConfirmedAllMealsLogged: isMealsConfirmed,
            portionControl: state.portionControl,
          ),
        );
      } catch (error, stackTrace) {
        debugPrint(
          'Error in _submitFoodWeight - Failed to insert food weight: $error',
        );
        debugPrint('Stack trace: $stackTrace');
        // Handle errors (e.g. database issues).
        emit(
          FoodWeightError(
            errorMessage: 'Failed to submit food weight: $error',
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            yesterdayConsumedTotal: state.yesterdayConsumedTotal,
            isConfirmedAllMealsLogged: isMealsConfirmed,
            portionControl: state.portionControl,
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
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          isConfirmedAllMealsLogged: isMealsConfirmed,
          portionControl: state.portionControl,
        ),
      );
    }
  }

  FutureOr<void> _deleteFoodEntry(
    DeleteFoodEntry event,
    Emitter<HomeState> emit,
  ) async {
    final bool isMealsConfirmed =
        _userPreferencesRepository.isMealsConfirmedForToday;
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
            yesterdayConsumedTotal: state.yesterdayConsumedTotal,
            isConfirmedAllMealsLogged: isMealsConfirmed,
            portionControl: state.portionControl,
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
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          isConfirmedAllMealsLogged: isMealsConfirmed,
          portionControl: state.portionControl,
        ),
      );
    }
  }

  FutureOr<void> _setDetailsToEditMode(
    _,
    Emitter<HomeState> emit,
  ) {
    emit(
      DetailsUpdateState(
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

  FutureOr<void> _setFoodWeightToEditMode(
    EditFoodEntry event,
    Emitter<HomeState> emit,
  ) {
    final bool isMealsConfirmed =
        _userPreferencesRepository.isMealsConfirmedForToday;
    emit(
      FoodWeightUpdateState(
        foodEntryId: event.foodEntryId,
        yesterdayConsumedTotal: state.yesterdayConsumedTotal,
        bodyWeight: state.bodyWeight,
        userDetails: state.userDetails,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
        isConfirmedAllMealsLogged: isMealsConfirmed,
        portionControl: state.portionControl,
      ),
    );
  }

  FutureOr<void> _clearUserData(
    _,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _clearTrackingDataUseCase.execute();
      emit(
        DetailsUpdateState(
          bodyWeight: 0,
          userDetails: state.userDetails,
          bodyWeightEntries: const <BodyWeight>[],
          foodEntries: const <FoodWeight>[],
        ),
      );
    } catch (error) {
      emit(
        DetailsError(
          errorMessage: 'Error clearing user data: $error.',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
        ),
      );
    }
  }

  FutureOr<void> _clearAllFoodEntries(
    _,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _foodWeightRepository.clearAllTrackingData();
      emit(
        BodyWeightSubmittedState(
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: const <FoodWeight>[],
          yesterdayConsumedTotal: 0,
          isConfirmedAllMealsLogged: false,
          portionControl: state.portionControl,
        ),
      );
    } catch (error) {
      emit(
        BodyWeightError(
          errorMessage: 'Error clearing food entries: $error.',
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
        ),
      );
    }
  }

  FutureOr<void> _saveMealsConfirmation(
    _,
    Emitter<HomeState> emit,
  ) async {
    bool isSaved = await _userPreferencesRepository.saveMealsConfirmed();
    if (isSaved) {
      emit(
        BodyWeightSubmittedState(
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          isConfirmedAllMealsLogged: isSaved,
          portionControl: state.portionControl,
        ),
      );
    } else {
      // We should never get here.
      emit(
        BodyWeightSubmittedState(
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          isConfirmedAllMealsLogged: false,
          portionControl: state.portionControl,
        ),
      );
    }
  }

  FutureOr<void> _onFeedbackRequested(_, Emitter<HomeState> emit) {
    _previousState = state;
    emit(
      HomeFeedbackState(
        userDetails: state.userDetails,
        bodyWeight: state.bodyWeight,
        yesterdayConsumedTotal: state.yesterdayConsumedTotal,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
        portionControl: state.portionControl,
      ),
    );
  }

  FutureOr<void> _onFeedbackDialogDismissed(_, Emitter<HomeState> emit) {
    if (_previousState != null) {
      emit(_previousState!);
    } else {
      add(const LoadEntries());
    }
  }

  FutureOr<void> _handleError(ErrorEvent event, Emitter<HomeState> emit) {
    debugPrint('ErrorEvent: ${event.error}');
    if (_previousState != null) {
      emit(_previousState!);
    } else {
      add(const LoadEntries());
    }
  }

  FutureOr<void> _sendUserFeedback(
    HomeSubmitFeedbackEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final UserFeedback feedback = event.feedback;
    try {
      final String screenshotFilePath = await _writeImageToStorage(
        feedback.screenshot,
      );

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final Map<String, dynamic>? extra = feedback.extra;
      final dynamic rating = extra?['rating'];
      final dynamic type = extra?['feedback_type'];

      // Construct the feedback text with details from `extra'.
      final StringBuffer feedbackBody = StringBuffer()
        ..writeln('${type is FeedbackType ? translate('feedback.type') : ''}:'
            ' ${type is FeedbackType ? type.value : ''}')
        ..writeln()
        ..writeln(feedback.text)
        ..writeln()
        ..writeln('${translate('appId')}: ${packageInfo.packageName}')
        ..writeln('${translate('appVersion')}: ${packageInfo.version}')
        ..writeln('${translate('buildNumber')}: ${packageInfo.buildNumber}')
        ..writeln()
        ..writeln(
            '${rating is FeedbackRating ? translate('feedback.rating') : ''}'
            '${rating is FeedbackRating ? ':' : ''}'
            ' ${rating is FeedbackRating ? rating.value : ''}');

      final List<String> attachmentPaths = screenshotFilePath.isNotEmpty
          ? <String>[screenshotFilePath]
          : <String>[];

      final Email email = Email(
        body: feedbackBody.toString(),
        subject: '${translate('feedback.appFeedback')}: '
            '${packageInfo.appName}',
        recipients: <String>[constants.supportEmail],
        attachmentPaths: attachmentPaths,
      );

      try {
        if (kIsWeb) {
          // Handle email sending on the web using a `mailto` link.
          final Uri emailLaunchUri = Uri(
            scheme: 'mailto',
            path: constants.supportEmail,
            queryParameters: <String, String>{
              'subject': '${translate('feedback.appFeedback')}: '
                  '${packageInfo.appName}',
              'body': feedbackBody.toString(),
            },
          );

          if (await canLaunchUrl(emailLaunchUri)) {
            await launchUrl(emailLaunchUri);
          } else {
            add(ErrorEvent(translate('error.unexpectedError')));
          }
        } else {
          await FlutterEmailSender.send(email);
        }
      } catch (error, stackTrace) {
        debugPrint(
          'Error in $runtimeType in `onError`: $error.\n'
          'Stacktrace: $stackTrace',
        );
        add(ErrorEvent(translate('error.unexpectedError')));
      }
    } catch (error, stackTrace) {
      debugPrint(
        'Error in $runtimeType in `onError`: $error.\n'
        'Stacktrace: $stackTrace',
      );
      add(ErrorEvent(translate('error.unexpectedError')));
    }
    if (_previousState != null) {
      emit(_previousState!);
    } else {
      add(const LoadEntries());
    }
  }

  Future<String> _writeImageToStorage(Uint8List feedbackScreenshot) async {
    if (kIsWeb) {
      // No file storage on web.
      return '';
    } else {
      final Directory output = await getTemporaryDirectory();
      final String screenshotFilePath = '${output.path}/feedback.png';
      final File screenshotFile = File(screenshotFilePath);
      await screenshotFile.writeAsBytes(feedbackScreenshot);
      return screenshotFilePath;
    }
  }
}
