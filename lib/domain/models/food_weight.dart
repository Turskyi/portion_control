import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';

class FoodWeight {
  const FoodWeight({
    required this.id,
    required this.weight,
    required this.dateTime,
  });

  final int id;

  /// Weight in grams.
  final double weight;

  /// Date when the weight was recorded.
  final DateTime dateTime;

  /// Returns the formatted time in "HH:mm" (24-hour format).
  String get time {
    final String hours = dateTime.hour.toString().padLeft(2, '0');
    final String minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  FoodWeight copyWith({int? id, double? weight, DateTime? dateTime}) {
    return FoodWeight(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  String getMealName({
    required int index,
    required int totalEntries,
  }) {
    //TODO: consider account for a dateTime too.
    // Clamp index to available meal slots
    final int safeIndex = index.clamp(0, _mealOrder.length - 1);

    return translate('meal_type.${_mealOrder[safeIndex]}');
  }

  static final List<String> _mealOrder = <String>[
    'breakfast',
    'second_breakfast',
    'lunch',
    'snack',
    'dinner',
  ];

  @override
  String toString() {
    if (kDebugMode) {
      return 'FoodWeight{'
          'id: $id, '
          'weight: $weight, '
          'date: $dateTime, '
          'time: $time,'
          '}';
    } else {
      return super.toString();
    }
  }
}
