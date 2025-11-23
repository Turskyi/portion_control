import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:portion_control/domain/enums/language.dart';

Future<void> injectDependencies() async {
  await _initializeAllDateFormatting();
}

/// Initializes date formatting for all supported languages.
///
/// For each language defined in [Language.values]:
/// - It attempts to initialize the specific date formatting rules for the
/// language's ISO code (e.g., 'en', 'uk').
/// - The second parameter to [initializeDateFormatting] is `null`. This means
///   that if exact formatting data for the specified `lang.isoLanguageCode`
///   is not found or is incomplete, the `intl` package will fall back to using
///   the current default system locale's formatting rules as a sensible
///   default.
///   This provides a graceful fallback and ensures dates can still be formatted
///   according to the user's device preferences if specific app-defined locale
///   data is missing.
Future<void> _initializeAllDateFormatting() async {
  for (final Language lang in Language.values) {
    try {
      await initializeDateFormatting(lang.isoLanguageCode, null);
    } catch (e, stackTrace) {
      debugPrint(
        'Failed to initialize date formatting for ${lang.isoLanguageCode}.\n'
        'Error: $e\n'
        'StackTrace: $stackTrace',
      );
    }
  }
}
