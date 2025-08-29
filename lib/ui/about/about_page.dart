import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/ui/about/widgets/about_page_content.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:portion_control/ui/widgets/leading_widget.dart';
import 'package:portion_control/ui/widgets/responsive_content.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(_) {
    return GradientBackgroundScaffold(
      appBar: BlurredAppBar(
        leading: kIsWeb ? const LeadingWidget() : null,
        title: translate('about_us.title'),
      ),
      body: const ResponsiveContent(child: AboutPageContent()),
    );
  }
}
