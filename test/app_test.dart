import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/app.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/database.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/localization/localization_delelegate_getter.dart'
    as localization;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/feedback/feedback_form.dart';
import 'package:portion_control/ui/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_interactors.dart';
import 'mock_repositories.dart';

void main() {
  testWidgets('App initializes and shows HomePage',
      (WidgetTester tester) async {
    // Create a mock instance of BodyWeightRepository.
    final MockBodyWeightRepository mockBodyWeightRepository =
        MockBodyWeightRepository();
    final MockFoodWeightRepository mockFoodWeightRepository =
        MockFoodWeightRepository();
    final MockUserDetailsRepository mockUserDetailsRepository =
        MockUserDetailsRepository();

    final MockClearTrackingDataUseCase mockClearTrackingDataUseCase =
        MockClearTrackingDataUseCase();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final AppDatabase appDatabase = AppDatabase();
    final LocalDataSource localDataSource = LocalDataSource(
      preferences,
      appDatabase,
    );
    await setUpFlutterTranslateForTests();

    final LocalizationDelegate localizationDelegate =
        await localization.getLocalizationDelegate(localDataSource);
    // Create a simple route map for testing.
    final Map<String, WidgetBuilder> testRoutes = <String, WidgetBuilder>{
      AppRoute.home.path: (BuildContext _) {
        return HomePage(localDataSource: localDataSource);
      },
    };

    // Provide the HomeBloc using a BlocProvider.
    await tester.pumpWidget(
      LocalizedApp(
        localizationDelegate,
        BetterFeedback(
          feedbackBuilder: (
            _,
            OnSubmit onSubmit,
            ScrollController? scrollController,
          ) =>
              FeedbackForm(
            onSubmit: onSubmit,
            scrollController: scrollController,
          ),
          child: BlocProvider<HomeBloc>(
            create: (_) => HomeBloc(
              mockUserDetailsRepository,
              mockBodyWeightRepository,
              mockFoodWeightRepository,
              mockClearTrackingDataUseCase,
            ),
            child: App(routeMap: testRoutes),
          ),
        ),
      ),
    );

    // Verify that the MaterialApp is present.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that the HomePage is shown.
    expect(find.byType(HomePage), findsOneWidget);
  });
}

