import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:portion_control/domain/enums/feedback_rating.dart';
import 'package:portion_control/domain/enums/feedback_submission_type.dart';
import 'package:portion_control/domain/enums/feedback_type.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/exceptions/email_launch_exception.dart';
import 'package:portion_control/domain/services/repositories/i_settings_repository.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:resend/resend.dart';
import 'package:url_launcher/url_launcher.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._settingsRepository)
    : super(SettingsInitial(language: _settingsRepository.getLanguage())) {
    on<ClosingFeedbackEvent>(_onFeedbackDialogDismissed);

    on<BugReportPressedEvent>(_onFeedbackRequested);

    on<SubmitFeedbackEvent>(_sendUserFeedback);

    on<SettingsErrorEvent>(_handleError);

    on<SettingsChangeLanguageEvent>(_changeLanguage);
  }

  final ISettingsRepository _settingsRepository;

  FutureOr<void> _handleError(
    SettingsErrorEvent event,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsError(errorMessage: event.error, language: state.language));
  }

  FutureOr<void> _sendUserFeedback(
    SubmitFeedbackEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! LoadingSettingsState && state is! SettingsFeedbackSent) {
      emit(LoadingSettingsState(language: state.language));
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
          ..writeln('${translate('platform')}: $platform')
          ..writeln(
            '${translate('screen_size')}: '
            '${screenSize ?? translate('unknown')}',
          )
          ..writeln();

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
          final Uri emailLaunchUri = Uri(
            scheme: constants.mailToScheme,
            path: constants.supportEmail,
            queryParameters: <String, Object?>{
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
                'Feedback email launched successfully via url_launcher.',
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

            emit(
              SettingsError(
                errorMessage: errorMessage,
                language: state.language,
              ),
            );
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

        emit(SettingsFeedbackSent(language: state.language));
      } catch (e, stackTrace) {
        debugPrint('SettingsErrorEvent:$e\nStackTrace: $stackTrace');
        emit(
          SettingsError(
            errorMessage: translate('error.unexpected_error'),
            language: state.language,
          ),
        );
      }
    }
  }

  FutureOr<void> _onFeedbackRequested(
    BugReportPressedEvent event,
    Emitter<SettingsState> emit,
  ) {
    String errorMessage = event.errorText;

    final SettingsState state = this.state;
    if (state is SettingsError) {
      errorMessage = state.errorMessage;
    } else if (state is FeedbackState) {
      errorMessage = state.errorMessage;
    }
    emit(FeedbackState(language: state.language, errorMessage: errorMessage));
  }

  FutureOr<void> _onFeedbackDialogDismissed(
    ClosingFeedbackEvent _,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsInitial(language: state.language));
  }

  FutureOr<void> _changeLanguage(
    SettingsChangeLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final Language language = event.language;

    final SettingsState state = this.state;

    if (language != state.language) {
      final bool isSaved = await _settingsRepository.saveLanguageIsoCode(
        language.isoLanguageCode,
      );
      if (isSaved) {
        if (state is SettingsInitial) {
          emit(state.copyWith(language: language));
        } else {
          SettingsInitial(language: language);
        }
      } else {
        //TODO: no sure what to do.
      }
    }
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
