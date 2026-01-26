import 'package:flutter/material.dart';

class DayCard extends StatelessWidget {
  const DayCard({
    this.title,
    this.meals = const <String>[],
    this.dayTitle,
    this.total,
    this.tried = false,
    this.onTriedChanged,
    this.recipeId,
    super.key,
  });

  final String? title;
  final String? dayTitle;
  final List<String> meals;
  final String? total;
  final bool tried;
  final VoidCallback? onTriedChanged;
  final String? recipeId;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SelectionArea(
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Opacity(
            opacity: tried ? 0.5 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
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
                        ],
                      ),
                    ),
                    if (onTriedChanged != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: InkWell(
                          onTap: onTriedChanged,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              tried
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: tried ? Colors.green : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
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
        ),
      ),
    );
  }
}
