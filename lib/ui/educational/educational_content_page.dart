import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/res/constants/constants.dart' as res;
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:portion_control/ui/widgets/leading_widget.dart';
import 'package:portion_control/ui/widgets/responsive_content.dart';

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
      body: ResponsiveContent(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalIndent,
            MediaQuery.paddingOf(context).top + 72,
            horizontalIndent,
            80.0,
          ),
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
}
