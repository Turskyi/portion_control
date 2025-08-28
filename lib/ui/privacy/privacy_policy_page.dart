import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/ui/privacy/widgets/privacy_policy_page_content.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:portion_control/ui/widgets/leading_widget.dart';
import 'package:portion_control/ui/widgets/responsive_content.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext _) {
    return GradientBackgroundScaffold(
      appBar: BlurredAppBar(
        leading: const LeadingWidget(),
        title: translate('privacy_policy.title'),
      ),
      body: const ResponsiveContent(child: PrivacyPolicyPageContent()),
    );
  }
}
