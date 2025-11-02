import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/res/constants/constants.dart' as res;
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
      appBar: BlurredAppBar(
        leading: kIsWeb ? const LeadingWidget() : null,
        title: translate('support_page.title'),
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
                _mainSupportText,
                style: TextStyle(fontSize: titleMediumFontSize),
              ),
              Text(
                translate('support_page.contact_us_title'),
                style: TextStyle(
                  fontSize: titleLargeFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(translate('support_page.contact_us_intro')),
              Text.rich(
                TextSpan(
                  text: translate('support_page.email_label'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  children: <InlineSpan>[
                    TextSpan(
                      text: '${res.supportEmailPrefix}${res.companyDomain}',
                      style: TextStyle(
                        color: linkColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          final Uri emailLaunchUri = Uri(
                            scheme: res.mailToScheme,
                            path:
                                '${res.supportEmailPrefix}${res.companyDomain}',
                          );
                          launchUrl(emailLaunchUri);
                        },
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: translate('support_page.telegram_label'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  children: <InlineSpan>[
                    TextSpan(
                      text: translate('support_page.telegram_link_text'),
                      style: TextStyle(
                        color: linkColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _launchTelegramUrl,
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: translate('support_page.developer_website_label'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  children: <InlineSpan>[
                    TextSpan(
                      text: translate(
                        'support_page.developer_website_link_text',
                      ),
                      style: TextStyle(
                        color: linkColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(
                            Uri.parse(
                              translate(
                                'support_page.developer_website_link_text',
                              ),
                            ),
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

  void _launchTelegramUrl() {
    launchUrl(Uri.parse(res.telegramUrl), mode: LaunchMode.externalApplication);
  }

  // Helper getter to create the main text content to avoid repetition.
  String get _mainSupportText {
    return '''
${translate('support_page.welcome_message', args: <String, Object?>{'appName': res.appName})}

${translate('support_page.about_app_title')}

 ${translate('support_page.about_app_content', args: <String, Object?>{'appName': res.appName})}

${translate('support_page.getting_started_title')}

${translate('support_page.getting_started_item1')}
${translate('support_page.getting_started_item2')}
${translate('support_page.getting_started_item3')}

${translate('support_page.common_questions_title')}

${translate('support_page.faq1_data_sync')}

${translate('support_page.faq2_forgot_meal')}

${translate('support_page.faq3_children')}

${translate('support_page.faq4_calories')}

${translate('support_page.need_help_title')}

${translate('support_page.need_help_content')}
''';
  }
}
