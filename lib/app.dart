import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portion_control/router/app_route.dart';

class App extends StatelessWidget {
  const App({required this.routeMap, super.key});

  final Map<String, WidgetBuilder> routeMap;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PortionControl',
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
    );
  }
}
