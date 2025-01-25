import 'package:flutter/material.dart';
import 'package:portion_control/ui/home_page.dart';

class PortionControlApp extends StatelessWidget {
  const PortionControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PortionControl',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE99CBF)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
