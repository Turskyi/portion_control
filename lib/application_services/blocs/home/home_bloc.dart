import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portion_control/domain/enums/feedback_rating.dart';
import 'package:portion_control/domain/enums/feedback_type.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/models/portion_control_summary.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/domain/services/interactors/i_clear_tracking_data_use_case.dart';
import 'package:portion_control/domain/services/repositories/i_body_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_food_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_preferences_repository.dart';
import 'package:portion_control/extensions/date_time_extension.dart';
import 'package:portion_control/extensions/list_extension.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/res/enums/home_widget_keys.dart';
import 'package:portion_control/services/home_widget_service.dart';
import 'package:portion_control/ui/home/widgets/body_weight_line_chart.dart';
import 'package:resend/resend.dart';
import 'package:url_launcher/url_launcher.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    this._userPreferencesRepository,
    this._bodyWeightRepository,
    this._foodWeightRepository,
    this._clearTrackingDataUseCase,
    this._homeWidgetService,
  ) : super(HomeLoading(language: _userPreferencesRepository.getLanguage())) {
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
    on<ClearTrackingData>(_clearTrackingData);
    on<ResetFoodEntries>(_clearFoodEntries);
    on<ConfirmMealsLogged>(_saveMealsConfirmation);
    on<HomeBugReportPressedEvent>(_onFeedbackRequested);
    on<HomeClosingFeedbackEvent>(_onFeedbackDialogDismissed);
    on<HomeSubmitFeedbackEvent>(_sendUserFeedback);
    on<CheckForUpdate>(_checkForUpdate);
    on<ErrorEvent>(_handleError);
    on<UpdateDeviceHomeWidgetEvent>(_updateDeviceHomeWidget);
    on<CheckDateChangeOnResume>(_checkDateChangeOnResume);
  }

  final IUserPreferencesRepository _userPreferencesRepository;
  final IBodyWeightRepository _bodyWeightRepository;
  final IFoodWeightRepository _foodWeightRepository;
  final IClearTrackingDataUseCase _clearTrackingDataUseCase;
  final HomeWidgetService _homeWidgetService;

  // Store the previous state.
  HomeState? _previousState;

  FutureOr<void> _loadEntries(
    LoadEntries event,
    Emitter<HomeState> emit,
  ) async {
    final UserDetails userDetails = _userPreferencesRepository.getUserDetails();
    final Language language = _userPreferencesRepository.getLanguage();
    final DateTime now = DateTime.now();

    if (userDetails.isNotEmpty) {
      emit(
        LoadingTodayBodyWeightState(
          userDetails: userDetails,
          bodyWeight: state.bodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.totalConsumedYesterday,
          language: language,
          dataDate: now,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
      final BodyWeight todayBodyWeightEntry = await _bodyWeightRepository
          .getTodayBodyWeight();
      double todayBodyWeight = todayBodyWeightEntry.weight;
      emit(
        LoadingConsumedYesterdayState(
          userDetails: userDetails,
          bodyWeight: todayBodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.totalConsumedYesterday,
          language: language,
          dataDate: now,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
      final double totalConsumedYesterday = await _foodWeightRepository
          .getTotalConsumedYesterday();

      emit(
        LoadingBodyWeightEntriesState(
          userDetails: userDetails,
          bodyWeight: todayBodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: totalConsumedYesterday,
          language: language,
          dataDate: now,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
      try {
        final List<BodyWeight> bodyWeightEntries = await _bodyWeightRepository
            .getAllBodyWeightEntries();

        double portionControl = constants.kMaxDailyFoodLimit;

        final double minConsumptionIfWeightIncreased =
            await _userPreferencesRepository
                .getMinConsumptionWhenWeightIncreased();

        final bool hasWeightIncreaseProof =
            minConsumptionIfWeightIncreased < constants.kMaxDailyFoodLimit;

        if (bodyWeightEntries.isNotEmpty) {
          final BodyWeight lastSavedBodyWeightEntry = bodyWeightEntries.last;
          final DateTime lastSavedBodyWeightDate =
              lastSavedBodyWeightEntry.date;

          todayBodyWeight = lastSavedBodyWeightDate.isSameDate(now)
              ? lastSavedBodyWeightEntry.weight
              : 0;

          final bool isWeightAboveHealthy = state.isWeightAboveHealthyFor(
            lastSavedBodyWeightEntry.weight,
          );
          final bool isWeightBelowHealthy = state.isWeightBelowHealthyFor(
            lastSavedBodyWeightEntry.weight,
          );

          if (isWeightAboveHealthy) {
            portionControl = minConsumptionIfWeightIncreased;
          } else if (isWeightBelowHealthy) {
            portionControl = await _userPreferencesRepository
                .getMaxConsumptionWhenWeightDecreased();
          }

          // If historical proofs are not yet available, fallback to last saved
          // portion.
          final bool isNoProofFound =
              portionControl == constants.kMaxDailyFoodLimit ||
              (isWeightBelowHealthy &&
                  portionControl == constants.kSafeMinimumFoodIntakeG);

          if (isNoProofFound) {
            final double? savedPortionControl = _userPreferencesRepository
                .getLastPortionControl();
            if (savedPortionControl != null) {
              portionControl = savedPortionControl;
            }
          }
        }

        // Always fetch today's food entries so we don't accidentally keep
        // showing yesterday's entries when transitioning to a new day.
        final List<FoodWeight> todayFoodWeightEntries =
            await _foodWeightRepository.getTodayFoodEntries();

        if (todayBodyWeight == 0) {
          emit(
            DetailsSubmittedState(
              userDetails: userDetails,
              bodyWeight: todayBodyWeight,
              bodyWeightEntries: bodyWeightEntries,
              foodEntries: todayFoodWeightEntries,
              yesterdayConsumedTotal: totalConsumedYesterday,
              language: language,
              dataDate: now,
              hasWeightIncreaseProof: hasWeightIncreaseProof,
            ),
          );
        } else if (todayBodyWeight > constants.minBodyWeight) {
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
                language: language,
                dataDate: now,
                hasWeightIncreaseProof: hasWeightIncreaseProof,
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
                language: language,
                dataDate: now,
                hasWeightIncreaseProof: hasWeightIncreaseProof,
              ),
            );
          }
        } else {
          emit(
            LoadingError(
              errorMessage:
                  'Error: Entered body weight is below the '
                  'biologically possible limit. Please verify your input.',
              userDetails: userDetails,
              bodyWeight: todayBodyWeight,
              bodyWeightEntries: state.bodyWeightEntries,
              foodEntries: state.foodEntries,
              yesterdayConsumedTotal: totalConsumedYesterday,
              portionControl: state.portionControl,
              language: language,
              dataDate: now,
              hasWeightIncreaseProof: hasWeightIncreaseProof,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error in _loadEntries: $e');
        emit(
          LoadingError(
            errorMessage: '$e',
            userDetails: userDetails,
            bodyWeight: todayBodyWeight,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            yesterdayConsumedTotal: totalConsumedYesterday,
            portionControl: state.portionControl,
            language: language,
            dataDate: now,
            hasWeightIncreaseProof: state.hasWeightIncreaseProof,
          ),
        );
      }
    } else {
      emit(
        HomeLoaded(
          userDetails: userDetails,
          bodyWeight: state.bodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.totalConsumedYesterday,
          portionControl: state.portionControl,
          language: language,
          dataDate: now,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }
    _triggerHomeWidgetUpdate();
  }

  FutureOr<void> _updateDateOfBirth(
    UpdateDateOfBirth event,
    Emitter<HomeState> emit,
  ) {
    final Language language = _userPreferencesRepository.getLanguage();
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
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
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
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }
  }

  Future<void> _updateHeight(
    UpdateHeight event,
    Emitter<HomeState> emit,
  ) async {
    final double? height = double.tryParse(event.height);
    final Language language = _userPreferencesRepository.getLanguage();
    if (height != null) {
      emit(
        DetailsUpdateState(
          userDetails: state.userDetails.copyWith(heightInCm: height),
          bodyWeight: state.bodyWeight,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    } else {
      emit(
        DetailsError(
          errorMessage: translate('error.invalid_height'),
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }
  }

  FutureOr<void> _updateGender(UpdateGender event, Emitter<HomeState> emit) {
    final Gender gender = event.gender;
    final Language language = _userPreferencesRepository.getLanguage();
    emit(
      DetailsUpdateState(
        userDetails: state.userDetails.copyWith(gender: gender),
        bodyWeight: state.bodyWeight,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
        yesterdayConsumedTotal: state.yesterdayConsumedTotal,
        language: language,
        dataDate: state.dataDate,
        hasWeightIncreaseProof: state.hasWeightIncreaseProof,
      ),
    );
  }

  Future<void> _updateBodyWeightState(
    UpdateBodyWeight event,
    Emitter<HomeState> emit,
  ) async {
    final double? bodyWeight = double.tryParse(event.bodyWeight);
    final Language language = _userPreferencesRepository.getLanguage();
    if (bodyWeight != null) {
      emit(
        BodyWeightUpdatedState(
          bodyWeight: bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    } else {
      emit(
        BodyWeightError(
          errorMessage: translate('error.invalid_body_weight'),
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }
  }

  Future<void> _updateFoodWeightState(
    UpdateFoodWeight event,
    Emitter<HomeState> emit,
  ) async {
    final Language language = _userPreferencesRepository.getLanguage();
    final double? foodWeight = double.tryParse(event.foodWeight);
    final bool isMealsConfirmed =
        _userPreferencesRepository.isMealsConfirmedForToday;
    if (foodWeight != null) {
      final int foodEntryId = event.foodEntryId;

      await _foodWeightRepository.updateFoodWeightEntry(
        foodEntryId: foodEntryId,
        foodEntryValue: foodWeight,
      );

      final List<FoodWeight> updatedFoodWeightEntries =
          await _foodWeightRepository.getTodayFoodEntries();

      emit(
        FoodWeightUpdatedState(
          foodEntryId: event.foodEntryId,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: updatedFoodWeightEntries,
          isConfirmedAllMealsLogged: isMealsConfirmed,
          portionControl: state.portionControl,
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    } else {
      emit(
        FoodWeightError(
          errorMessage: translate('error.invalid_food_weight'),
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          isConfirmedAllMealsLogged: isMealsConfirmed,
          portionControl: state.portionControl,
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }
    _triggerHomeWidgetUpdate();
  }

  FutureOr<void> _submitDetails(
    SubmitDetails _,
    Emitter<HomeState> emit,
  ) async {
    final Language language = _userPreferencesRepository.getLanguage();
    if (state.isNotEmptyDetails) {
      final double height = state.heightInCm;
      final DateTime? dateOfBirth = state.dateOfBirth;
      final Gender gender = state.gender;

      if (height < constants.minUserHeight ||
          height > constants.maxUserHeight) {
        emit(
          DetailsError(
            errorMessage: translate(
              'error.height_range',
              args: <String, Object?>{
                'minHeight': constants.minUserHeight,
                'maxHeight': constants.maxUserHeight,
              },
            ),
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            yesterdayConsumedTotal: state.yesterdayConsumedTotal,
            language: language,
            dataDate: state.dataDate,
            hasWeightIncreaseProof: state.hasWeightIncreaseProof,
          ),
        );
        // Exit early if height validation fails.
        return;
      }

      try {
        // Insert into the data store.
        final bool isDetailsSaved = await _userPreferencesRepository
            .saveUserDetails(
              UserDetails(
                heightInCm: height,
                dateOfBirth: dateOfBirth,
                gender: gender,
              ),
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
                language: language,
                dataDate: state.dataDate,
                hasWeightIncreaseProof: state.hasWeightIncreaseProof,
              ),
            );
          } else {
            emit(
              DetailsSubmittedState(
                bodyWeight: state.bodyWeight,
                userDetails: state.userDetails,
                bodyWeightEntries: state.bodyWeightEntries,
                foodEntries: state.foodEntries,
                language: language,
                dataDate: state.dataDate,
                hasWeightIncreaseProof: state.hasWeightIncreaseProof,
              ),
            );
          }
        } else {
          emit(
            DetailsError(
              errorMessage: translate('error.failed_to_submit_user_details'),
              bodyWeight: state.bodyWeight,
              userDetails: state.userDetails,
              bodyWeightEntries: state.bodyWeightEntries,
              foodEntries: state.foodEntries,
              yesterdayConsumedTotal: state.yesterdayConsumedTotal,
              language: language,
              dataDate: state.dataDate,
              hasWeightIncreaseProof: state.hasWeightIncreaseProof,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error in _submitDetails: $e');
        // Handle errors (e.g. data store issues).
        emit(
          DetailsError(
            errorMessage: translate(
              'error.failed_to_submit_details',
              args: <String, Object?>{'errorDetails': '$e'},
            ),
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            yesterdayConsumedTotal: state.yesterdayConsumedTotal,
            language: language,
            dataDate: state.dataDate,
            hasWeightIncreaseProof: state.hasWeightIncreaseProof,
          ),
        );
      }

      // Only add the event if it's NOT web AND NOT macOS.
      // For context, see issue:
      // https://github.com/ABausG/home_widget/issues/137.
      await _triggerHomeWidgetUpdate();
    } else {
      emit(
        DetailsError(
          errorMessage: translate('error.details_cannot_be_empty'),
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }
  }

  FutureOr<void> _submitBodyWeight(
    SubmitBodyWeight event,
    Emitter<HomeState> emit,
  ) async {
    final Language language = _userPreferencesRepository.getLanguage();
    if (event.bodyWeight > constants.minBodyWeight) {
      final double bodyWeight = state.bodyWeight;

      try {
        // Normalize the date to the start of the day (00:00:00.000)
        // so that multiple entries today update the same record.
        final DateTime now = DateTime.now();
        final DateTime todayAtMidnight = DateTime(now.year, now.month, now.day);

        await _bodyWeightRepository.addOrUpdateBodyWeightEntry(
          weight: bodyWeight,
          date: todayAtMidnight,
        );
        final List<BodyWeight> updatedBodyWeightEntries =
            await _bodyWeightRepository.getAllBodyWeightEntries();
        // We have just saved one body weight entry, so we know that
        // `updatedBodyWeightEntries` is not empty.
        final double lastSavedBodyWeight =
            updatedBodyWeightEntries.lastOrNull?.weight ?? 0.0;

        final double totalConsumedYesterday = state.yesterdayConsumedTotal;

        final bool isWeightBelowHealthy = state.isWeightBelowHealthyFor(
          lastSavedBodyWeight,
        );

        final bool isWeightAboveHealthy = state.isWeightAboveHealthyFor(
          lastSavedBodyWeight,
        );
        final bool isMealsConfirmed =
            _userPreferencesRepository.isMealsConfirmedForToday;

        double portionControl = constants.kMaxDailyFoodLimit;

        final double minConsumptionIfWeightIncreased =
            await _userPreferencesRepository
                .getMinConsumptionWhenWeightIncreased();

        final bool hasWeightIncreaseProof =
            minConsumptionIfWeightIncreased < constants.kMaxDailyFoodLimit;

        if (isWeightAboveHealthy) {
          portionControl = minConsumptionIfWeightIncreased;
        } else if (isWeightBelowHealthy) {
          portionControl = await _userPreferencesRepository
              .getMaxConsumptionWhenWeightDecreased();
        }

        // Synchronize with manually adjusted portion or latest calculation.
        final double? savedPortionControl = _userPreferencesRepository
            .getLastPortionControl();

        if (isWeightAboveHealthy) {
          if (portionControl == constants.kMaxDailyFoodLimit) {
            if (savedPortionControl != null) {
              portionControl = savedPortionControl;
            }
          } else {
            // We have a historical proof (min consumption when weight
            // increased).
            if (savedPortionControl != null &&
                savedPortionControl < portionControl) {
              portionControl = savedPortionControl;
            } else {
              await _userPreferencesRepository.savePortionControl(
                portionControl,
              );
            }
          }
        } else if (isWeightBelowHealthy) {
          if (portionControl == constants.kSafeMinimumFoodIntakeG) {
            if (savedPortionControl != null) {
              portionControl = savedPortionControl;
            }
          } else {
            // We have a historical proof (max consumption when weight
            // decreased).
            if (savedPortionControl != null &&
                savedPortionControl > portionControl) {
              portionControl = savedPortionControl;
            } else {
              await _userPreferencesRepository.savePortionControl(
                portionControl,
              );
            }
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
            language: language,
            dataDate: state.dataDate,
            hasWeightIncreaseProof: hasWeightIncreaseProof,
          ),
        );
      } catch (error, stackTrace) {
        // Handle errors (e.g. database issues).
        debugPrint('Error while submitting body weight: $error');
        debugPrint('Stack trace: $stackTrace');
        emit(
          BodyWeightError(
            errorMessage: translate(
              'error.failed_to_submit_body_weight',
              args: <String, Object?>{'errorDetails': '$error'},
            ),
            bodyWeight: state.bodyWeight,
            userDetails: state.userDetails,
            bodyWeightEntries: state.bodyWeightEntries,
            foodEntries: state.foodEntries,
            yesterdayConsumedTotal: state.yesterdayConsumedTotal,
            language: language,
            dataDate: state.dataDate,
            hasWeightIncreaseProof: state.hasWeightIncreaseProof,
          ),
        );
      }

      // Only add the event if it's NOT web AND NOT macOS.
      // For context, see issue:
      // https://github.com/ABausG/home_widget/issues/137.
      await _triggerHomeWidgetUpdate();
    } else {
      emit(
        BodyWeightError(
          errorMessage: translate(
            'error.body_weight_too_low',
            args: <String, Object?>{'minBodyWeight': constants.minBodyWeight},
          ),
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }
  }

  FutureOr<void> _submitFoodWeight(
    AddFoodEntry event,
    Emitter<HomeState> emit,
  ) async {
    final Language language = _userPreferencesRepository.getLanguage();
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
            language: language,
            dataDate: state.dataDate,
            hasWeightIncreaseProof: state.hasWeightIncreaseProof,
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
            language: language,
            dataDate: state.dataDate,
            hasWeightIncreaseProof: state.hasWeightIncreaseProof,
          ),
        );
      }
    } else {
      emit(
        FoodWeightError(
          errorMessage: translate('error.invalid_food_weight'),
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: state.foodEntries,
          yesterdayConsumedTotal: state.yesterdayConsumedTotal,
          isConfirmedAllMealsLogged: isMealsConfirmed,
          portionControl: state.portionControl,
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }

    _triggerHomeWidgetUpdate();
  }

  FutureOr<void> _deleteFoodEntry(
    DeleteFoodEntry event,
    Emitter<HomeState> emit,
  ) async {
    final Language language = _userPreferencesRepository.getLanguage();
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
                language: language,
                dataDate: state.dataDate,
                hasWeightIncreaseProof: state.hasWeightIncreaseProof,
              ),
            );
          });
    } catch (e) {
      debugPrint('Error in _deleteFoodEntry: $e');
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
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }
    _triggerHomeWidgetUpdate();
  }

  Future<void> _setDetailsToEditMode(
    EditDetails _,
    Emitter<HomeState> emit,
  ) async {
    final Language language = _userPreferencesRepository.getLanguage();
    final double yesterdayConsumedTotal = await _foodWeightRepository
        .getTotalConsumedYesterday();
    emit(
      DetailsUpdateState(
        bodyWeight: state.bodyWeight,
        userDetails: state.userDetails,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
        language: language,
        yesterdayConsumedTotal: yesterdayConsumedTotal,
        dataDate: state.dataDate,
        hasWeightIncreaseProof: state.hasWeightIncreaseProof,
      ),
    );
  }

  FutureOr<void> _setBodyWeightToEditMode(
    EditBodyWeight _,
    Emitter<HomeState> emit,
  ) {
    final Language language = _userPreferencesRepository.getLanguage();
    emit(
      BodyWeightUpdatedState(
        bodyWeight: state.bodyWeight,
        userDetails: state.userDetails,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
        language: language,
        dataDate: state.dataDate,
        hasWeightIncreaseProof: state.hasWeightIncreaseProof,
      ),
    );
  }

  FutureOr<void> _setFoodWeightToEditMode(
    EditFoodEntry event,
    Emitter<HomeState> emit,
  ) {
    final bool isMealsConfirmed =
        _userPreferencesRepository.isMealsConfirmedForToday;
    final Language language = _userPreferencesRepository.getLanguage();
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
        language: language,
        dataDate: state.dataDate,
        hasWeightIncreaseProof: state.hasWeightIncreaseProof,
      ),
    );
  }

  FutureOr<void> _clearTrackingData(
    ClearTrackingData _,
    Emitter<HomeState> emit,
  ) async {
    final Language language = _userPreferencesRepository.getLanguage();
    try {
      await _clearTrackingDataUseCase.execute();
      emit(
        DetailsUpdateState(
          bodyWeight: 0,
          userDetails: state.userDetails,
          bodyWeightEntries: const <BodyWeight>[],
          foodEntries: const <FoodWeight>[],
          language: language,
          yesterdayConsumedTotal: 0,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: false,
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
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }
  }

  FutureOr<void> _clearFoodEntries(
    ResetFoodEntries _,
    Emitter<HomeState> emit,
  ) async {
    final Language language = _userPreferencesRepository.getLanguage();
    try {
      await _foodWeightRepository.clearFoodEntries();
      emit(
        BodyWeightSubmittedState(
          bodyWeight: state.bodyWeight,
          userDetails: state.userDetails,
          bodyWeightEntries: state.bodyWeightEntries,
          foodEntries: const <FoodWeight>[],
          yesterdayConsumedTotal: 0,
          isConfirmedAllMealsLogged: false,
          portionControl: state.portionControl,
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
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
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }
  }

  FutureOr<void> _saveMealsConfirmation(
    ConfirmMealsLogged _,
    Emitter<HomeState> emit,
  ) async {
    final Language language = _userPreferencesRepository.getLanguage();
    final bool isSaved = await _userPreferencesRepository.saveMealsConfirmed();
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
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
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
          language: language,
          dataDate: state.dataDate,
          hasWeightIncreaseProof: state.hasWeightIncreaseProof,
        ),
      );
    }
  }

  FutureOr<void> _onFeedbackRequested(
    HomeBugReportPressedEvent _,
    Emitter<HomeState> emit,
  ) {
    final Language language = _userPreferencesRepository.getLanguage();
    _previousState = state;
    emit(
      HomeFeedbackState(
        userDetails: state.userDetails,
        bodyWeight: state.bodyWeight,
        yesterdayConsumedTotal: state.yesterdayConsumedTotal,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
        portionControl: state.portionControl,
        language: language,
        dataDate: state.dataDate,
        hasWeightIncreaseProof: state.hasWeightIncreaseProof,
      ),
    );
  }

  FutureOr<void> _onFeedbackDialogDismissed(
    HomeClosingFeedbackEvent _,
    Emitter<HomeState> emit,
  ) {
    if (_previousState != null) {
      emit(_previousState!);
    } else {
      add(const LoadEntries());
    }
  }

  FutureOr<void> _handleError(ErrorEvent event, Emitter<HomeState> emit) {
    debugPrint('ErrorEvent error: ${event.error}');
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
    final Language language = _userPreferencesRepository.getLanguage();
    emit(
      FeedbackHomeLoading(
        language: language,
        userDetails: state.userDetails,
        bodyWeight: state.bodyWeight,
        bodyWeightEntries: state.bodyWeightEntries,
        foodEntries: state.foodEntries,
        yesterdayConsumedTotal: state.yesterdayConsumedTotal,
        portionControl: state.portionControl,
        dataDate: state.dataDate,
        hasWeightIncreaseProof: state.hasWeightIncreaseProof,
      ),
    );
    final UserFeedback feedback = event.feedback;
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final Map<String, Object?>? extra = feedback.extra;
      final Object? rating = extra?['rating'];
      final Object? type = extra?['feedback_type'];

      // Construct the feedback text with details from `extra'.
      final StringBuffer feedbackBody = StringBuffer()
        ..writeln(
          '${type is FeedbackType ? translate('feedback.type') : ''}:'
          ' ${type is FeedbackType ? type.value : ''}',
        )
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
          ' ${rating is FeedbackRating ? rating.value : ''}',
        );

      try {
        if (kIsWeb) {
          // Handle email sending on the web using a `mailto` link.
          final Uri emailLaunchUri = Uri(
            scheme: constants.kMailToScheme,
            path: constants.supportEmail,
            queryParameters: <String, String>{
              constants.kSubjectParameter:
                  '${translate('feedback.appFeedback')}: '
                  '${packageInfo.appName}',
              constants.kBodyParameter: feedbackBody.toString(),
            },
          );

          if (await canLaunchUrl(emailLaunchUri)) {
            await launchUrl(emailLaunchUri);
          } else {
            add(ErrorEvent(translate('error.unexpectedError')));
          }
        } else {
          // TODO: move this thing to "data".
          final Resend resend = Resend.instance;
          await resend.sendEmail(
            from: constants.feedbackEmailSender,
            to: <String>[constants.supportEmail],
            subject:
                '${translate('feedback.app_feedback')}: ${packageInfo.appName}',
            text: feedbackBody.toString(),
          );
        }
      } catch (error, stackTrace) {
        debugPrint(
          'Error in $runtimeType in `onError`: $error.\n'
          'Stack trace: $stackTrace',
        );
        add(ErrorEvent(translate('error.unexpectedError')));
      }
    } catch (error, stackTrace) {
      debugPrint(
        'Error in $runtimeType in `onError`: $error.\n'
        'Stack trace: $stackTrace',
      );
      add(ErrorEvent(translate('error.unexpectedError')));
    }
    if (_previousState != null) {
      emit(_previousState!);
    } else {
      add(const LoadEntries());
    }
  }

  FutureOr<void> _updateDeviceHomeWidget(
    UpdateDeviceHomeWidgetEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Check if the platform is web OR macOS. If so, return early.
    // See issue: https://github.com/ABausG/home_widget/issues/137.
    if (!kIsWeb && !Platform.isMacOS) {
      final BodyWeight todayBodyWeight = await _bodyWeightRepository
          .getTodayBodyWeight();

      final PortionControlSummary portionControlSummary = PortionControlSummary(
        weight: todayBodyWeight.weight,
        consumed: state.totalConsumedToday,
        portionControl: state.portionControl,
        recommendation: state.bmiMessage,
        formattedLastUpdatedDateTime: _formattedLastUpdatedDateTime,
      );

      try {
        _homeWidgetService.setAppGroupId(constants.appleAppGroupId);

        _homeWidgetService.saveWidgetData<String>(
          HomeWidgetKey.locale.stringValue,
          state.language.isoLanguageCode,
        );

        _homeWidgetService.saveWidgetData<String>(
          HomeWidgetKey.weight.stringValue,
          portionControlSummary.weight.toString(),
        );

        _homeWidgetService.saveWidgetData<String>(
          HomeWidgetKey.consumed.stringValue,
          portionControlSummary.consumed.toString(),
        );

        _homeWidgetService.saveWidgetData<String>(
          HomeWidgetKey.portionControl.stringValue,
          portionControlSummary.portionControl.toString(),
        );

        _homeWidgetService.saveWidgetData<String>(
          HomeWidgetKey.textLastUpdated.stringValue,
          '${translate('last_updated_on_label')}\n'
          '${portionControlSummary.formattedLastUpdatedDateTime}',
        );

        _homeWidgetService.saveWidgetData<String>(
          HomeWidgetKey.textRecommendation.stringValue,
          portionControlSummary.recommendation,
        );

        if (state.bodyWeightEntries.length > 1) {
          // Line Chart of Body Weight trends for the last two weeks.
          await _homeWidgetService.renderFlutterWidget(
            MediaQuery(
              data: const MediaQueryData(
                // Logical pixels for the chart rendering.
                size: Size(400, 200),
              ),
              child: BodyWeightLineChart(
                bodyWeightEntries: state.lastTwoWeeksBodyWeightEntries,
              ),
            ),
            // This is the logical size for the home_widget plugin.
            logicalSize: const Size(400, 200),
            key: HomeWidgetKey.image.stringValue,
          );
        }

        _homeWidgetService.updateWidget(
          name: 'PortionControlWidget',
          iOSName: constants.iOSWidgetName,
          androidName: constants.kAndroidWidgetName,
        );
        if (Platform.isAndroid) {
          _homeWidgetService.updateWidget(
            qualifiedAndroidName:
                'com.turskyi.portion_control.glance.HomeWidgetReceiver',
          );
        }
      } catch (e) {
        debugPrint('Failed to update home screen widget: $e');
      }
    } else {
      debugPrint(
        'Home screen widget update skipped, '
        'because it is not supported on this platform.',
      );
    }
  }

  String get _formattedLastUpdatedDateTime {
    final DateTime now = DateTime.now();
    final DateTime lastUpdatedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    final String languageIsoCode = _userPreferencesRepository
        .getLanguageIsoCode();
    try {
      final DateFormat formatter = DateFormat(
        'MMM dd, EEEE \'-\' hh:mm a',
        languageIsoCode,
      );
      return formatter.format(lastUpdatedDateTime);
    } catch (e, stackTrace) {
      // We will get here if user does not have any of the app supported
      // languages on his device.
      debugPrint(
        'Error in `Weather.formattedLastUpdatedDateTime`:\n'
        'Failed to format date with locale "$languageIsoCode".\n'
        'Falling back to default locale formatting.\n'
        'Error: $e\n'
        'StackTrace: $stackTrace',
      );

      final DateFormat formatter = DateFormat('MMM dd, EEEE \'at\' hh:mm a');
      return formatter.format(lastUpdatedDateTime);
    }
  }

  Future<void> _triggerHomeWidgetUpdate() async {
    // Only add the event if it's NOT web AND NOT macOS.
    // For context, see issue:
    // https://github.com/ABausG/home_widget/issues/137.
    if (!kIsWeb && !Platform.isMacOS) {
      add(const UpdateDeviceHomeWidgetEvent());
    }
  }

  Future<void> _checkForUpdate(
    CheckForUpdate _,
    Emitter<HomeState> emit,
  ) async {
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        await _checkAndroidUpdate();
      } else if (Platform.isIOS) {
        await _checkIosUpdate();
      }
    }
  }

  Future<void> _checkAndroidUpdate() async {
    try {
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      debugPrint('Error checking for Android update: $e');
    }
  }

  Future<void> _checkIosUpdate() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String bundleId = packageInfo.packageName;
      final String currentVersion = packageInfo.version;

      final Uri url = Uri.parse('${constants.kITunesLookupUrl}$bundleId');

      final HttpClient client = HttpClient();
      final HttpClientRequest request = await client.getUrl(url);
      final HttpClientResponse response = await request.close();
      final String body = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Object? decodedData = json.decode(body);
        if (decodedData is Map<String, Object?>) {
          final Object? results = decodedData['results'];

          if (results is List<Object?> && results.isNotEmpty) {
            final Object? firstResult = results.first;

            if (firstResult is Map<String, Object?>) {
              final Object? storeVersion = firstResult['version'];
              final Object? trackViewUrl = firstResult['trackViewUrl'];

              if (storeVersion is String && trackViewUrl is String) {
                if (_isUpdateAvailable(currentVersion, storeVersion)) {
                  final Uri appStoreUri = Uri.parse(trackViewUrl);
                  final bool canLaunchAppStoreUrl = await canLaunchUrl(
                    appStoreUri,
                  );
                  if (canLaunchAppStoreUrl) {
                    await launchUrl(
                      appStoreUri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking for iOS update: $e');
    }
  }

  bool _isUpdateAvailable(String currentVersion, String storeVersion) {
    try {
      final List<int> currentParts = currentVersion
          .split('.')
          .map(int.parse)
          .toList();
      final List<int> storeParts = storeVersion
          .split('.')
          .map(int.parse)
          .toList();

      for (int i = 0; i < storeParts.length; i++) {
        final int current = i < currentParts.length ? currentParts[i] : 0;
        final int store = storeParts[i];

        if (store > current) return true;
        if (store < current) return false;
      }
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return false;
    }
    return false;
  }

  void _checkDateChangeOnResume(
    CheckDateChangeOnResume event,
    Emitter<HomeState> emit,
  ) {
    final DateTime now = DateTime.now();
    final DateTime lastDataDate = state.dataDate;

    // If the date has changed since the app was last active, reload entries
    if (!lastDataDate.isSameDate(now)) {
      add(const LoadEntries());
    }
  }
}
