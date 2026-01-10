enum MealType {
  breakfast,
  secondBreakfast,
  lunch,
  snack,
  dinner;

  String get translationKey =>
      name == 'secondBreakfast' ? 'second_breakfast' : name;
}
