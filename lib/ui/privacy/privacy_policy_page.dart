import 'package:flutter/material.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/privacy/widgets/privacy_policy_page_content.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundScaffold(
      appBar: BlurredAppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Material(
              // Ensures the background remains unchanged.
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pushReplacementNamed(
                  AppRoute.home.path,
                ),
                child: Ink.image(
                  image: const AssetImage('${constants.imagePath}logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        title: 'Privacy Policy',
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > constants.wideScreenThreshold) {
            return const Center(
              child: SizedBox(
                // Fixed width for wide screens.
                width: constants.wideScreenContentWidth,
                child: PrivacyPolicyPageContent(),
              ),
            );
          } else {
            // Narrow screen layout.
            return const PrivacyPolicyPageContent();
          }
        },
      ),
    );
  }
}
