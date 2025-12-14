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
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/res/enums/home_widget_keys.dart';
import 'package:portion_control/services/home_widget_service.dart';
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
    this._localDataSource,
  ) : super(const LoadingMenuState(streakDays: 0)) {
    on<LoadingInitialMenuStateEvent>(_loadInitialMenuState);
    on<BugReportPressedEvent>(_onFeedbackRequested);
    on<MenuClosingFeedbackEvent>(_onFeedbackDialogDismissed);
    on<MenuSubmitFeedbackEvent>(_sendUserFeedback);
    on<MenuErrorEvent>(_handleError);
    on<ChangeLanguageEvent>(_changeLanguage);
    on<OpenWebVersionEvent>(_openWebPage);
    on<PinWidgetEvent>(_onPinWidgetPressed);
  }

  final ISettingsRepository _settingsRepository;
  final HomeWidgetService _homeWidgetService;
  final IBodyWeightRepository _bodyWeightRepository;
  final IFoodWeightRepository _foodWeightRepository;
  final IUserPreferencesRepository _userPreferencesRepository;
  final LocalDataSource _localDataSource;

  FutureOr<void> _onFeedbackRequested(
    BugReportPressedEvent _,
    Emitter<MenuState> emit,
  ) {
    emit(
      MenuFeedbackState(
        language: state.language,
        streakDays: state.streakDays,
      ),
    );
  }

  FutureOr<void> _onFeedbackDialogDismissed(
    MenuClosingFeedbackEvent _,
    Emitter<MenuState> emit,
  ) {
    emit(MenuInitial(language: state.language, streakDays: state.streakDays));
  }

  FutureOr<void> _sendUserFeedback(
    MenuSubmitFeedbackEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(
      LoadingMenuState(language: state.language, streakDays: state.streakDays),
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
            scheme: constants.mailToScheme,
            path: constants.supportEmail,
            queryParameters: <String, String>{
              constants.subjectParameter:
                  '${translate('feedback.app_feedback')}: '
                  '${packageInfo.appName}',
              constants.bodyParameter: feedbackBody.toString(),
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
            streakDays: state.streakDays,
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
    emit(MenuInitial(language: state.language, streakDays: state.streakDays));
  }

  Future<void> _loadInitialMenuState(
    LoadingInitialMenuStateEvent _,
    Emitter<MenuState> emit,
  ) async {
    final Language savedLanguage = _settingsRepository.getLanguage();
    final int streakDays = await _bodyWeightRepository.getBodyWeightStreak();
    emit(MenuInitial(language: savedLanguage, streakDays: streakDays));
  }

  FutureOr<void> _handleError(MenuErrorEvent event, Emitter<MenuState> emit) {
    debugPrint('MenuErrorEvent: ${event.error}');
    //TODO: add ErrorMenuState and use it instead.
    emit(MenuInitial(streakDays: state.streakDays));
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
          MenuInitial(language: language, streakDays: state.streakDays);
        }
      } else {
        //TODO: not sure what to do.
      }
    }
  }

  FutureOr<void> _openWebPage(OpenWebVersionEvent _, Emitter<MenuState> _) {
    String url = constants.baseUrl;
    if (state.isUkrainian) {
      url = constants.ukrainianWebVersion;
    }
    launchUrl(Uri.parse(url));
  }

  Future<void> _onPinWidgetPressed(
    PinWidgetEvent event,
    Emitter<MenuState> emit,
  ) async {
    await _homeWidgetService.requestPinWidget(
      name: 'PortionControlWidget',
      androidName: constants.androidWidgetName,
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
          androidName: constants.androidWidgetName,
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
    final double totalConsumedYesterday = await _foodWeightRepository
        .getTotalConsumedYesterday();
    final List<BodyWeight> bodyWeightEntries = await _bodyWeightRepository
        .getAllBodyWeightEntries();
    double portionControl = constants.maxDailyFoodLimit;

    if (bodyWeightEntries.isNotEmpty) {
      final BodyWeight lastSavedBodyWeightEntry = bodyWeightEntries.last;

      final bool isWeightIncreasingOrSame = await _isWeightIncreasingOrSameFor(
        bodyWeightEntries,
      );
      final bool isWeightAboveHealthy = _isWeightAboveHealthyFor(
        lastSavedBodyWeightEntry.weight,
      );
      final bool isWeightDecreasingOrSame = await _isWeightDecreasingOrSameFor(
        bodyWeightEntries,
      );
      final bool isWeightBelowHealthy = _isWeightBelowHealthyFor(
        lastSavedBodyWeightEntry.weight,
      );

      final double? savedPortionControl = _userPreferencesRepository
          .getPortionControl();

      if (isWeightIncreasingOrSame && isWeightAboveHealthy) {
        if (savedPortionControl == null) {
          portionControl = totalConsumedYesterday;
        } else if (savedPortionControl < totalConsumedYesterday) {
          portionControl = savedPortionControl;
        } else if (savedPortionControl > totalConsumedYesterday) {
          portionControl = totalConsumedYesterday;
        }
        // Ensure portion control doesn't go below the minimum safe intake
        // if it was adjusted downwards based on yesterday's consumption.
        if (portionControl < constants.safeMinimumFoodIntakeG) {
          portionControl = constants.safeMinimumFoodIntakeG;
        }
      } else if (isWeightDecreasingOrSame && isWeightBelowHealthy) {
        // When weight is decreasing and below healthy,
        // prioritize safe minimum or user's higher intake.
        portionControl = constants.safeMinimumFoodIntakeG;
        if (savedPortionControl == null) {
          if (totalConsumedYesterday > constants.safeMinimumFoodIntakeG) {
            portionControl = totalConsumedYesterday;
          }
        } else {
          // If there's a saved portion, take the higher of saved, yesterday,
          // or safe minimum.
          if (savedPortionControl > portionControl) {
            portionControl = savedPortionControl;
          }
          if (totalConsumedYesterday > portionControl) {
            portionControl = totalConsumedYesterday;
          }
        }
      }
      // If no specific condition met, `portionControl` remains
      // `constants.maxDailyFoodLimit`.
      else if (savedPortionControl != null) {
        portionControl = savedPortionControl;
      }
    }
    return portionControl;
  }

  Future<bool> _isWeightIncreasingOrSameFor(
    List<BodyWeight> bodyWeightEntries,
  ) async {
    final double yesterdayConsumedTotal = await _foodWeightRepository
        .getTotalConsumedYesterday();
    if (yesterdayConsumedTotal <= 0 || bodyWeightEntries.isEmpty) {
      return false;
    }
    if (bodyWeightEntries.length == 1) {
      return true;
    }
    return bodyWeightEntries.last.weight >=
        bodyWeightEntries[bodyWeightEntries.length - 2].weight;
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
    final String languageIsoCode = _localDataSource.getLanguageIsoCode();
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
    final double bmi = bodyWeight / (heightInMeters * heightInMeters);
    return bmi > constants.maxHealthyBmi;
  }

  Future<bool> _isWeightDecreasingOrSameFor(
    List<BodyWeight> bodyWeightEntries,
  ) async {
    final double yesterdayConsumedTotal = await _foodWeightRepository
        .getTotalConsumedYesterday();
    if (yesterdayConsumedTotal <= 0 || bodyWeightEntries.isEmpty) {
      return false;
    }
    if (bodyWeightEntries.length == 1) {
      return true;
    }
    return bodyWeightEntries.last.weight <=
        bodyWeightEntries[bodyWeightEntries.length - 2].weight;
  }

  bool _isWeightBelowHealthyFor(double bodyWeight) {
    final UserDetails userDetails = _userPreferencesRepository.getUserDetails();
    final double heightInMeters = userDetails.heightInCm / 100;
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
}
