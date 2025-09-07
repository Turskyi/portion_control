class PortionControlSummary {
  const PortionControlSummary({
    required this.weight,
    required this.consumed,
    required this.portionControl,
    required this.recommendation,
    required this.formattedLastUpdatedDateTime,
  });

  /// User's current weight (kg).
  final double weight;

  /// Total consumed food (g).
  final double consumed;

  /// Daily portion limit (g).
  final double portionControl;

  /// Text recommendation for the user.
  final String recommendation;

  /// Last time data was updated.
  final String formattedLastUpdatedDateTime;

  /// Copy with modifications
  PortionControlSummary copyWith({
    double? weight,
    double? consumed,
    double? portionControl,
    String? recommendation,
    String? formattedLastUpdatedDateTime,
  }) {
    return PortionControlSummary(
      weight: weight ?? this.weight,
      consumed: consumed ?? this.consumed,
      portionControl: portionControl ?? this.portionControl,
      recommendation: recommendation ?? this.recommendation,
      formattedLastUpdatedDateTime:
          formattedLastUpdatedDateTime ?? this.formattedLastUpdatedDateTime,
    );
  }
}
