import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PortionControl'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Enter Your Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Text Field for Body Weight
            const InputRow(label: 'Body Weight', unit: 'kg'),
            const SizedBox(height: 16),
            // Text Field for Food Weight
            const Row(
              children: <Widget>[
                Expanded(
                  child: Placeholder(
                    fallbackHeight: 50,
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text('g'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Placeholder for button action
              },
              style: ElevatedButton.styleFrom(
                // Full-width button.
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Submit'),
            ),
            const SizedBox(height: 16),
            // Recommendation Section Placeholder
            const Placeholder(
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
    required this.label,
    required this.unit,
    super.key,
  });

  final String label;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: label,
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            unit,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
