import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:url_launcher/url_launcher.dart';

class AboutUsPageContent extends StatelessWidget {
  const AboutUsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final double horizontalIndent = 16.0;
    final ThemeData themeData = Theme.of(context);
    final Color linkColor = themeData.colorScheme.primary;
    final TextTheme textTheme = themeData.textTheme;
    final double? headlineSmallFontSize = textTheme.headlineSmall?.fontSize;
    final double? titleMediumFontSize = textTheme.titleMedium?.fontSize;
    final double? titleLargeFontSize = textTheme.titleLarge?.fontSize;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalIndent,
        MediaQuery.of(context).padding.top + 18,
        horizontalIndent,
        80.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'About Us',
            style: TextStyle(
              fontSize: headlineSmallFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            '''
The idea for ${constants.appName} was sparked by a simple ChatGPT prompt: "Fill the gap. To lose weight, forget about eating the __ for at least one year." The response? "To lose weight, forget about eating the wrong portions for at least one year." That sentence resonated deeply.

Around the same time, our Bengal cat, Bella, had a vet visit. The verdict? She had "gotten rounded." Our solution was simple: we adjusted her automatic feeder to dispense smaller portions. It worked for Bella — but could a similar approach work for people?

Obviously, humans aren't cats, and we don’t eat the same thing every day. However, from experience, I noticed that when people overeat, they often do so with foods they’re familiar with. When trying something new, portions tend to be smaller. This observation led to an idea: What if portion control alone could help maintain a healthy weight without the need for complex diets?

Theoretically, if someone stopped eating altogether and only drank water, they would lose weight—but that’s neither healthy nor sustainable. On the flip side, eating without restraint often leads to weight gain. I had already experienced this cycle: my wife and I followed a diet prescribed by a nutritionist, carefully weighing our portions. We lost weight — but as soon as we stopped following the program, the weight returned. The problem wasn’t just what we ate, but how much.

That’s when the idea for ${constants.appName} took shape. What if I created a mobile app where users could enter their height, weight, and the weight of the food they consume each time they eat? The app could calculate a recommended daily food intake in grams — enough to prevent weight gain while still being sustainable. By tracking daily weight measurements, the app could adjust recommendations dynamically. If weight starts creeping up, the app lowers the recommended intake.

Unlike calorie counting, ${constants.appName} simplifies the process. No need to track complex nutritional values, hunt for specific ingredients, or cook elaborate meals. Just start small — control portions, track progress, and find balance.

Welcome to ${constants.appName} — the practical approach to mindful eating.
            ''',
            style: TextStyle(fontSize: titleMediumFontSize),
          ),
          const SizedBox(height: 24),
          Text(
            'Contact Us',
            style: TextStyle(
              fontSize: titleLargeFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'For any questions or feedback, feel free to contact us at:',
          ),
          Text.rich(
            TextSpan(
              text: 'Email: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
              children: <InlineSpan>[
                TextSpan(
                  text: 'support@${constants.companyDomain}',
                  style: TextStyle(
                    color: linkColor,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'support@${constants.companyDomain}',
                      );
                      launchUrl(emailLaunchUri);
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
