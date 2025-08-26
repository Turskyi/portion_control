import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/infrastructure/repositories/settings_repository.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/menu/widgets/animated_drawer_item.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimatedDrawer extends StatefulWidget {
  const AnimatedDrawer({
    required this.localDataSource,
    super.key,
  });

  final LocalDataSource localDataSource;

  @override
  State<AnimatedDrawer> createState() => _AnimatedDrawerState();
}

class _AnimatedDrawerState extends State<AnimatedDrawer>
    with SingleTickerProviderStateMixin {
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
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                translate('menu'),
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext _, Widget? child) {
                return Transform.translate(
                  offset: Offset(_slideAnimation.value * 100, 0),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                );
              },
              child: ListView(
                children: <Widget>[
                  AnimatedDrawerItem(
                    icon: Icons.language,
                    text: translate('language'),
                    onTap: _showLanguageSelectionDialog,
                  ),
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
                    icon: Icons.feedback,
                    text: translate('button.feedback'),
                    onTap: () => context
                        .read<MenuBloc>()
                        .add(const BugReportPressedEvent()),
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.support_agent,
                    text: translate('support.title'),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoute.support.path);
                    },
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.web,
                    text: translate('open_web_version'),
                    onTap: () => launchUrl(Uri.parse(constants.baseUrl)),
                  ),
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
    super.dispose();
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider<MenuBloc>(
          create: (BuildContext _) {
            return MenuBloc(SettingsRepository(widget.localDataSource))
              ..add(const LoadingInitialMenuStateEvent());
          },
          child: BlocBuilder<MenuBloc, MenuState>(
            builder: (BuildContext _, MenuState state) {
              final Language currentLanguage = state.language;
              return AlertDialog(
                title: Text(translate('select_language')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RadioListTile<Language>(
                      title: Text(translate('english')),
                      value: Language.en,
                      groupValue: currentLanguage,
                      onChanged: _changeLanguage,
                    ),
                    RadioListTile<Language>(
                      title: const Text('Українська'),
                      value: Language.uk,
                      groupValue: currentLanguage,
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

  void _changeLanguage(Language? newLanguage) {
    changeLocale(context, newLanguage?.isoLanguageCode)
        // The returned value is always `null`.
        .then((Object? _) {
      if (mounted && newLanguage != null) {
        context.read<MenuBloc>().add(ChangeLanguageEvent(newLanguage));
        Navigator.pop(context);
      }
    });
  }
}
