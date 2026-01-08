import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/settings/settings_bloc.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/extensions/build_context_extensions.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/infrastructure/repositories/settings_repository.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/landing/widgets/glowing_animated_box.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({required this.localDataSource, super.key});

  final LocalDataSource localDataSource;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final double? titleMediumSize = textTheme.titleMedium?.fontSize;
    final Color splashColor = colorScheme.primary.withOpacity(
      0.2,
    );
    // Helper for translation.
    String t(String key) => translate(key);
    return GradientBackgroundScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GlowingAnimatedBox(
                onTap: () => Navigator.of(
                  context,
                ).pushReplacementNamed(AppRoute.home.path),
              ),
              const SizedBox(height: 4),
              Text(
                constants.appName,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(
                height: 50,
                child: DefaultTextStyle(
                  style: textTheme.bodyLarge ?? const TextStyle(),
                  child: AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: <AnimatedText>[
                      TypewriterAnimatedText(
                        t('landing_page.animated_text_1'),
                        textStyle: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onBackground,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                      TypewriterAnimatedText(
                        t('landing_page.animated_text_2'),
                        textStyle: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onBackground,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                      TypewriterAnimatedText(
                        t('landing_page.animated_text_3'),
                        textStyle: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onBackground,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _navigateToNextScreen(context),
                child: Text(t('landing_page.get_started_button')),
              ),
            ],
          ),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: context.isNarrowScreen
          ? <Widget>[
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: colorScheme.primary),
                onSelected: (String result) {
                  _onMenuItemSelected(context: context, result: result);
                },
                itemBuilder: (BuildContext _) {
                  final double badgeHeight = 40.0;

                  final bool showGooglePlayLink =
                      kIsWeb || defaultTargetPlatform == TargetPlatform.android;

                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: constants.kLanguageValue,
                      child: Text(t('language')),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: AppRoute.privacyPolity.name,
                      child: Text(t('landing_page.menu_item_privacy_policy')),
                    ),
                    PopupMenuItem<String>(
                      value: AppRoute.about.name,
                      child: Text(t('landing_page.menu_item_about')),
                    ),
                    PopupMenuItem<String>(
                      value: AppRoute.support.name,
                      child: Text(t('landing_page.menu_item_support')),
                    ),
                    const PopupMenuDivider(),
                    if (showGooglePlayLink)
                      PopupMenuItem<String>(
                        value: constants.googlePlayUrl,
                        child: Semantics(
                          label: t('landing_page.semantics_label_google_play'),
                          button: true,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Material(
                              // Ensures the background remains unchanged.
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: splashColor,
                                onTap: _launchGooglePlayUrl,
                                child: Ink.image(
                                  image: const AssetImage(
                                    '${constants.imagePath}'
                                    'play_store_badge.png',
                                  ),
                                  height: badgeHeight,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (kIsWeb ||
                        defaultTargetPlatform != TargetPlatform.android)
                      PopupMenuItem<String>(
                        value: constants.testFlightUrl,
                        child: Semantics(
                          label: t('landing_page.semantics_label_testflight'),
                          button: true,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Material(
                              // Ensures the background remains unchanged.
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: splashColor,
                                onTap: _launchTestFlightUrl,
                                child: Ink.image(
                                  image: const AssetImage(
                                    '${constants.imagePath}'
                                    'test_flight_badge.png',
                                  ),
                                  height: badgeHeight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (kIsWeb ||
                        defaultTargetPlatform == TargetPlatform.macOS ||
                        defaultTargetPlatform == TargetPlatform.iOS)
                      PopupMenuItem<String>(
                        value: constants.macOsUrl,
                        child: Semantics(
                          label: t('landing_page.semantics_label_macos'),
                          button: true,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Material(
                              // Ensures the background remains unchanged.
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: splashColor,
                                onTap: _launchMacOsUrl,
                                child: Ink.image(
                                  image: const AssetImage(
                                    '${constants.imagePath}mac_os_badge.png',
                                  ),
                                  height: badgeHeight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ];
                },
              ),
            ]
          : <Widget>[
              Semantics(
                label: t('language'),
                button: true,
                child: TextButton.icon(
                  onPressed: () => _showLanguageSelectionDialog(context),
                  icon: Icon(Icons.language, size: titleMediumSize),
                  label: Text(t('language')),
                ),
              ),
              Semantics(
                label: t('landing_page.menu_item_privacy_policy'),
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoute.privacyPolity.path);
                  },
                  icon: Icon(Icons.privacy_tip, size: titleMediumSize),
                  label: Text(t('landing_page.menu_item_privacy_policy')),
                ),
              ),
              Semantics(
                label: t('landing_page.menu_item_about'),
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoute.about.path);
                  },
                  icon: Icon(Icons.group, size: titleMediumSize),
                  label: Text(t('landing_page.menu_item_about')),
                ),
              ),
              Semantics(
                label: t('landing_page.menu_item_support'),
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoute.support.path);
                  },
                  icon: Icon(Icons.support_agent, size: titleMediumSize),
                  label: Text(t('landing_page.menu_item_support')),
                ),
              ),
              Semantics(
                label: t('landing_page.semantics_label_google_play'),
                button: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Material(
                    // Ensures the background remains unchanged.
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: splashColor,
                      onTap: _launchGooglePlayUrl,
                      child: Ink.image(
                        image: const AssetImage(
                          '${constants.imagePath}play_store_badge.png',
                        ),
                        height: 72,
                        width: 156,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Semantics(
                label: t('landing_page.semantics_label_macos'),
                button: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Material(
                    // Ensures the background remains unchanged.
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: colorScheme.primary.withOpacity(0.2),
                      onTap: _launchMacOsUrl,
                      child: Ink.image(
                        image: const AssetImage(
                          '${constants.imagePath}mac_os_badge.png',
                        ),
                        height: 72,
                        width: 156,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
    );
  }

  Future<void> _navigateToNextScreen(BuildContext context) {
    final String routeName = localDataSource.isOnboardingCompleted()
        ? AppRoute.home.path
        : AppRoute.onboarding.path;
    return Navigator.of(context).pushNamed<void>(routeName);
  }

  void _onMenuItemSelected({
    required BuildContext context,
    required String result,
  }) {
    if (result == constants.kLanguageValue) {
      _showLanguageSelectionDialog(context);
    } else if (result == AppRoute.privacyPolity.name) {
      Navigator.pushNamed(context, AppRoute.privacyPolity.path);
    } else if (result == AppRoute.about.name) {
      Navigator.pushNamed(context, AppRoute.about.path);
    } else if (result == AppRoute.support.name) {
      Navigator.pushNamed(context, AppRoute.support.path);
    } else if (result == constants.googlePlayUrl) {
      launchUrl(
        Uri.parse(constants.googlePlayUrl),
        mode: LaunchMode.externalApplication,
      );
    } else if (result == constants.testFlightUrl) {
      launchUrl(
        Uri.parse(constants.testFlightUrl),
        mode: LaunchMode.externalApplication,
      );
    } else if (result == constants.macOsUrl) {
      launchUrl(
        Uri.parse(constants.macOsUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<bool> _launchMacOsUrl() {
    return launchUrl(
      Uri.parse(constants.macOsUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<bool> _launchGooglePlayUrl() {
    return launchUrl(
      Uri.parse(constants.googlePlayUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<bool> _launchTestFlightUrl() {
    return launchUrl(
      Uri.parse(constants.testFlightUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _showLanguageSelectionDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider<SettingsBloc>(
          create: (BuildContext _) {
            return SettingsBloc(SettingsRepository(localDataSource));
          },
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (BuildContext context, SettingsState state) {
              final Language currentLanguage = state.language;
              final TextStyle? headlineMedium = Theme.of(
                context,
              ).textTheme.headlineMedium;
              final double horizontalPadding = 12.0;
              return AlertDialog(
                title: Text(translate('select_language')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: Language.values.map((Language language) {
                    return RadioListTile<Language>(
                      title: Text(translate(language.key)),
                      value: language,
                      groupValue: currentLanguage,
                      secondary: Text(
                        language.flag,
                        style: headlineMedium,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      onChanged: (Language? newLanguage) {
                        if (newLanguage != null) {
                          _changeLanguage(
                            context: context,
                            newLanguage: newLanguage,
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _changeLanguage({
    required BuildContext context,
    required Language newLanguage,
  }) {
    return changeLocale(context, newLanguage.isoLanguageCode)
    // The returned value is always `null`.
    .then((Object? _) {
      if (context.mounted) {
        context.read<SettingsBloc>().add(
          SettingsChangeLanguageEvent(newLanguage),
        );
        Navigator.pop(context);
      }
    });
  }
}
