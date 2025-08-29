import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/env/env.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:portion_control/router/app_route.dart';
import 'package:portion_control/router/navigator.dart';
import 'package:resend/resend.dart';

class App extends StatelessWidget {
  const App({required this.routeMap, super.key});

  final Map<String, WidgetBuilder> routeMap;

  @override
  Widget build(BuildContext context) {
    Resend(apiKey: Env.resendApiKey);
    final LocalizationDelegate localizationDelegate =
        LocalizedApp.of(context).delegate;
    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
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
        initialRoute: kIsWeb ? AppRoute.landing.path : AppRoute.home.path,
        routes: routeMap,
      ),
    );
  }
}
