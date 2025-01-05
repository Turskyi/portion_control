import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PortionControl'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Enter Your Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Text Field for Body Weight
            InputRow(unit: 'kg'),
            SizedBox(height: 16),
            // Text Field for Food Weight
            InputRow(unit: 'g'),
            SizedBox(height: 32),
            // Placeholder for Submit Button
            Placeholder(
              fallbackHeight: 50,
              // Placeholder for a button.
              fallbackWidth: double.infinity,
            ),
            SizedBox(height: 16),
            // Placeholder for Recommendation Section
            Placeholder(
              fallbackHeight: 100,
              fallbackWidth: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class InputRow extends StatelessWidget {
  const InputRow({
    required this.unit,
    super.key,
  });

  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Placeholder(
            fallbackHeight: 50,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(unit),
        ),
      ],
    );
  }
}
