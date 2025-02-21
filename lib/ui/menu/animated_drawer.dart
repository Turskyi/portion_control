import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/menu/widgets/animated_drawer_item.dart';

class AnimatedDrawer extends StatefulWidget {
  const AnimatedDrawer({super.key});

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
                'Menu',
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
              builder: (BuildContext context, Widget? child) {
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
                    icon: Icons.privacy_tip,
                    text: 'Privacy Policy',
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoute.privacyPolity.path,
                    ),
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.group,
                    text: 'About Us',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoute.about.path),
                  ),
                  AnimatedDrawerItem(
                    icon: Icons.feedback,
                    text: 'Feedback',
                    onTap: () => context
                        .read<MenuBloc>()
                        .add(const BugReportPressedEvent()),
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
}
