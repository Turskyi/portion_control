import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.titleKey,
    required this.contentKey,
    this.imageAsset,
    this.isAnimated = false,
    super.key,
  });

  final String titleKey;
  final String contentKey;
  final String? imageAsset;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final String? localImageAsset = imageAsset;

    Widget titleWidget;
    Widget contentWidget;

    if (isAnimated) {
      titleWidget = AnimatedTextKit(
        totalRepeatCount: 1,
        animatedTexts: <AnimatedText>[
          TypewriterAnimatedText(
            translate(titleKey),
            textStyle: textTheme.headlineSmall,
            textAlign: TextAlign.center,
            speed: const Duration(milliseconds: 100),
          ),
        ],
      );
      contentWidget = AnimatedTextKit(
        totalRepeatCount: 1,
        animatedTexts: <AnimatedText>[
          TypewriterAnimatedText(
            translate(contentKey),
            textStyle: textTheme.bodyLarge,
            textAlign: TextAlign.center,
            speed: const Duration(milliseconds: 50),
          ),
        ],
      );
    } else {
      titleWidget = Text(
        translate(titleKey),
        style: textTheme.headlineSmall,
        textAlign: TextAlign.center,
      );
      contentWidget = Text(
        translate(contentKey),
        style: textTheme.bodyLarge,
        textAlign: TextAlign.center,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (localImageAsset != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    localImageAsset,
                    height: 180,
                  ),
                ),
              ),
            titleWidget,
            const SizedBox(height: 16),
            contentWidget,
          ],
        ),
      ),
    );
  }
}
