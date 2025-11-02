import 'package:flutter/foundation.dart';

class FoodWeight {
  const FoodWeight({
    required this.id,
    required this.weight,
    required this.date,
  });

  final int id;

  /// Weight in grams.
  final double weight;

  /// Date when the weight was recorded.
  final DateTime date;

  /// Returns the formatted time in "HH:mm" (24-hour format).
  String get time {
    final String hours = date.hour.toString().padLeft(2, '0');
    final String minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  String toString() {
    if (kDebugMode) {
      return 'FoodWeight{id: $id, weight: $weight, date: $date, time: $time,}';
    } else {
      return super.toString();
    }
  }

  FoodWeight copyWith({int? id, double? weight, DateTime? date}) {
    return FoodWeight(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      date: date ?? this.date,
    );
  }
}
