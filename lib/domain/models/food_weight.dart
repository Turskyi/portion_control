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

  @override
  String toString() {
    if (kDebugMode) {
      return 'FoodWeight{id: $id, weight: $weight, date: $date}';
    } else {
      return super.toString();
    }
  }
}
