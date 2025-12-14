import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPageContent extends StatelessWidget {
  const PrivacyPolicyPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Color linkColor = themeData.colorScheme.primary;
    final TextTheme textTheme = themeData.textTheme;
    final double? titleMediumFontSize = textTheme.titleMedium?.fontSize;
    final double? titleLargeFontSize = textTheme.titleLarge?.fontSize;

    final Map<String, Style> htmlStyles = <String, Style>{
      'p': Style(fontSize: FontSize(titleMediumFontSize ?? 16.0)),
      'li': Style(fontSize: FontSize(titleMediumFontSize ?? 16.0)),
      'b': Style(fontWeight: FontWeight.bold),
    };

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        constants.kHorizontalIndent,
        MediaQuery.paddingOf(context).top,
        constants.kHorizontalIndent,
        80.0,
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SelectionArea(
            child: Html(
              data: translate(
                'privacy_policy.content_html',
                args: <String, Object?>{'appName': constants.appName},
              ),
              style: htmlStyles,
            ),
          ),
          Text(
            translate('contact_us.title'),
            style: TextStyle(
              fontSize: titleLargeFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            translate('privacy_policy.contact_us_prompt'),
            style: TextStyle(fontSize: titleMediumFontSize),
          ),
          Text.rich(
            TextSpan(
              text: translate('contact_us.email_label'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleMediumFontSize,
              ),
              children: <InlineSpan>[
                TextSpan(
                  text: 'privacy@${constants.companyDomain}',
                  style: TextStyle(
                    color: linkColor,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      final Uri emailLaunchUri = Uri(
                        scheme: constants.mailToScheme,
                        path: 'privacy@${constants.companyDomain}',
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
