enum MealType {
  /// Typical range: 07:00–09:00
  breakfast(8, (4, 10)),

  /// Typical range: 10:00–11:00
  secondBreakfast(11, (10, 12)),

  /// Typical range: 12:00–14:00
  lunch(13, (12, 15)),

  /// Typical range: 15:00–16:00
  snack(16, (15, 18)),

  /// Typical range: 18:00–20:00
  dinner(19, (18, 24));

  const MealType(this.startHour, this.range);

  /// The typical hour of the day (0–23) when this meal type usually starts.
  ///
  /// These values are approximate defaults used for heuristic meal
  /// classification when the app needs to infer a meal type from time of day.
  /// They are based on commonly observed meal-time patterns in Western
  /// countries (breakfast in the morning, lunch early afternoon, dinner in
  /// the evening, with a mid‑morning "second breakfast" and mid‑afternoon
  /// snack).
  ///
  /// Reference (observed meal and snack timing patterns in nutrition studies):
  /// https://www.cambridge.org/core/journals/public-health-nutrition/article/characterisation-of-breakfast-lunch-dinner-and-snacks-in-the-japanese-context-an-exploratory-crosssectional-analysis/6C7AD61A99255FA922176CCD4947C1D6
  ///
  /// Studies analyzing real eating behaviour show that people commonly have
  /// 3 main meals and 2 snacks per day, with approximate average times around
  /// breakfast (~07:00–09:00), morning snack (~10:00–11:00),
  /// lunch (~12:00–14:00), afternoon snack (~15:00–16:00),
  /// and dinner (~18:00–20:00). The enum values
  /// below use rounded anchor hours within these ranges.
  ///
  /// The values are intentionally conservative anchors rather than strict
  /// rules and are only used as fallbacks when the app cannot infer the meal
  /// type from other signals (e.g., number of meals or portion size).
  final int startHour;

  /// The inclusive–exclusive hour range during which this meal type is
  /// typically eaten, represented as a Dart **record** `(start, end)`.
  ///
  /// These ranges come from commonly observed meal‑timing patterns in
  /// nutritional studies, which show approximate averages of:
  /// - breakfast: 07:00–09:00
  /// - morning snack / “second breakfast”: 10:00–11:00
  /// - lunch: 12:00–14:00
  /// - afternoon snack: 15:00–16:00
  /// - dinner: 18:00–20:00
  ///
  /// The enum stores a simplified anchor range for each meal type based on
  /// these findings. These values are not strict rules — they are heuristic
  /// boundaries used when inferring a meal type from the time of day.
  ///
  /// For reference, see the exploratory analysis of meal‑timing patterns:
  /// https://www.cambridge.org/core/journals/public-health-nutrition/article/characterisation-of-breakfast-lunch-dinner-and-snacks-in-the-japanese-context-an-exploratory-crosssectional-analysis/6C7AD61A99255FA922176CCD4947C1D6
  ///
  /// Dart documentation on records (the feature that provides `$1`, `$2`,
  /// etc.): https://dart.dev/language/records
  final (int start, int end) range;

  /// Returns `true` if the given [hour] falls within this meal type’s
  /// classification range.
  ///
  /// The [range] field is a Dart **record**, introduced in Dart 3.0.
  /// Records allow lightweight tuple-like structures with positional fields.
  ///
  /// In a record like `(int start, int end)`, the positional fields can be
  /// accessed using the `$1`, `$2`, `$3`, ... getters.
  ///
  /// For example:
  /// ```dart
  /// final r = (7, 10);
  /// print(r.$1); // 7
  /// print(r.$2); // 10
  /// ```
  ///
  /// Official Dart documentation on records:
  /// https://dart.dev/language/records
  bool matchesHour(int hour) {
    return hour >= range.$1 && hour < range.$2;
  }

  String get translationKey =>
      name == 'secondBreakfast' ? 'second_breakfast' : name;
}
