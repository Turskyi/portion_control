import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/about/widgets/about_us_page_content.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
                  kIsWeb ? AppRoute.landing.path : AppRoute.home.path,
                ),
                child: Ink.image(
                  image: const AssetImage('${constants.imagePath}logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        title: 'About Us',
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > constants.wideScreenThreshold) {
            return const Center(
              child: SizedBox(
                // Fixed width for wide screens.
                width: constants.wideScreenContentWidth,
                child: AboutUsPageContent(),
              ),
            );
          } else {
            // Narrow screen layout.
            return const AboutUsPageContent();
          }
        },
      ),
    );
  }
}
