import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portion_control/di/dependencies_scope.dart';
import 'package:portion_control/env/env.dart';
import 'package:portion_control/res/colors/gradients.dart';
import 'package:portion_control/res/colors/material_colors.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/res/resources.dart';
import 'package:portion_control/router/navigator.dart';
import 'package:resend/resend.dart';

class App extends StatelessWidget {
  const App({
    required this.routeMap,
    super.key,
  });

  final Map<String, WidgetBuilder> routeMap;

  @override
  Widget build(BuildContext context) {
    Resend(apiKey: Env.resendApiKey);
    final LocalizationDelegate localizationDelegate = LocalizedApp.of(
      context,
    ).delegate;

    final String initialRoute = DependenciesScope.of(context).initialRoute;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: Resources(
        colors: const MaterialColors(),
        gradients: const Gradients(),
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: constants.appName,
          localizationsDelegates: <LocalizationsDelegate<Object>>[
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            localizationDelegate,
          ],
          supportedLocales: localizationDelegate.supportedLocales,
          locale: localizationDelegate.currentLocale,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.comfortaaTextTheme(),
            colorScheme: ColorScheme.fromSeed(
              // Seed color for the palette.
              seedColor: const Color(0xFFE99CBF),
              // Override primary color (border outline, input label).
              primary: Colors.pinkAccent,
              // Background gradient center.
              background: const Color(0xFFFFF0F5),
              // Background gradient edge.
              secondary: const Color(0xFFD47A9B),
            ),
          ),
          initialRoute: initialRoute,
          routes: routeMap,
        ),
      ),
    );
  }
}
