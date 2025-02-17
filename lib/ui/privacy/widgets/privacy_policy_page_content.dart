import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPageContent extends StatelessWidget {
  const PrivacyPolicyPageContent({
    super.key,
  });

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
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: headlineSmallFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SelectableText(
            '''
Introduction
              
${constants.appName} respects your privacy and is committed to protecting it. This Privacy Policy explains how we collect, use, and safeguard your data.
              
Information We Collect
              
- Personal Data: We do not collect personally identifiable information.
- Health and Fitness Data: The app stores your body weight and food weight entries locally on your device.
- App Usage Data: We may collect anonymous usage analytics to improve user experience.
              
Data Storage and Security
              
- Your data is stored securely on your device.
- We do not transmit personal data to external servers.
              
Third-Party Services
              
- The app uses Firebase Analytics for anonymous usage insights, compliant with industry standards, and does not include personally identifiable information.
              
Children’s Privacy  
      
- This app is not intended for use by children under 13 years old.  
- We do not specifically design PortionControl for children, as tracking food intake may not be suitable for their growth and nutritional needs.  
- While the app does not collect personal data, it may use Firebase Analytics for anonymous usage insights.  
- Parents and guardians should be aware that this app is intended for adults managing their portion sizes.  
              
User Rights
              
- You can delete your data at any time by uninstalling the app.
- No registration is required to use ${constants.appName}.
              
Changes to This Policy
              
We may update this Privacy Policy as needed. Continued use of the app implies acceptance of any changes.
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
            'If you have any questions or concerns about this Privacy '
            'Policy or your personal data, feel free to contact us at:',
          ),
          Text.rich(
            TextSpan(
              text: 'Email: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
                        scheme: 'mailto',
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
