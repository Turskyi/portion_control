import 'package:flutter/material.dart';
import 'package:portion_control/ui/about/widgets/about_page_content.dart';
import 'package:portion_control/ui/widgets/blurred_app_bar.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';
import 'package:portion_control/ui/widgets/leading_widget.dart';
import 'package:portion_control/ui/widgets/responsive_content.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(_) {
    return const GradientBackgroundScaffold(
      appBar: BlurredAppBar(leading: LeadingWidget(), title: 'About'),
      body: ResponsiveContent(child: AboutPageContent()),
    );
  }
}
