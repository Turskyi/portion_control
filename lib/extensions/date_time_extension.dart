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
    DateTime.april;
    // "Jan"
    final String monthAbbreviation = _monthNames[month - 1].substring(0, 3);
    // Example: "12 Jan 1987".
    return '$day $monthAbbreviation $year';
  }

  bool get isToday {
    final DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  static const List<String> _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}
