import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return GradientBackgroundScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  // Glowing border.
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushReplacementNamed(
                        AppRoute.home.path,
                      ),
                      child: Ink.image(
                        image: const AssetImage(
                          '${constants.imagePath}logo.png',
                        ),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'PortionControl',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
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
      persistentFooterButtons: <Widget>[
        Semantics(
          label: 'Privacy Policy',
          button: true,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoute.privacyPolity.path);
            },
            icon: Icon(
              Icons.privacy_tip,
              size: Theme.of(context).textTheme.titleMedium?.fontSize,
            ),
            label: const Text('Privacy Policy'),
          ),
        ),
      ],
    );
  }
}
