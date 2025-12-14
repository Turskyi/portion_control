import 'package:flutter/material.dart';

class DayCard extends StatelessWidget {
  const DayCard({
    this.title,
    this.meals = const <String>[],
    this.dayTitle,
    this.total,
    super.key,
  });

  final String? title;
  final String? dayTitle;
  final List<String> meals;
  final String? total;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  title!,
                  style: textTheme.titleLarge,
                ),
              ),
            if (dayTitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  dayTitle!,
                  style: textTheme.titleMedium,
                ),
              ),
            for (final String meal in meals)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  meal,
                  style: textTheme.bodyMedium,
                ),
              ),
            if (total != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  total!,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
