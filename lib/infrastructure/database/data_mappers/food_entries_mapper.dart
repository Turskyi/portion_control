import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/infrastructure/database/database.dart';

extension FoodEntriesMapper on FoodEntry {
  FoodWeight toDomain() {
    return FoodWeight(
      // `id` is the actual value in the data row.
      id: id,
      // `weight` is the value in the data row.
      weight: weight,
      // `date` is the value in the data row.
      date: date,
    );
  }
}
