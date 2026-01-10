import 'dart:io' show Platform;

import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:portion_control/application_services/blocs/home/home_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/application_services/blocs/settings/settings_bloc.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/extensions/build_context_extensions.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/infrastructure/repositories/settings_repository.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/home/widgets/home_page_content.dart';
import 'package:portion_control/ui/menu/animated_drawer.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.localDataSource, super.key});

  final LocalDataSource localDataSource;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FeedbackController? _feedbackController;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    if (kIsWeb) {
      return;
    }

    if (Platform.isAndroid) {
      try {
        final AppUpdateInfo info = await InAppUpdate.checkForUpdate();
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          await InAppUpdate.performImmediateUpdate();
        }
      } catch (e) {
        if (kDebugMode) {
          print('InAppUpdate error: $e');
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    _feedbackController = BetterFeedback.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // Helper for translation.
    String t(String key) => translate(key);
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final double? titleMediumSize = textTheme.titleMedium?.fontSize;
    final ColorScheme colorScheme = theme.colorScheme;
    return GradientBackgroundScaffold(
      drawer: kIsWeb
          ? null
          : BlocListener<MenuBloc, MenuState>(
              listener: _menuStateListener,
              child: AnimatedDrawer(localDataSource: widget.localDataSource),
            ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const HomePageContent(),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: kIsWeb && context.isNarrowScreen
          ? <Widget>[
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: colorScheme.primary),
                onSelected: _handlePopupMenuSelection,
                itemBuilder: (BuildContext _) {
                  final double badgeHeight = 40.0;
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: constants.kLanguageValue,
                      child: Text(t('language')),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: AppRoute.dailyFoodLogHistory.name,
                      child: Text(t('daily_food_log_history.title')),
                    ),
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
                    PopupMenuItem<String>(
                      value: AppRoute.recipes.name,
                      child: Text(t('recipes_page.title')),
                    ),
                    const PopupMenuDivider(),
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
                              splashColor: colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              onTap: _launchGooglePlayUrl,
                              child: Ink.image(
                                image: const AssetImage(
                                  '${constants.imagePath}play_store_badge.png',
                                ),
                                height: badgeHeight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
                              splashColor: colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
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
          : kIsWeb
          ? <Widget>[
              Semantics(
                label: t('language'),
                button: true,
                child: TextButton.icon(
                  onPressed: _showLanguageSelectionDialog,
                  icon: Icon(Icons.language, size: titleMediumSize),
                  label: Text(t('language')),
                ),
              ),
              Semantics(
                label: t('semantic_label.daily_food_log_history'),
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoute.dailyFoodLogHistory.path,
                    );
                  },
                  icon: Icon(Icons.history, size: titleMediumSize),
                  label: Text(t('daily_food_log_history.title')),
                ),
              ),
              Semantics(
                label: translate('semantic_label.privacy_policy_button'),
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoute.privacyPolity.path);
                  },
                  icon: Icon(
                    Icons.privacy_tip,
                    size: titleMediumSize,
                  ),
                  label: Text(translate('button.privacy_policy')),
                ),
              ),
              Semantics(
                label: translate('semantic_label.about_us_button'),
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoute.about.path);
                  },
                  icon: Icon(
                    Icons.group,
                    size: titleMediumSize,
                  ),
                  label: Text(translate('button.about_us')),
                ),
              ),
              Semantics(
                label: translate('semantic_label.recipes_button'),
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoute.recipes.path);
                  },
                  icon: Icon(
                    Icons.restaurant_menu,
                    size: titleMediumSize,
                  ),
                  label: Text(translate('recipes_page.title')),
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
                label: translate('semantic_label.feedback_button'),
                button: true,
                child: TextButton.icon(
                  onPressed: () => _showFeedbackDialog(context),
                  icon: Icon(
                    Icons.feedback,
                    size: Theme.of(context).textTheme.titleMedium?.fontSize,
                  ),
                  label: Text(translate('button.feedback')),
                ),
              ),
            ]
          : null,
    );
  }

  void _handlePopupMenuSelection(String result) {
    if (result == constants.kLanguageValue) {
      _showLanguageSelectionDialog();
    } else if (result == AppRoute.privacyPolity.name) {
      Navigator.pushNamed(context, AppRoute.privacyPolity.path);
    } else if (result == AppRoute.dailyFoodLogHistory.name) {
      Navigator.pushNamed(context, AppRoute.dailyFoodLogHistory.path);
    } else if (result == AppRoute.about.name) {
      Navigator.pushNamed(context, AppRoute.about.path);
    } else if (result == AppRoute.support.name) {
      Navigator.pushNamed(context, AppRoute.support.path);
    } else if (result == AppRoute.recipes.name) {
      Navigator.pushNamed(context, AppRoute.recipes.path);
    } else if (result == constants.googlePlayUrl) {
      launchUrl(
        Uri.parse(constants.googlePlayUrl),
        mode: LaunchMode.externalApplication,
      );
    } else if (result == constants.macOsUrl) {
      launchUrl(
        Uri.parse(constants.macOsUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  void dispose() {
    _feedbackController?.removeListener(_onFeedbackChanged);
    _feedbackController = null;
    super.dispose();
  }

  void _menuStateListener(BuildContext _, MenuState state) {
    if (state is MenuFeedbackState) {
      _showFeedbackUi();
    } else if (state is MenuFeedbackSent) {
      _notifyFeedbackSent();
    }
  }

  void _showFeedbackDialog(BuildContext context) {
    context.read<HomeBloc>().add(const HomeBugReportPressedEvent());
  }

  void _showFeedbackUi() {
    _feedbackController?.show((UserFeedback feedback) {
      context.read<MenuBloc>().add(MenuSubmitFeedbackEvent(feedback: feedback));
    });
    _feedbackController?.addListener(_onFeedbackChanged);
  }

  void _notifyFeedbackSent() {
    BetterFeedback.of(context).hide();
    // Let user know that his feedback is sent.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate('feedback.sent')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onFeedbackChanged() {
    final bool? isVisible = _feedbackController?.isVisible;
    if (isVisible == false) {
      _feedbackController?.removeListener(_onFeedbackChanged);
      context.read<MenuBloc>().add(const MenuClosingFeedbackEvent());
    }
  }

  Future<void> _showLanguageSelectionDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider<SettingsBloc>(
          create: (BuildContext _) {
            return SettingsBloc(SettingsRepository(widget.localDataSource));
          },
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (BuildContext context, SettingsState state) {
              final Language currentLanguage = state.language;
              final TextStyle? headlineMedium = Theme.of(
                context,
              ).textTheme.headlineMedium;
              return AlertDialog(
                title: Text(translate('select_language')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RadioListTile<Language>(
                      title: Text(translate('english')),
                      value: Language.en,
                      groupValue: currentLanguage,
                      secondary: Text(
                        Language.en.flag,
                        style: headlineMedium,
                      ),
                      onChanged: _changeLanguage,
                    ),
                    RadioListTile<Language>(
                      title: Text(translate('ukrainian')),
                      value: Language.uk,
                      groupValue: currentLanguage,
                      secondary: Text(
                        Language.uk.flag,
                        style: headlineMedium,
                      ),
                      onChanged: _changeLanguage,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _changeLanguage(Language? newLanguage) {
    return changeLocale(context, newLanguage?.isoLanguageCode)
    // The returned value is always `null`.
    .then((Object? _) {
      if (mounted && newLanguage != null) {
        context.read<SettingsBloc>().add(
          SettingsChangeLanguageEvent(newLanguage),
        );
        Navigator.pop(context);
      }
    });
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
}
