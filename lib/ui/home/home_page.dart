import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/ui/home/widgets/home_page_content.dart';
import 'package:portion_control/ui/widgets/gradient_background_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundScaffold(
      body: LayoutBuilder(
        builder: (_, BoxConstraints constraints) {
          if (constraints.maxWidth > constants.wideScreenThreshold) {
            // Wide screen layout.
            return const Center(
              child: SizedBox(
                // Fixed width for wide screens.
                width: constants.wideScreenContentWidth,
                child: HomePageContent(),
              ),
            );
          } else {
            // Narrow screen layout.
            return const HomePageContent();
          }
        },
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: <Widget>[
        if (kIsWeb)
          Semantics(
            label: 'Privacy Policy',
            button: true,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoute.privacyPolity.path);
              },
              icon: Icon(
                Icons.privacy_tip,
                size: Theme.of(context).textTheme.titleMedium?.fontSize,
              ),
              label: const Text('Privacy Policy'),
            ),
          ),
      ],
    );
  }
}
