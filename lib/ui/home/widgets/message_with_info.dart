import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/ui/widgets/safety_limits_dialog.dart';

class MessageWithInfo extends StatelessWidget {
  const MessageWithInfo({
    required this.text,
    this.style,
    super.key,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: style,
        children: <InlineSpan>[
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              onPressed: () => _showSafetyLimitsDialog(context),
              tooltip: translate('educational_content.safety_limits_tooltip'),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.only(left: 4.0),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSafetyLimitsDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) => const SafetyLimitsDialog(),
    );
  }
}
