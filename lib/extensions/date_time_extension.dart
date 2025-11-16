import 'package:flutter_translate/flutter_translate.dart';
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

  /// Returns a user-friendly date format like "12 Jan 1987"
  String toReadableDate() {
    // "Jan"
    final String monthAbbreviation = _monthNames[month - 1].substring(0, 3);
    // Example: "12 Jan 1987".
    return '$day $monthAbbreviation $year';
  }

  bool get isToday {
    final DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  List<String> get _monthNames {
    return <String>[
      translate('month_names.january'),
      translate('month_names.february'),
      translate('month_names.march'),
      translate('month_names.april'),
      translate('month_names.may'),
      translate('month_names.june'),
      translate('month_names.july'),
      translate('month_names.august'),
      translate('month_names.september'),
      translate('month_names.october'),
      translate('month_names.november'),
      translate('month_names.december'),
    ];
  }
}
