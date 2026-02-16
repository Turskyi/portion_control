import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/ui/widgets/safety_limit_detail.dart';

class SafetyLimitsDialog extends StatelessWidget {
  const SafetyLimitsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(translate('educational_content.safety_limits_title')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(translate('educational_content.safety_limits_intro')),
            const SizedBox(height: 16),
            SafetyLimitDetail(
              title: translate('educational_content.max_limit_title'),
              content: translate('educational_content.max_limit_content'),
            ),
            const SizedBox(height: 12),
            SafetyLimitDetail(
              title: translate('educational_content.safe_min_limit_title'),
              content: translate('educational_content.safe_min_limit_content'),
            ),
            const SizedBox(height: 12),
            SafetyLimitDetail(
              title: translate('educational_content.absolute_min_limit_title'),
              content: translate(
                'educational_content.absolute_min_limit_content',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(translate('button.close')),
        ),
      ],
    );
  }
}