Future<LocalizationDelegate> setUpFlutterTranslateForTests({
  Locale startLocale = const Locale('en'),
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final LocalizationDelegate delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en',
    supportedLocales: <String>['en', 'uk'],
  );

  // Manually load translations for the starting locale into the static
  // Localization instance.
  // This is the key to bypassing the file loading for the actual translation
  // content.
  if (startLocale.languageCode == 'en') {
    Localization.load(_enTestTranslations);
  } else if (startLocale.languageCode == 'uk') {
    Localization.load(_ukTestTranslations);
  } else {
    // Load fallback or throw error if startLocale is not one of your test
    // locales.
    Localization.load(_enTestTranslations);
  }

  // Ensure the delegate's internal state reflects this locale.
  // The call to Localization.load above primes the static instance.
  // The changeLocale method in the delegate will use this primed instance
  // if its internal logic calls Localization.instance.
  // Or, more directly, it also calls Localization.load itself.
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
    'cors': 'Error: Local Environment Setup Required\nTo run this application '
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
  'legal_and_app_info_title': '📄 Правова інформація та інформація про '
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
  'windows': 'Віндовс',
  'linux': 'Лінукс',
  'unknown': 'Невідомо',
  'feedback': <String, String>{
    'title': 'Відгук',
    'app_feedback': 'Відгук про додаток',
    'what_kind': 'Який тип відгуку ви хочете надіслати?',
    'what_is_your_feedback': 'Який ваш відгук?',
    'how_does_this_feel': 'Які це викликає у вас почуття?',
    'sent': 'Ваш відгук успішно надіслано!',
    'bug_report': 'Повідомлення про помилку',
    'feature_request': 'Запропонувати покращення',
    'type': 'Тип відгуку',
    'rating': 'Рейтинг',
    'bad': 'Погано',
    'neutral': 'Нейтральний',
    'good': 'Добре',
  },
  'error': <String, String>{
    'please_check_internet': 'Виникла помилка. Будьласка, перевірте '
        'підключення до Інтернету та спробуйте ще раз.',
    'unexpected_error': 'Виникла неочікувана помилка. Будь ласка, спробуйте ще '
        'раз.',
    'oops': 'Ой лишенько! Щось пішло не так. Будь ласка, спробуйте пізніше.',
    'cors': 'Помилка: Необхідне налаштування локального середовища\nДля '
        'локального запуску цього веб додатку в браузері, будь ласка, '
        'використовуйте наступну команду:\n'
        'flutter run -d chrome --web-browser-flag "--disable-web-security"\n'
        'Цей крок необхідний для обходу обмежень CORS під час локальної '
        'розробки. Зверніть увагу, що цей прапорець слід використовувати '
        'тільки в середовищі розробки і ніколи в продакшні.',
    'launch_email_or_support_page': 'Не вдалося запустити електронну пошту або '
        'сторінку підтримки.',
    'something_went_wrong': 'Щось пішло не так!',
    'launch_email_app_to_address': 'Не вдалося запустити поштовий клієнт, щоб '
        'надіслати листа на адресу {emailAddress}',
    'launch_email_failed': 'Не вдалося запустити поштову програму.',
    'save_asset_image_failed': 'Не вдалося зберегти зображення у сховищі '
        'пристрою',
  },
  'settings': <String, String>{
    'title': 'Налаштування',
    'language': 'Мова',
    'feedback_subtitle': 'Поділіться своїми думками та пропозиціями. Ви також '
        'можете повідомити про будь-які проблеми з вмістом програми.',
    'support_subtitle': 'Відвідайте нашу сторінку підтримки для допомоги та '
        'поширених запитань.',
  },
  'about': <String, String>{
    'title': 'Про застосунок',
    'feature_home_widgets': '• Віджети головного екрана для мобільних '
        'пристроїв',
    'view_privacy_policy': 'Переглянути Політику конфіденційності',
    'support_description': 'Виникли проблеми? Потрібна допомога або хочете '
        "запропонувати нову функцію? Приєднуйтесь до спільноти або зв'яжіться "
        'з розробником напряму.',
  },
  'privacy': <String, String>{
    'policy_intro': 'Ваша конфіденційність важлива для нас. Політика {appName} '
        'полягає в повазі до вашої конфіденційності та дотриманні всіх чинних '
        'законів і нормативних актів щодо будь-якої особистої інформації, яку '
        'ми можемо збирати про вас, у тому числі в нашому додатку «{appName}» '
        "та пов'язаних з ним сервісах.",
    'information_we_collect': 'Ми збираємо такі дані',
    'no_personal_data_collection': 'Ми не збираємо жодної особистої '
        "інформації, такої як ім'я, адреса електронної пошти або номер "
        'телефону.',
    'third_party_services_info': '«{appName}» використовує сторонні сервіси, '
        'які можуть збирати інформацію, що використовується для вашої '
        'ідентифікації. До таких сервісів належать Firebase Crashlytics та '
        'Google Analytics. Дані, зібрані цими сервісами, використовуються для '
        'покращення стабільності програми та взаємодії з користувачем. Більше '
        'інформації про їхню політику конфіденційності ви можете знайти на '
        'їхніх відповідних веб-сайтах.',
    'consent_agreement': 'Використовуючи наші сервіси, ви погоджуєтеся на збір '
        'та використання вашої інформації, як описано в цій політиці '
        'конфіденційності.',
    'security_measures': 'Заходи безпеки',
    'security_measures_description': 'Ми вживаємо розумних заходів для захисту '
        'вашої інформації від несанкціонованого доступу, розголошення або '
        'зміни.',
    'children_description': 'Наші послуги не призначені для дітей віком до '
        '{age} років. Ми свідомо не збираємо особисту інформацію від дітей '
        'віком до {age} років. Хоча ми прагнемо мінімізувати збір даних, '
        'сторонні сервіси, які ми використовуємо (наприклад, Firebase '
        'Crashlytics та Google Analytics), можуть збирати деякі дані. Однак ці '
        "дані збираються анонімно та не пов'язані з жодною особистою "
        'інформацією. Якщо ви вважаєте, що дитина віком до {age} років надала '
        "нам особисту інформацію, будь ласка, зв'яжіться з нами, і ми "
        'розслідуємо це питання.',
    'crashlytics_description': '«{appName}» використовує Firebase Crashlytics, '
        'сервіс від Google, для анонімного збору звітів про збої, що допомагає '
        'нам покращувати стабільність програми та виправляти помилки. Дані, '
        'зібрані Crashlytics, не містять жодної особистої інформації.',
    'updates_and_notifications_description':
        'Ця політика конфіденційності може періодично оновлюватися. Про '
            'будь-які зміни в політиці вам буде повідомлено через оновлення '
            'програми або сповіщення.',
    'contact_us_invitation':
        'З будь-яких питань або занепокоєнь щодо вашої конфіденційності, ви '
            "можете зв'язатися з нами за наступними контактними даними:",
  },
  'support': <String, String>{
    'title': 'Підтримка',
    'intro_line':
        'Потрібна допомога або бажаєте залишити відгук? Ви у правильному '
            'місці.',
    'contact_intro': 'Якщо у вас виникають проблеми або є пропозиції:',
    'contact_us_via_email_button': "Зв'язатися з нами електронною поштою",
    'join_telegram_support_button': 'Приєднатися до групи підтримки в Telegram',
    'visit_developer_support_website_button':
        'Відвідати сторінку підтримки на сайті розробника',
    'email_default_body': 'Привіт, мені потрібна допомога з...',
  },
};
