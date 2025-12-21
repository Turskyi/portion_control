import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/domain/models/food_weight.dart';

class DayFoodLog {
  const DayFoodLog({
    required this.date,
    required this.totalConsumed,
    required this.dailyLimit,
    required this.entries,
  });

  final DateTime date;
  final double totalConsumed;
  final double dailyLimit;
  final List<FoodWeight> entries;

  bool get hasEntries => entries.isNotEmpty;

  bool get isOverLimit => totalConsumed > dailyLimit;

  String get formattedDate {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime dayDate = DateTime(date.year, date.month, date.day);

    final int difference = today.difference(dayDate).inDays;

    if (difference == 0) {
      return translate('today');
    } else if (difference == 1) {
      return translate('yesterday');
    }

    // Fallback: human-readable calendar date, e.g. 18 Nov 2025
    final List<String> months = <String>[
      translate('month_abbr.jan'),
      translate('month_abbr.feb'),
      translate('month_abbr.mar'),
      translate('month_abbr.apr'),
      translate('month_abbr.may'),
      translate('month_abbr.jun'),
      translate('month_abbr.jul'),
      translate('month_abbr.aug'),
      translate('month_abbr.sep'),
      translate('month_abbr.oct'),
      translate('month_abbr.nov'),
      translate('month_abbr.dec'),
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
