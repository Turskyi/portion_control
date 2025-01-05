import 'package:flutter/material.dart';
import 'package:portion_control/ui/home_page.dart';

void main() {
  runApp(const PortionControlApp());
}

class PortionControlApp extends StatelessWidget {
  const PortionControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PortionControl',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}