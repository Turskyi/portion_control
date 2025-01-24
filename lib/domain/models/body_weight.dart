class BodyWeight {
  const BodyWeight({
    required this.id,
    required this.weight,
    required this.date,
  });

  final int id;

  /// Weight in kilograms or pounds.
  final double weight;

  /// Date when the weight was recorded.
  final DateTime date;
}
