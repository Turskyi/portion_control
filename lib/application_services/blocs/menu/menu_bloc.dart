import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:portion_control/domain/enums/feedback_rating.dart';
import 'package:portion_control/domain/enums/feedback_submission_type.dart';
import 'package:portion_control/domain/enums/feedback_type.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/exceptions/email_launch_exception.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/domain/models/portion_control_summary.dart';
import 'package:portion_control/domain/models/user_details.dart';
import 'package:portion_control/domain/services/repositories/i_body_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_food_weight_repository.dart';
import 'package:portion_control/domain/services/repositories/i_preferences_repository.dart';
import 'package:portion_control/domain/services/repositories/i_settings_repository.dart';
import 'package:portion_control/extensions/list_extension.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/res/enums/home_widget_keys.dart';
import 'package:portion_control/services/home_widget_service.dart';
import 'package:portion_control/services/reminder_service.dart';
import 'package:portion_control/ui/home/widgets/body_weight_line_chart.dart';
import 'package:resend/resend.dart';
import 'package:url_launcher/url_launcher.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc(
    this._settingsRepository,
    this._homeWidgetService,
    this._bodyWeightRepository,
    this._foodWeightRepository,
    this._userPreferencesRepository,
  ) : super(const LoadingMenuState(streakDays: 0)) {
    on<LoadingInitialMenuStateEvent>(_loadInitialMenuState);
    on<BugReportPressedEvent>(_onFeedbackRequested);
    on<MenuClosingFeedbackEvent>(_onFeedbackDialogDismissed);
    on<MenuSubmitFeedbackEvent>(_sendUserFeedback);
    on<MenuErrorEvent>(_handleError);
    on<ChangeLanguageEvent>(_changeLanguage);
    on<ChangeThemeEvent>(_changeTheme);
    on<OpenWebVersionEvent>(_openWebPage);
    on<PinWidgetEvent>(_onPinWidgetPressed);
    on<ToggleWeightReminderEvent>(_onToggleWeightReminder);
    on<ChangeWeightReminderTimeEvent>(_onChangeWeightReminderTime);
    on<SaveReminderSettingsEvent>(_onSaveReminderSettings);
  }

  final ISettingsRepository _settingsRepository;
  final HomeWidgetService _homeWidgetService;
  final IBodyWeightRepository _bodyWeightRepository;
  final IFoodWeightRepository _foodWeightRepository;
  final IUserPreferencesRepository _userPreferencesRepository;

  FutureOr<void> _onFeedbackRequested(
    BugReportPressedEvent _,
    Emitter<MenuState> emit,
  ) {
    emit(
      MenuFeedbackState(
        language: state.language,
        themeMode: state.themeMode,
        streakDays: state.streakDays,
        appVersion: state.appVersion,
        isWeightReminderEnabled: state.isWeightReminderEnabled,
        weightReminderTime: state.weightReminderTime,
      ),
    );
  }

  FutureOr<void> _onFeedbackDialogDismissed(
    MenuClosingFeedbackEvent _,
    Emitter<MenuState> emit,
  ) {
    emit(
      MenuInitial(
        language: state.language,
        themeMode: state.themeMode,
        streakDays: state.streakDays,
        appVersion: state.appVersion,
        isWeightReminderEnabled: state.isWeightReminderEnabled,
        weightReminderTime: state.weightReminderTime,
      ),
    );
  }

  FutureOr<void> _sendUserFeedback(
    MenuSubmitFeedbackEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(
      LoadingMenuState(
        language: state.language,
        themeMode: state.themeMode,
        streakDays: state.streakDays,
        appVersion: state.appVersion,
        isWeightReminderEnabled: state.isWeightReminderEnabled,
        weightReminderTime: state.weightReminderTime,
      ),
    );
    final UserFeedback feedback = event.feedback;
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final String platform = kIsWeb
          ? translate('web')
          : switch (defaultTargetPlatform) {
              TargetPlatform.android => translate('android'),
              TargetPlatform.iOS => translate('ios'),
              TargetPlatform.macOS => translate('macos'),
              TargetPlatform.windows => translate('windows'),
              TargetPlatform.linux => translate('linux'),
              TargetPlatform _ => translate('unknown'),
            };

      final Map<String, Object?>? extra = feedback.extra;
      final Object? rating = extra?[constants.ratingProperty];
      final Object? type = extra?[constants.feedbackTypeProperty];
      final Object? screenSize = extra?[constants.screenSizeProperty];
      final String feedbackText = feedback.text;

      // `extra?[constants.feedbackTextProperty]` is usually same as
      // `feedback.text`.
      final Object feedbackExtraText =
          extra?[constants.feedbackTextProperty] ?? feedbackText;

      final bool isFeedbackType = type is FeedbackType;
      final bool isFeedbackRating = rating is FeedbackRating;

      // Construct the feedback text with details from `extra'.
      final StringBuffer feedbackBody = StringBuffer()
        ..writeln(
          '${isFeedbackType ? translate('feedback.type') : ''}:'
          ' ${isFeedbackType ? type.value : ''}',
        )
        ..writeln(feedbackText.isEmpty ? feedbackExtraText : feedbackText)
        ..writeln(
          '${isFeedbackRating ? translate('feedback.rating') : ''}'
          '${isFeedbackRating ? ':' : ''}'
          ' ${isFeedbackRating ? rating.value : ''}',
        )
        ..writeln()
        ..writeln('${translate('app_id')}: ${packageInfo.packageName}')
        ..writeln('${translate('app_version')}: ${packageInfo.version}')
        ..writeln('${translate('build_number')}: ${packageInfo.buildNumber}')
        ..writeln()
        ..writeln('${translate('platform')}: $platform');

      if (screenSize != null) {
        feedbackBody.writeln('${translate('screen_size')}: $screenSize');
      }

      feedbackBody.writeln();

      try {
        if (event.submissionType.isAutomatic) {
          // TODO: move this thing to "data".
          final Resend resend = Resend.instance;
          await resend.sendEmail(
            from: constants.feedbackEmailSender,
            to: <String>[constants.supportEmail],
            subject:
                '${translate('feedback.app_feedback')}: ${packageInfo.appName}',
            text: feedbackBody.toString(),
          );
        } else if (kIsWeb || Platform.isMacOS) {
          // Handle email sending on the web and MacOS using a `mailto` link.
          final Uri emailLaunchUri = Uri(
            scheme: constants.kMailToScheme,
            path: constants.supportEmail,
            queryParameters: <String, String>{
              constants.kSubjectParameter:
                  '${translate('feedback.app_feedback')}: '
                  '${packageInfo.appName}',
              constants.kBodyParameter: feedbackBody.toString(),
            },
          );

          try {
            if (await canLaunchUrl(emailLaunchUri)) {
              await launchUrl(emailLaunchUri);
              debugPrint(
                'Menu Feedback email launched successfully via url_launcher.',
              );
            } else {
              throw const EmailLaunchException('error.launch_email_failed');
            }
          } catch (urlLauncherError, urlLauncherStackTrace) {
            final String urlLauncherErrorMessage =
                'Error launching email via url_launcher: $urlLauncherError';
            debugPrint(
              '$urlLauncherErrorMessage\nStackTrace: $urlLauncherStackTrace',
            );

            final String errorMessage = translate('error.launch_email_failed');

            add(MenuErrorEvent(errorMessage));
          }
        } else {
          final String screenshotFilePath = await _writeImageToStorage(
            feedback.screenshot,
          );
          final Email email = Email(
            subject:
                '${translate('feedback.app_feedback')}: ${packageInfo.appName}',
            body: feedbackBody.toString(),
            recipients: <String>[constants.supportEmail],
            attachmentPaths: <String>[screenshotFilePath],
          );
          try {
            await FlutterEmailSender.send(email);
          } catch (e, stackTrace) {
            debugPrint(
              'Warning: an error occurred in $this: $e;\n'
              'StackTrace: $stackTrace',
            );
          }
        }
        emit(
          MenuFeedbackSent(
            language: state.language,
            themeMode: state.themeMode,
            streakDays: state.streakDays,
            appVersion: state.appVersion,
            isWeightReminderEnabled: state.isWeightReminderEnabled,
            weightReminderTime: state.weightReminderTime,
          ),
        );
      } catch (error, stackTrace) {
        debugPrint(
          'Error in $runtimeType in `onError`: $error.\n'
          'Stacktrace: $stackTrace',
        );
        add(MenuErrorEvent(translate('error.unexpectedError')));
      }
    } catch (error, stackTrace) {
      debugPrint(
        'Error in $runtimeType in `onError`: $error.\n'
        'Stacktrace: $stackTrace',
      );
      add(MenuErrorEvent(translate('error.unexpectedError')));
    }
    emit(
      MenuInitial(
        language: state.language,
        themeMode: state.themeMode,
        streakDays: state.streakDays,
        appVersion: state.appVersion,
        isWeightReminderEnabled: state.isWeightReminderEnabled,
        weightReminderTime: state.weightReminderTime,
      ),
    );
  }

  Future<void> _loadInitialMenuState(
    LoadingInitialMenuStateEvent _,
    Emitter<MenuState> emit,
  ) async {
    final Language savedLanguage = _settingsRepository.getLanguage();
    final ThemeMode themeMode = _settingsRepository.getThemeMode();
    final int streakDays = await _bodyWeightRepository.getBodyWeightStreak();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion =
        '${packageInfo.version} (${packageInfo.buildNumber})';

    final bool isWeightReminderEnabled = _userPreferencesRepository
        .isWeightReminderEnabled();
    final String? timeString = _userPreferencesRepository
        .getWeightReminderTimeString();
    TimeOfDay weightReminderTime = const TimeOfDay(hour: 8, minute: 0);
    if (timeString != null) {
      final List<String> parts = timeString.split(':');
      weightReminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    emit(
      MenuInitial(
        language: savedLanguage,
        themeMode: themeMode,
        streakDays: streakDays,
        appVersion: appVersion,
        isWeightReminderEnabled: isWeightReminderEnabled,
        weightReminderTime: weightReminderTime,
      ),
    );
  }

  FutureOr<void> _handleError(MenuErrorEvent event, Emitter<MenuState> emit) {
    debugPrint('MenuErrorEvent: ${event.error}');
    //TODO: add ErrorMenuState and use it instead.
    emit(
      MenuInitial(
        streakDays: state.streakDays,
        appVersion: state.appVersion,
        language: state.language,
        themeMode: state.themeMode,
        isWeightReminderEnabled: state.isWeightReminderEnabled,
        weightReminderTime: state.weightReminderTime,
      ),
    );
  }

  FutureOr<void> _changeLanguage(
    ChangeLanguageEvent event,
    Emitter<MenuState> emit,
  ) async {
    final Language language = event.language;

    final MenuState state = this.state;

    if (language != state.language) {
      final bool isSaved = await _settingsRepository.saveLanguageIsoCode(
        language.isoLanguageCode,
      );
      if (isSaved) {
        if (state is MenuInitial) {
          emit(state.copyWith(language: language));
        } else {
          emit(
            MenuInitial(
              language: language,
              themeMode: state.themeMode,
              streakDays: state.streakDays,
              appVersion: state.appVersion,
              isWeightReminderEnabled: state.isWeightReminderEnabled,
              weightReminderTime: state.weightReminderTime,
            ),
          );
        }
      } else {
        //TODO: not sure what to do.
      }
    }
  }

  FutureOr<void> _changeTheme(
    ChangeThemeEvent event,
    Emitter<MenuState> emit,
  ) async {
    final ThemeMode themeMode = event.themeMode;
    final MenuState state = this.state;

    if (themeMode != state.themeMode) {
      final bool isSaved = await _settingsRepository.saveThemeMode(themeMode);
      if (isSaved) {
        if (state is MenuInitial) {
          emit(state.copyWith(themeMode: themeMode));
        } else {
          emit(
            MenuInitial(
              language: state.language,
              themeMode: themeMode,
              streakDays: state.streakDays,
              appVersion: state.appVersion,
              isWeightReminderEnabled: state.isWeightReminderEnabled,
              weightReminderTime: state.weightReminderTime,
            ),
          );
        }
      }
    }
  }

  FutureOr<void> _openWebPage(OpenWebVersionEvent _, Emitter<MenuState> _) {
    String url = constants.baseUrl;
    if (state.isUkrainian) {
      url = constants.ukrainianWebVersion;
    } else if (state.isFrench) {
      url = constants.frenchWebVersion;
    }
    if (url.isNotEmpty) launchUrl(Uri.parse(url));
  }

  Future<void> _onPinWidgetPressed(
    PinWidgetEvent event,
    Emitter<MenuState> emit,
  ) async {
    await _homeWidgetService.requestPinWidget(
      name: 'PortionControlWidget',
      androidName: constants.kAndroidWidgetName,
      qualifiedAndroidName:
          'com.turskyi.portion_control.glance.HomeWidgetReceiver',
    );
    _updateDeviceHomeWidget();
  }

  FutureOr<void> _updateDeviceHomeWidget() async {
    // Check if the platform is web OR macOS. If so, return early.
    // See issue: https://github.com/ABausG/home_widget/issues/137.
    if (!kIsWeb && !Platform.isMacOS) {
      final BodyWeight todayBodyWeight = await _bodyWeightRepository
          .getTodayBodyWeight();
      final List<FoodWeight> todayFoodWeightEntries =
          await _foodWeightRepository.getTodayFoodEntries();
      final double totalConsumedToday = todayFoodWeightEntries.fold(
        0,
        (double sum, FoodWeight entry) => sum + entry.weight,
      );

      final double portionControl = await _calculatePortionControl();

      final PortionControlSummary portionControlSummary = PortionControlSummary(
        weight: todayBodyWeight.weight,
        consumed: totalConsumedToday,
        portionControl: portionControl,
        recommendation: await _getBmiMessage(),
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

        final List<BodyWeight> bodyWeightEntries = await _bodyWeightRepository
            .getAllBodyWeightEntries();
        if (bodyWeightEntries.length > 1) {
          // Line Chart of Body Weight trends for the last two weeks.
          _homeWidgetService.renderFlutterWidget(
            MediaQuery(
              data: const MediaQueryData(
                // Logical pixels for the chart rendering.
                size: Size(400, 200),
              ),
              child: BodyWeightLineChart(
                bodyWeightEntries: bodyWeightEntries
                    .takeLast(DateTime.daysPerWeek * 2)
                    .toList(),
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

  //TODO: move this to a UseCase
  Future<double> _calculatePortionControl() async {
    final BodyWeight bodyWeightEntry = await _bodyWeightRepository
        .getLastBodyWeight();
    double portionControl = constants.kMaxDailyFoodLimit;

    if (bodyWeightEntry.weight > 0) {
      final double bodyWeight = bodyWeightEntry.weight;
      final bool isWeightAboveHealthy = _isWeightAboveHealthyFor(bodyWeight);
      final bool isWeightBelowHealthy = _isWeightBelowHealthyFor(bodyWeight);

      if (isWeightAboveHealthy) {
        portionControl = await _userPreferencesRepository
            .getMinConsumptionWhenWeightIncreased();
      } else if (isWeightBelowHealthy) {
        portionControl = await _userPreferencesRepository
            .getMaxConsumptionWhenWeightDecreased();
      }

      final double? savedPortionControl = _userPreferencesRepository
          .getLastPortionControl();

      if (isWeightAboveHealthy) {
        if (portionControl == constants.kMaxDailyFoodLimit) {
          if (savedPortionControl != null) {
            portionControl = savedPortionControl;
          } else {
            final double yesterdayTotal = await _foodWeightRepository
                .getTotalConsumedYesterday();
            if (yesterdayTotal > constants.kSafeMinimumFoodIntakeG) {
              portionControl = yesterdayTotal;
            }
          }
        } else if (savedPortionControl != null &&
            savedPortionControl < portionControl) {
          portionControl = savedPortionControl;
        }
      } else if (isWeightBelowHealthy) {
        if (portionControl == constants.kSafeMinimumFoodIntakeG) {
          if (savedPortionControl != null) {
            portionControl = savedPortionControl;
          }
        } else if (savedPortionControl != null &&
            savedPortionControl > portionControl) {
          portionControl = savedPortionControl;
        }
      } else if (savedPortionControl != null) {
        portionControl = savedPortionControl;
      }
    }
    return portionControl;
  }

  Future<String> _getBmiMessage() async {
    final double bmi = await _getBmi();
    if (bmi < constants.bmiUnderweightThreshold) {
      return translate('healthy_weight.underweight_message');
    } else if (bmi >= constants.bmiUnderweightThreshold &&
        bmi <= constants.bmiHealthyUpperThreshold) {
      return translate('healthy_weight.healthy_message');
    } else if (bmi >= constants.bmiOverweightLowerThreshold &&
        bmi <= constants.bmiOverweightUpperThreshold) {
      return translate('healthy_weight.overweight_message');
    } else {
      return translate('healthy_weight.obese_message');
    }
  }

  Future<double> _getBmi() async {
    final BodyWeight bodyWeight = await _bodyWeightRepository
        .getLastBodyWeight();
    final UserDetails userDetails = _userPreferencesRepository.getUserDetails();
    final double weight = bodyWeight.weight;
    final double heightInMeters = userDetails.heightInCm / 100;
    return weight / (heightInMeters * heightInMeters);
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

  bool _isWeightAboveHealthyFor(double bodyWeight) {
    final UserDetails userDetails = _userPreferencesRepository.getUserDetails();
    final double heightInMeters = userDetails.heightInCm / 100;
    if (heightInMeters == 0) return false;
    final double bmi = bodyWeight / (heightInMeters * heightInMeters);
    return bmi > constants.maxHealthyBmi;
  }

  bool _isWeightBelowHealthyFor(double bodyWeight) {
    final UserDetails userDetails = _userPreferencesRepository.getUserDetails();
    final double heightInMeters = userDetails.heightInCm / 100;
    if (heightInMeters == 0) return false;
    final double bmi = bodyWeight / (heightInMeters * heightInMeters);
    return bmi < constants.minHealthyBmi;
  }

  Future<String> _writeImageToStorage(Uint8List feedbackScreenshot) async {
    final Directory output = await path.getTemporaryDirectory();
    final String screenshotFilePath =
        '${output.path}/${constants.feedbackScreenshotFileName}';
    final File screenshotFile = File(screenshotFilePath);
    await screenshotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }

  void _onToggleWeightReminder(
    ToggleWeightReminderEvent event,
    Emitter<MenuState> emit,
  ) {
    if (state is MenuInitial) {
      emit(
        (state as MenuInitial).copyWith(isWeightReminderEnabled: event.enabled),
      );
    } else if (state is MenuFeedbackState) {
      emit(
        (state as MenuFeedbackState).copyWith(
          isWeightReminderEnabled: event.enabled,
        ),
      );
    } else if (state is MenuFeedbackSent) {
      emit(
        (state as MenuFeedbackSent).copyWith(
          isWeightReminderEnabled: event.enabled,
        ),
      );
    } else if (state is LoadingMenuState) {
      emit(
        (state as LoadingMenuState).copyWith(
          isWeightReminderEnabled: event.enabled,
        ),
      );
    }
  }

  void _onChangeWeightReminderTime(
    ChangeWeightReminderTimeEvent event,
    Emitter<MenuState> emit,
  ) {
    if (state is MenuInitial) {
      emit((state as MenuInitial).copyWith(weightReminderTime: event.time));
    } else if (state is MenuFeedbackState) {
      emit(
        (state as MenuFeedbackState).copyWith(weightReminderTime: event.time),
      );
    } else if (state is MenuFeedbackSent) {
      emit(
        (state as MenuFeedbackSent).copyWith(weightReminderTime: event.time),
      );
    } else if (state is LoadingMenuState) {
      emit(
        (state as LoadingMenuState).copyWith(weightReminderTime: event.time),
      );
    }
  }

  Future<void> _onSaveReminderSettings(
    SaveReminderSettingsEvent event,
    Emitter<MenuState> emit,
  ) async {
    final bool enabled = state.isWeightReminderEnabled;
    final TimeOfDay time = state.weightReminderTime;

    await _userPreferencesRepository.saveWeightReminderEnabled(enabled);
    await _userPreferencesRepository.saveWeightReminderTimeString(
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}',
    );

    if (enabled) {
      bool granted = await ReminderService.instance
          .requestNotificationPermissions();

      if (granted && Platform.isAndroid) {
        granted = await Permission.scheduleExactAlarm.request().isGranted;
      }

      if (granted) {
        await ReminderService.instance.scheduleDailyWeightReminder(
          time: time,
          body: translate('reminders.daily_reminder_body'),
        );
      }
    } else {
      await ReminderService.instance.cancelWeightReminder();
    }
  }
}
