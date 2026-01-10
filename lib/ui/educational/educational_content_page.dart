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

class EducationalContentPage extends StatelessWidget {
  const EducationalContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double horizontalIndent = 16.0;
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    return GradientBackgroundScaffold(
      appBar: BlurredAppBar(
        leading: kIsWeb ? const LeadingWidget() : null,
        title: translate('educational_content.title'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          horizontalIndent,
          MediaQuery.paddingOf(context).top + 72,
          horizontalIndent,
          80.0,
        ),
        child: ResponsiveContent(
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                translate('educational_content.what_is_portion_control_title'),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          translate('educational_content.disclaimer_short'),
                          style: textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: translate(
                          'educational_content.disclaimer_more_info_tooltip',
                        ),
                        onPressed: () => _showFullDisclaimerDialog(context),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                translate(
                  'educational_content.what_is_portion_control_content',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                translate('educational_content.why_grams_title'),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(translate('educational_content.why_grams_content')),
              const SizedBox(height: 12),
              Text(
                translate('educational_content.how_to_weigh_title'),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(translate('educational_content.how_to_weigh_content')),
              const SizedBox(height: 16),
              Text(
                translate('educational_content.note_title'),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SelectableText(
                translate(
                  'educational_content.note_content',
                  args: <String, Object?>{'appName': res.appName},
                ),
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                translate('educational_content.high_calorie_title'),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SelectionArea(
                child: Text(translate('educational_content.high_calorie_list')),
              ),
              const SizedBox(height: 12),
              Text(
                translate('educational_content.low_calorie_title'),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(translate('educational_content.low_calorie_list')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFullDisclaimerDialog(BuildContext context) {
    final Uri whoUri = Uri.parse(
      translate('health_sources.who_url'),
    );
    final Uri cdcUri = Uri.parse(
      translate('health_sources.cdc_url'),
    );
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            translate(
              'educational_content.disclaimer_full_title',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium,
                    children: <InlineSpan>[
                      TextSpan(
                        text:
                            '${translate(
                              'educational_content.disclaimer_full',
                            )} ',
                      ),
                      TextSpan(
                        text: translate(
                          'health_sources.who',
                        ),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                            whoUri,
                            mode: LaunchMode.externalApplication,
                          ),
                      ),
                      const TextSpan(text: ' · '),
                      TextSpan(
                        text: translate(
                          'health_sources.cdc',
                        ),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                            cdcUri,
                            mode: LaunchMode.externalApplication,
                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(
                MaterialLocalizations.of(
                  context,
                ).closeButtonLabel,
              ),
            ),
          ],
        );
      },
    );
  }
}
