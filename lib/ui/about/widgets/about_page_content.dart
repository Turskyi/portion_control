import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/res/constants/constants.dart' as res;
import 'package:url_launcher/url_launcher.dart';

class AboutPageContent extends StatelessWidget {
  const AboutPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Color linkColor = themeData.colorScheme.primary;
    final TextTheme textTheme = themeData.textTheme;
    final double? titleMediumFontSize = textTheme.titleMedium?.fontSize;
    final double? titleLargeFontSize = textTheme.titleLarge?.fontSize;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        res.kHorizontalIndent,
        MediaQuery.paddingOf(context).top + 12.0,
        res.kHorizontalIndent,
        80.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SelectableText(
            translate(
              'about_us.story',
              args: <String, Object?>{'appName': res.appName},
            ),
            style: TextStyle(fontSize: titleMediumFontSize),
          ),
          const SizedBox(height: 24),
          Text(
            translate('contact_us.title'),
            style: TextStyle(
              fontSize: titleLargeFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(translate('contact_us.intro')),
          Text.rich(
            TextSpan(
              text: translate('contact_us.email_label'),
              style: const TextStyle(fontWeight: FontWeight.bold),
              children: <InlineSpan>[
                TextSpan(
                  text: '${res.supportEmailPrefix}${res.companyDomain}',
                  style: TextStyle(
                    color: linkColor,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _launchEmailClient,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchEmailClient() {
    final Uri emailLaunchUri = Uri(
      scheme: res.mailToScheme,
      path: '${res.supportEmailPrefix}${res.companyDomain}',
    );
    launchUrl(emailLaunchUri);
  }
}
