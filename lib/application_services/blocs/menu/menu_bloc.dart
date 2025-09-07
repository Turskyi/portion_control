import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portion_control/domain/enums/feedback_rating.dart';
import 'package:portion_control/domain/enums/feedback_type.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/body_weight.dart';
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
  ) : super(const LoadingMenuState()) {
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
    emit(MenuFeedbackState(language: state.language));
  }

  FutureOr<void> _onFeedbackDialogDismissed(
    MenuClosingFeedbackEvent _,
    Emitter<MenuState> emit,
  ) {
    emit(MenuInitial(language: state.language));
  }

  FutureOr<void> _sendUserFeedback(
    MenuSubmitFeedbackEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(
      LoadingMenuState(language: state.language),
    );
    final UserFeedback feedback = event.feedback;
    try {
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
            add(MenuErrorEvent(translate('error.unexpectedError')));
          }
        } else {
          // TODO: move this thing to "data".
          final Resend resend = Resend.instance;
          await resend.sendEmail(
            from: 'Do Not Reply ${constants.appName} '
                '<no-reply@${constants.resendEmailDomain}>',
            to: <String>[constants.supportEmail],
            subject:
                '${translate('feedback.app_feedback')}: ${packageInfo.appName}',
            text: feedbackBody.toString(),
          );
        }
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
      MenuInitial(language: state.language),
    );
  }

  FutureOr<void> _loadInitialMenuState(
    LoadingInitialMenuStateEvent _,
    Emitter<MenuState> emit,
  ) {
    final Language savedLanguage = _settingsRepository.getLanguage();
    emit(MenuInitial(language: savedLanguage));
  }

  FutureOr<void> _handleError(MenuErrorEvent event, Emitter<MenuState> emit) {
    debugPrint('MenuErrorEvent: ${event.error}');
    //TODO: add ErrorMenuState and use it instead.
    emit(const MenuInitial());
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
          MenuInitial(language: language);
        }
      } else {
        //TODO: not sure what to do.
      }
    }
  }

  FutureOr<void> _openWebPage(
    OpenWebVersionEvent _,
    Emitter<MenuState> __,
  ) {
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
      final BodyWeight todayBodyWeight =
          await _bodyWeightRepository.getTodayBodyWeight();
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
        recommendation: await _getMmiMessage(),
        formattedLastUpdatedDateTime: _formattedLastUpdatedDateTime,
      );

      try {
        _homeWidgetService.setAppGroupId(constants.appleAppGroupId);

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

        final List<BodyWeight> bodyWeightEntries =
            await _bodyWeightRepository.getAllBodyWeightEntries();
        if (bodyWeightEntries.length > 1) {
          // Line Chart of Body Weight trends for the last two weeks.
          _homeWidgetService.renderFlutterWidget(
            BodyWeightLineChart(
              bodyWeightEntries:
                  bodyWeightEntries.takeLast(DateTime.daysPerWeek * 2).toList(),
            ),
            logicalSize: const Size(100, 400),
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
    final double totalConsumedYesterday =
        await _foodWeightRepository.getTotalConsumedYesterday();
    final List<BodyWeight> bodyWeightEntries =
        await _bodyWeightRepository.getAllBodyWeightEntries();
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
    final double yesterdayConsumedTotal =
        await _foodWeightRepository.getTotalConsumedYesterday();
    if (yesterdayConsumedTotal <= 0 || bodyWeightEntries.isEmpty) {
      return false;
    }
    if (bodyWeightEntries.length == 1) {
      return true;
    }
    return bodyWeightEntries.last.weight >=
        bodyWeightEntries[bodyWeightEntries.length - 2].weight;
  }

  Future<String> _getMmiMessage() async {
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
    final BodyWeight bodyWeight =
        await _bodyWeightRepository.getLastBodyWeight();
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
    final double yesterdayConsumedTotal =
        await _foodWeightRepository.getTotalConsumedYesterday();
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
}
