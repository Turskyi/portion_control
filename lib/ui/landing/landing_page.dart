import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/landing/widgets/glowing_animated_box.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final double? titleMediumSize = textTheme.titleMedium?.fontSize;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 600;
    return GradientBackgroundScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GlowingAnimatedBox(
                onTap: () => Navigator.of(context).pushReplacementNamed(
                  AppRoute.home.path,
                ),
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
                height: 50, // Fixed height for animated text
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyLarge ??
                      const TextStyle(),
                  child: AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: <AnimatedText>[
                      TypewriterAnimatedText(
                        'Track your food portions with ease.',
                        textStyle: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onBackground,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                      TypewriterAnimatedText(
                        'No calorie counting, just simple portion control.',
                        textStyle: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onBackground,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                      TypewriterAnimatedText(
                        'See your progress over time.',
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
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoute.home.path);
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: isNarrowScreen
          ? <Widget>[
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: colorScheme.primary),
                onSelected: (String result) {
                  if (result == AppRoute.privacyPolity.name) {
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
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: AppRoute.privacyPolity.name,
                    child: const Text('Privacy Policy'),
                  ),
                  PopupMenuItem<String>(
                    value: AppRoute.about.name,
                    child: const Text('About'),
                  ),
                  PopupMenuItem<String>(
                    value: AppRoute.support.name,
                    child: const Text('Support'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: constants.googlePlayUrl,
                    child: Semantics(
                      label: 'Google Play Store',
                      button: true,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Material(
                          // Ensures the background remains unchanged.
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: colorScheme.primary.withOpacity(0.2),
                            onTap: () {
                              launchUrl(
                                Uri.parse(constants.googlePlayUrl),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Ink.image(
                              image: const AssetImage(
                                '${constants.imagePath}play_store_badge.png',
                              ),
                              height: 40,
                              // height: 72,
                              // width: 156,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: constants.testFlightUrl,
                    child: Semantics(
                      label: 'TestFlight',
                      button: true,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Material(
                          // Ensures the background remains unchanged.
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: colorScheme.primary.withOpacity(0.2),
                            onTap: () {
                              launchUrl(
                                Uri.parse(constants.testFlightUrl),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Ink.image(
                              image: const AssetImage(
                                '${constants.imagePath}test_flight_badge.png',
                              ),
                              height: 40,
                              // width: 140,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: constants.macOsUrl,
                    child: Semantics(
                      label: 'MacOS',
                      button: true,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Material(
                          // Ensures the background remains unchanged.
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: colorScheme.primary.withOpacity(0.2),
                            onTap: () {
                              launchUrl(
                                Uri.parse(constants.macOsUrl),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Ink.image(
                              image: const AssetImage(
                                '${constants.imagePath}mac_os_badge.png',
                              ),
                              height: 40,
                              // width: 140,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ]
          : <Widget>[
              Semantics(
                label: 'Privacy Policy',
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoute.privacyPolity.path);
                  },
                  icon: Icon(
                    Icons.privacy_tip,
                    size: titleMediumSize,
                  ),
                  label: const Text('Privacy Policy'),
                ),
              ),
              Semantics(
                label: 'About',
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoute.about.path);
                  },
                  icon: Icon(
                    Icons.group,
                    size: titleMediumSize,
                  ),
                  label: const Text('About'),
                ),
              ),
              Semantics(
                label: 'Support',
                button: true,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoute.support.path);
                  },
                  icon: Icon(
                    Icons.support_agent,
                    size: titleMediumSize,
                  ),
                  label: const Text('Support'),
                ),
              ),
              Semantics(
                label: 'Google Play Store',
                button: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Material(
                    // Ensures the background remains unchanged.
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: colorScheme.primary.withOpacity(0.2),
                      onTap: () {
                        launchUrl(
                          Uri.parse(constants.googlePlayUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
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
                label: 'TestFlight',
                button: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Material(
                    // Ensures the background remains unchanged.
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: colorScheme.primary.withOpacity(0.2),
                      onTap: () {
                        launchUrl(
                          Uri.parse(constants.testFlightUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Ink.image(
                        image: const AssetImage(
                          '${constants.imagePath}test_flight_badge.png',
                        ),
                        height: 40,
                        width: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Semantics(
                label: 'MacOS',
                button: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Material(
                    // Ensures the background remains unchanged.
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: colorScheme.primary.withOpacity(0.2),
                      onTap: () {
                        launchUrl(
                          Uri.parse(constants.macOsUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Ink.image(
                        image: const AssetImage(
                          '${constants.imagePath}mac_os_badge.png',
                        ),
                        height: 40,
                        width: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
    );
  }
}
