import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This is a 1x1 transparent PNG. It's a standard technique to mock images in tests.
final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

Future<LocalizationDelegate> setUpFlutterTranslateForTests({
  Locale startLocale = const Locale('en'),
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  // The asset manifest must contain a list of variant maps for each asset.
  final Map<String, dynamic> manifest = <String, dynamic>{
    'assets/i18n/en.json': <Map<String, String>>[
      {'asset': 'assets/i18n/en.json'},
    ],
    'assets/i18n/uk.json': <Map<String, String>>[
      {'asset': 'assets/i18n/uk.json'},
    ],
    'assets/images/onboarding_plate.png': <Map<String, String>>[
      {'asset': 'assets/images/onboarding_plate.png'},
    ],
  };

  binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets',
      (ByteData? message) async {
    if (message == null) {
      return null;
    }
    final String key = utf8.decode(message.buffer.asUint8List());

    if (key == 'AssetManifest.json') {
      return ByteData.sublistView(utf8.encode(json.encode(manifest)));
    }

    if (key == 'AssetManifest.bin') {
      final ByteData? manifestData =
          const StandardMessageCodec().encodeMessage(manifest);
      return manifestData;
    }

    if (key == 'assets/i18n/en.json') {
      return ByteData.sublistView(utf8.encode(json.encode(_enTestTranslations)));
    }
    if (key == 'assets/i18n/uk.json') {
      return ByteData.sublistView(utf8.encode(json.encode(_ukTestTranslations)));
    }
    if (key == 'assets/images/onboarding_plate.png') {
      return ByteData.sublistView(kTransparentImage);
    }
    return null;
  });

  final LocalizationDelegate delegate = await LocalizationDelegate.create(
    fallbackLocale: Language.en.isoLanguageCode,
    supportedLocales: <String>[
      Language.en.isoLanguageCode,
      Language.uk.isoLanguageCode,
    ],
  );

  await delegate.changeLocale(startLocale);

  return delegate;
}

// Mock translation data for tests.
const Map<String, Object?> _enTestTranslations = <String, Object?>{
  'title': 'PortionControl',
  'submit': 'Submit',
  'app_id': 'App id',
  'app_version': 'App version',
  'build_number': 'Build number',
  'features': 'Features',
  'support_and_feedback': 'Support & Feedback',
  'telegram_group': 'Telegram Support Group',
  'developer_contact_form': 'Developer Contact Form',
  'privacy_policy': 'Privacy Policy',
  'last_updated': 'Last updated',
  'for': 'for',
  'android_app': 'Android Application',
  'location': 'Location Data',
  'third_party': 'Third-Party Services',
  'consent': 'Consent',
  'children_privacy': "Children's Privacy",
  'crashlytics': 'Crashlytics',
  'ai_content': 'AI-Generated Content',
  'updates_and_notifications': 'Updates and Notification',
  'contact_us': 'Contact Us',
  'platform_specific': 'Platform-Specific Features',
  'mobile': 'Mobile (Android/iOS)',
  'macos': 'macOS',
  'web': 'Web',
  'never_updated': 'Never updated',
  'could_not_launch': 'Could not launch',
  'faq': 'Frequently Asked Questions',
  'legal_and_app_info_title': '📄 Legal & App Info',
  'developer': 'Developer',
  'developer_name': 'Dmytro Turskyi',
  'email': 'Email',
  'last_updated_on_label': 'Last Updated on',
  'no': 'No',
  'yes': 'Yes',
  'cancel': 'Cancel',
  'ukrainian': 'Ukrainian',
  'english': 'English',
  'en': 'EN',
  'uk': 'UK',
  'platform': 'Platform',
  'android': 'Android',
  'ios': 'iOS',
  'windows': 'Windows',
  'linux': 'Linux',
  'unknown': 'Unknown',
  'feedback': <String, String>{
    'title': 'Feedback',
    'app_feedback': 'App Feedback',
    'what_kind': 'What kind of feedback do you want to give?',
    'what_is_your_feedback': 'What is your feedback?',
    'how_does_this_feel': 'How does this make you feel?',
    'sent': 'Your feedback has been sent successfully!',
    'bug_report': 'Bug report',
    'feature_request': 'Feature request',
    'type': 'Feedback Type',
    'rating': 'Rating',
    'bad': 'Bad',
    'neutral': 'Neutral',
    'good': 'Good',
  },
  'error': <String, String>{
    'please_check_internet':
        'An error occurred. Please check your internet connection and try '
        'again.',
    'unexpected_error': 'An unexpected error occurred. Please try again.',
    'oops': 'Oops! Something went wrong. Please try again later.',
    'cors':
        'Error: Local Environment Setup Required\nTo run this application '
        'locally on web, please use the following command:\nflutter run -d '
        'chrome --web-browser-flag "--disable-web-security"\nThis step is '
        'necessary to bypass CORS restrictions during local development. '
        'Please note that this flag should only be used in a development '
        'environment and never in production.',
    'launch_email_or_support_page': 'Could not launch email or support page.',
    'something_went_wrong': 'Something went wrong!',
    'searching_location': 'Error searching for location',
    'launch_email_app_to_address':
        'Could not launch email app to send an email to {emailAddress}',
    'launch_email_failed': 'Could not launch the email application.',
    'save_asset_image_failed': 'Failed to save image to device storage',
  },
  'settings': <String, String>{
    'title': 'Settings',
    'language': 'Language',
    'temperature_units_subtitle_imperial':
        'Use imperial measurements for temperature units.',
    'feedback_subtitle':
        'Let us know your thoughts and suggestions. You can also report any '
        'issues with the app’s content.',
    'support_subtitle':
        'Visit our support page for help and frequently asked questions.',
  },
  'about': <String, String>{
    'title': 'About',
    'feature_privacy_friendly': '• Privacy-friendly (no tracking, no accounts)',
    'feature_home_widgets': '• Home screen widgets for mobile devices',
    'privacy_title': 'Privacy & Data',
    'view_privacy_policy': 'View Privacy Policy',
    'support_description':
        'Having trouble? Need help or want to suggest a feature? Join the '
        'community or contact the developer directly.',
    'contact_support': 'Contact Support',
  },
  'privacy': <String, String>{
    'policy_intro':
        "Your privacy is important to us. It is {appName}'s policy to respect "
        'your privacy and comply with any applicable law and regulation '
        'regarding any personal information we may collect about you, '
        'including across our app, «{appName}», and its associated '
        'services.',
    'information_we_collect': 'Information We Collect',
    'no_personal_data_collection':
        'We do not collect any personal information such as name, email '
        'address, or phone number.',
    'third_party_services_info':
        '«{appName}» uses third-party services that may collect information '
        'used to identify you. These services include Firebase Crashlytics '
        'and Google Analytics. The data collected by these services is '
        'used to improve app stability and user experience. You can find '
        'more information about their privacy practices at their '
        'respective websites.',
    'consent_agreement':
        'By using our services, you consent to the collection and use of your '
        'information as described in this privacy policy.',
    'security_measures': 'Security Measures',
    'security_measures_description':
        'We take reasonable measures to protect your information from '
        'unauthorized access, disclosure, or modification.',
    'children_description':
        'Our services are not directed towards children under the age of '
        '{age}. We do not knowingly collect personal information from '
        'children under {age}. While we strive to minimize data '
        'collection, third-party services we use (such as Firebase '
        'Crashlytics and Google Analytics) may collect some data. However, '
        'this data is collected anonymously and is not linked to any '
        'personal information. If you believe that a child under {age} has '
        'provided us with personal information, please contact us, and we '
        'will investigate the matter.',
    'crashlytics_description':
        '«{appName}» uses Firebase Crashlytics, a service by Google, to '
        'collect crash reports anonymously to help us improve app '
        'stability and fix bugs. The data collected by Crashlytics does '
        'not include any personal information.',
    'updates_and_notifications_description':
        'This privacy policy may be updated periodically. Any changes to the '
        'policy will be communicated to you through app updates or '
        'notifications.',
    'contact_us_invitation':
        'For any questions or concerns regarding your privacy, you may contact '
        'us using the following details:',
  },
  'support': <String, String>{
    'title': 'Support',
    'intro_line':
        'Need help or want to give feedback? You’re in the right place.',
    'contact_intro': 'If you’re experiencing issues or have suggestions:',
    'contact_us_via_email_button': 'Contact Us via Email',
    'join_telegram_support_button': 'Join Telegram Support Group',
    'visit_developer_support_website_button':
        "Visit Support Page on Developer's Website",
    'email_default_body': 'Hi, I need help with...',
  },
};

