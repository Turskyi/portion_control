import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:home_widget/home_widget.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/menu/reminder_dialog.dart';
import 'package:portion_control/ui/menu/widgets/animated_drawer_item.dart';

class AnimatedDrawer extends StatefulWidget {
  const AnimatedDrawer({required this.localDataSource, super.key});

  final LocalDataSource localDataSource;

  @override
  State<AnimatedDrawer> createState() => _AnimatedDrawerState();
}

class _AnimatedDrawerState extends State<AnimatedDrawer>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _isRequestPinWidgetSupported = ValueNotifier<bool>(
    false,
  );
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _checkPinability();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    translate('menu'),
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  BlocBuilder<MenuBloc, MenuState>(
                    builder: (BuildContext context, MenuState state) {
                      if (state is LoadingMenuState) {
                        return SizedBox(
                          height: textTheme.bodyMedium?.fontSize,
                          width: textTheme.bodyMedium?.fontSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        );
                      } else {
                        final int streakDays = state.streakDays;
                        // The `flutter_translate` package automatically handles
                        // pluralization rules based on the provided numeric
                        // value.
                        // When `streakDays` is 0, it correctly maps to the
                        // "zero" key in the localization files without needing
                        // explicit handling in the code.
                        final String streakText = translatePlural(
                          'streak',
                          streakDays,
                          args: <String, Object?>{'count': streakDays},
                        );
                        return Text(
                          streakText,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.85),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext _, Widget? child) {
                return Transform.translate(
                  offset: Offset(_slideAnimation.value * 100, 0),
                  child: Opacity(opacity: _fadeAnimation.value, child: child),
                );
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  AnimatedDrawerItem(
                    icon: Icons.privacy_tip,
                    text: translate('privacy_policy.title'),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoute.privacyPolity.path);
                    },
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.group,
                    text: translate('about_us.title'),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoute.about.path);
                    },
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.support_agent,
                    text: translate('support.title'),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoute.support.path);
                    },
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.menu_book,
                    text: translate('recipes_page.title'),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoute.recipes.path);
                    },
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.school,
                    text: translate('educational_content.title'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoute.educationalContent.path,
                      );
                    },
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.history,
                    text: translate('daily_food_log_history.title'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoute.dailyFoodLogHistory.path,
                      );
                    },
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.bar_chart,
                    text: translate('stats.title'),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoute.stats.path);
                    },
                  ),
                  const Divider(),
                  AnimatedDrawerItem(
                    icon: Icons.language,
                    text: translate('language'),
                    onTap: _showLanguageSelectionDialog,
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.notifications,
                    text: translate('reminders.title'),
                    onTap: _showRemindersDialog,
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.feedback,
                    text: translate('button.feedback'),
                    onTap: () => context.read<MenuBloc>().add(
                      const BugReportPressedEvent(),
                    ),
                  ),
                  // Only add the event if it's NOT web AND NOT macOS.
                  // For context, see issue:
                  // https://github.com/ABausG/home_widget/issues/137.
                  if (!kIsWeb && !Platform.isMacOS)
                    ValueListenableBuilder<bool>(
                      valueListenable: _isRequestPinWidgetSupported,
                      builder: (BuildContext context, bool isSupported, _) {
                        if (isSupported) {
                          return AnimatedDrawerItem(
                            icon: Icons.widgets_outlined,
                            text: translate('pin_widget'),
                            onTap: _pinWidget,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  if (!kIsWeb)
                    AnimatedDrawerItem(
                      icon: Icons.web,
                      text: translate('open_web_version'),
                      onTap: _openWebVersion,
                    ),
                  const Divider(),
                  BlocBuilder<MenuBloc, MenuState>(
                    builder: (BuildContext context, MenuState state) {
                      if (state is LoadingMenuState) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          '${translate('app_version')}: ${state.appVersion}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _isRequestPinWidgetSupported.dispose();
    super.dispose();
  }

  Future<void> _showRemindersDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) {
        return ReminderDialog(
          localDataSource: widget.localDataSource,
        );
      },
    );
  }

  void _openWebVersion() {
    context.read<MenuBloc>().add(const OpenWebVersionEvent());
  }

  void _pinWidget() {
    context.read<MenuBloc>().add(const PinWidgetEvent());
  }

  Future<void> _showLanguageSelectionDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) {
        return BlocBuilder<MenuBloc, MenuState>(
          builder: (BuildContext context, MenuState state) {
            final Language currentLanguage = state.language;
            final TextStyle? headlineMedium = Theme.of(
              context,
            ).textTheme.headlineMedium;
            final double horizontalPadding = 8.0;
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
                    onChanged: _changeLanguage,
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _changeLanguage(Language? newLanguage) {
    return changeLocale(context, newLanguage?.isoLanguageCode)
    // The returned value is always `null`.
    .then((Object? _) {
      if (mounted && newLanguage != null) {
        context.read<MenuBloc>().add(ChangeLanguageEvent(newLanguage));
        Navigator.pop(context);
      }
    });
  }

  Future<void> _checkPinability() async {
    try {
      final bool? isRequestPinWidgetSupported =
          await HomeWidget.isRequestPinWidgetSupported();

      if (mounted) {
        _isRequestPinWidgetSupported.value =
            isRequestPinWidgetSupported ?? false;
      }
    } catch (e, s) {
      debugPrint(
        '''
        Error checking widget pinning support in `AnimatedDrawer` 
        ($runtimeType): $e. This might happen on platforms where 
        `HomeWidget.isRequestPinWidgetSupported()` is not implemented or fails. 
        Defaulting to not showing the "Pin Widget" option.
        Stacktrace: $s
        ''',
      );
      if (mounted) {
        _isRequestPinWidgetSupported.value = false;
      }
    }
  }
}
