import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:portion_control/ui/widgets/leading_widget.dart';
import 'package:portion_control/ui/widgets/responsive_content.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double horizontalIndent = 16.0;
    final ThemeData themeData = Theme.of(context);
    final Color linkColor = themeData.colorScheme.primary;
    final TextTheme textTheme = themeData.textTheme;
    final double? titleMediumFontSize = textTheme.titleMedium?.fontSize;
    final double? titleLargeFontSize = textTheme.titleLarge?.fontSize;
    return GradientBackgroundScaffold(
      appBar: const BlurredAppBar(
        leading: kIsWeb ? LeadingWidget() : null,
        title: 'Support',
      ),
      body: ResponsiveContent(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalIndent,
            MediaQuery.of(context).padding.top + 72,
            horizontalIndent,
            80.0,
          ),
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SelectableText(
                '''
Welcome to the ${constants.appName} support page. Here you’ll find information to help you use the app effectively and troubleshoot common issues.

About the App

 ${constants.appName} helps users track their food intake in grams and body weight in kilograms to support mindful eating and avoid unnecessary weight gain.

Getting Started

- Log your height and daily weight.
- Use a food scale to log each meal in grams.
- The app will suggest portion guidelines to help you manage your intake.

Common Questions

- Q: Is my data synced or backed up?
  A: No, all data is stored locally on your device.

- Q: I forgot to log a meal. What should I do?
  A: While the app allows you to edit or add missed meals later, we strongly recommend choosing to start the day from scratch. Accurate tracking is essential for building a reliable portion control baseline, and incomplete records can lead to misleading results.

- Q: Is this app suitable for children?
  A: No. This app is designed for adults.

- Q: Does the app count calories?
  A: No. This app tracks food weight in grams, not calories.

Need Help?

If you have issues or questions not covered here, feel free to reach out.
''',
                style: TextStyle(fontSize: titleMediumFontSize),
              ),
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: titleLargeFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'For further assistance or to report a problem, '
                'you can reach out through any of the following channels:',
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
              Text.rich(
                TextSpan(
                  text: 'Telegram Group: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Join the community chat',
                      style: TextStyle(
                        color: linkColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(
                            Uri.parse('https://t.me/+Zmd6QYP3iXc2MjZi'),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Developer Website: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'https://turskyi.com/#/support',
                      style: TextStyle(
                        color: linkColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(
                            Uri.parse('https://turskyi.com/#/support'),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
