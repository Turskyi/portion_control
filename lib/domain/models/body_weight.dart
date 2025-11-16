import 'package:flutter/foundation.dart';

@immutable
class BodyWeight {
  const BodyWeight({
    required this.id,
    required this.weight,
    required this.date,
  });

  BodyWeight.empty() : this(id: 0, weight: 0, date: DateTime(0));

  final int id;

  /// Weight in kilograms or pounds.
  final double weight;

  /// Date when the weight was recorded.
  final DateTime date;

  @override
  String toString() {
    if (kDebugMode) {
      return 'BodyWeight{id: $id, weight: $weight, date: $date}';
    } else {
      return super.toString();
    }
  }
}