const Map<String, Object?> _ukTestTranslations = <String, Object?>{
  'title': 'WeatherFit',
  'submit': 'Відправити',
  'app_id': 'Ідентифікатор програми',
  'app_version': 'Версія програми',
  'build_number': 'Номер збірки',
  'features': 'Можливості (Функції)',
  'artwork': 'Ілюстрації',
  'support_and_feedback': 'Підтримка та відгук',
  'telegram_group': 'Группа в Телеграмі',
  'developer_contact_form': "Зв'яжіться з розробником",
  'privacy_policy': 'Політика конфіденційності',
  'for': 'для',
  'android_app': 'Андроїд додатку',
  'last_update': 'Останнє оновлення',
  'location': 'Дані про місцезнаходження',
  'third_party': 'Внутрішні бібліотеки',
  'consent': 'Погодження',
  'children_privacy': 'Політика конфіденційності для дітей',
  'crashlytics': 'Крашлітика',
  'ai_content': 'Контент, сгенерований нейронними мережами',
  'updates_and_notifications': 'Оновлення та сповіщення',
  'contact_us': "Зв'яжіться з нами",
  'platform_specific_features': 'Функції, специфічні для платформи',
  'mobile': 'Мобільні пристрої (Андроїд, Айос)',
  'macos': 'Макось',
  'web': 'Веб (Інтернет)',
  'never_updated': 'Ніколи не оновлювався',
  'lat': 'Широта',
  'lon': 'Довгота',
  'could_not_launch': 'Не вдалося відкрити',
  'faq': 'Часті запитання',
  'contact_support': 'Звернутися до служби підтримки',
  'legal_and_app_info_title':
      '📄 Правова інформація та інформація про '
      'програму',
  'developer': 'Розробник',
  'developer_name': 'Дмитро Турський',
  'email': 'Електронна пошта',
  'last_updated_on_label': 'Востаннє оновлено',
  'no': 'Ні',
  'yes': 'Так',
  'cancel': 'Скасувати',
  'ukrainian': 'Українська',
  'english': 'Англійська',
  'en': 'АН',
  'uk': 'УК',
  'platform': 'Платформа',
  'android': 'Андроїд',
  'ios': 'Айос',
  'window': <Object?, Object?>{},
};
