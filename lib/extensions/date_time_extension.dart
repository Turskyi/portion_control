import 'package:portion_control/res/constants/date_constants.dart';

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool get isOlderThanMinimumAge => isBefore(minAllowedBirthDate);

  bool get isYoungerThanMinimumAge => isAfter(minAllowedBirthDate);

  /// This method converts the [DateTime] to a [String] without the time part.
  String? toIso8601Date() {
    return toIso8601String().split('T').firstOrNull;
  }

  bool get isToday {
    final DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
