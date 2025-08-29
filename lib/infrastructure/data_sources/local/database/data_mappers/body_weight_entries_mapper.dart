import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/database.dart';

extension BodyWeightEntriesMapper on BodyWeightEntry {
  BodyWeight toDomain() {
    return BodyWeight(
      // `id` is the actual value in the data row.
      id: id,
      // `weight` is the value in the data row.
      weight: weight,
      // `date` is the value in the data row.
      date: date,
    );
  }
}
