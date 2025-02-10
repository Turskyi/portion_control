import 'package:flutter/material.dart';
import 'package:portion_control/ui/home/widgets/home_page_content.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundScaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600) {
            // Wide screen layout.
            return const Center(
              child: SizedBox(
                // Fixed width for wide screens.
                width: 800,
                child: HomePageContent(),
              ),
            );
          } else {
            // Narrow screen layout.
            return const HomePageContent();
          }
        },
      ),
    );
  }
}
