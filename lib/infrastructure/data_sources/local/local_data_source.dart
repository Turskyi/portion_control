import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/body_weight.dart';
import 'package:portion_control/domain/models/day_food_log.dart';
import 'package:portion_control/domain/models/food_weight.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/data_mappers/body_weight_entries_mapper.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/data_mappers/food_entries_mapper.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/database.dart';
import 'package:portion_control/res/enums/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDataSource {
  const LocalDataSource(this._preferences, this._appDatabase);

  final SharedPreferences _preferences;
  final AppDatabase _appDatabase;

  static const String _heightKey = 'user_height';
  static const String _ageKey = 'user_age';
  static const String _genderKey = 'user_gender';
  static const String _dateOfBirthKey = 'user_date_of_birth';
  static const String _mealsConfirmedKey = 'meals_confirmed';
  static const String _mealsConfirmedDateKey = 'meals_confirmed_date';
  static const String _lastPortionControlKey = 'portion_control';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _weightReminderEnabledKey = 'weight_reminder_enabled';
  static const String _weightReminderTimeKey = 'weight_reminder_time';
  static const String _themeModeKey = 'theme_mode';

  double? getHeight() => _preferences.getDouble(_heightKey);

  int? getAge() => _preferences.getInt(_ageKey);

  String? getGender() => _preferences.getString(_genderKey);

  /// Get Date of Birth from [SharedPreferences].
  DateTime? getDateOfBirth() {
    final String? dobString = _preferences.getString(_dateOfBirthKey);
    return dobString != null ? DateTime.parse(dobString) : null;
  }

  Future<bool> saveHeight(double height) {
    return _preferences.setDouble(_heightKey, height);
  }

  Future<bool> saveAge(int age) {
    return _preferences.setInt(_ageKey, age);
  }

  Future<bool> saveGender(Gender gender) {
    return _preferences.setString(_genderKey, gender.name);
  }

  Future<String> downloadAndSaveImage(String assetPath) async {
    // Check if the platform is web OR macOS. If so, return early.
    // See issue: https://github.com/ABausG/home_widget/issues/137.
    if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
      return '';
    }
    try {
      // Load asset data as ByteData.
      final ByteData byteData = await rootBundle.load(assetPath);

      // Get the application documents directory.
      final Directory directory = await _getAppDirectory();
      final String filePath = '${directory.path}/outfit_image.png';
      // Write the bytes to the file.
      final File file = File(filePath);

      final bool fileExist = await file.exists();
      // Check if the file exists and delete it if it does.
      if (fileExist) {
        await file.delete();
      }

      // Ensure the directory exists.
      await directory.create(recursive: true);

      // Write the new image data.
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      // Invalidate the image cache.
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      return filePath;
    } catch (e) {
      // Handle potential errors (e.g., asset not found).
      debugPrint('Error saving asset image to file: $e');
      final String locale = PlatformDispatcher.instance.locale.languageCode;
      throw Exception(
        '${_translateError('error.save_asset_image_failed', locale)}: $e',
      );
    }
  }

  Future<bool> saveLanguageIsoCode(String languageIsoCode) {
    final bool isSupported = Language.values.any(
      (Language lang) => lang.isoLanguageCode == languageIsoCode,
    );

    final String safeLanguageCode = isSupported
        ? languageIsoCode
        : Language.en.isoLanguageCode;

    return _preferences.setString(
      Settings.languageIsoCode.key,
      safeLanguageCode,
    );
  }

  String getLanguageIsoCode() {
    final String? savedLanguageIsoCode = _preferences.getString(
      Settings.languageIsoCode.key,
    );

    final bool isSavedLanguageSupported =
        savedLanguageIsoCode != null &&
        Language.values.any(
          (Language lang) => lang.isoLanguageCode == savedLanguageIsoCode,
        );

    final String systemLanguageCode =
        PlatformDispatcher.instance.locale.languageCode;

    String defaultLanguageCode =
        Language.values.any(
          (Language lang) => lang.isoLanguageCode == systemLanguageCode,
        )
        ? systemLanguageCode
        : Language.en.isoLanguageCode;

    final String host = Uri.base.host;

    for (final Language language in Language.values) {
      final String currentLanguageCode = language.isoLanguageCode;
      if (host.startsWith('$currentLanguageCode.')) {
        try {
          Intl.defaultLocale = currentLanguageCode;
        } catch (e, stackTrace) {
          debugPrint(
            'Failed to set Intl.defaultLocale to "$currentLanguageCode".\n'
            'Error: $e\n'
            'StackTrace: $stackTrace\n'
            'Proceeding with previously set default locale or system default.',
          );
        }
        defaultLanguageCode = currentLanguageCode;
        // Exit the loop once a match is found and processed.
        break;
      }
    }

    return isSavedLanguageSupported
        ? savedLanguageIsoCode
        : defaultLanguageCode;
  }

  /// Save Date of Birth as an ISO8601 [String].
  Future<bool> saveDateOfBirth(DateTime dateOfBirth) {
    return _preferences.setString(
      _dateOfBirthKey,
      dateOfBirth.toIso8601String(),
    );
  }

  Future<bool> saveMealsConfirmed() async {
    final DateTime today = DateTime.now();
    final bool confirmedSaved = await _preferences.setBool(
      _mealsConfirmedKey,
      true,
    );
    final bool dateSaved = await _preferences.setString(
      _mealsConfirmedDateKey,
      today.toIso8601String(),
    );
    return confirmedSaved && dateSaved;
  }

  bool get isMealsConfirmedForToday {
    final bool? isConfirmed = _preferences.getBool(_mealsConfirmedKey);

    final String? savedDateString = _preferences.getString(
      _mealsConfirmedDateKey,
    );

    if (isConfirmed == true && savedDateString != null) {
      final DateTime savedDate = DateTime.parse(savedDateString);
      final DateTime today = DateTime.now();

      return savedDate.year == today.year &&
          savedDate.month == today.month &&
          savedDate.day == today.day;
    }

    return false;
  }

  double? getLastPortionControl() {
    return _preferences.getDouble(_lastPortionControlKey);
  }

  Future<bool> savePortionControl(double portionControl) {
    _appDatabase
        .insertPortionControl(
          value: portionControl,
          date: DateTime.now(),
        )
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Error while saving portion control to database: $error');
          debugPrint('Stack trace: $stackTrace');
        });

    return _preferences.setDouble(_lastPortionControlKey, portionControl);
  }

  Future<bool> saveOnboardingCompleted() {
    return _preferences.setBool(_onboardingCompletedKey, true);
  }

  bool isOnboardingCompleted() {
    return _preferences.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Reminder settings for logging body weight.
  bool isWeightReminderEnabled() =>
      _preferences.getBool(_weightReminderEnabledKey) ?? false;

  Future<bool> saveWeightReminderEnabled(bool enabled) {
    return _preferences.setBool(_weightReminderEnabledKey, enabled);
  }

  /// Store reminder time as "HH:mm" string. Returns TimeOfDay or null if not
  /// set.
  TimeOfDay? getWeightReminderTime() {
    final String? timeString = _preferences.getString(_weightReminderTimeKey);
    if (timeString == null) return null;
    try {
      final List<String> parts = timeString.split(':');
      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      debugPrint('Error parsing weight reminder time: $e');
      return null;
    }
  }

  Future<bool> saveWeightReminderTime(TimeOfDay time) {
    final String value =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    return _preferences.setString(_weightReminderTimeKey, value);
  }

  ThemeMode getThemeMode() {
    final String? themeName = _preferences.getString(_themeModeKey);
    if (themeName == null) return ThemeMode.light;
    return ThemeMode.values.firstWhere(
      (ThemeMode mode) => mode.name == themeName,
      orElse: () => ThemeMode.light,
    );
  }

  Future<bool> saveThemeMode(ThemeMode themeMode) {
    return _preferences.setString(_themeModeKey, themeMode.name);
  }

  /// Insert or update a body weight entry for the same date.
  /// Returns the `rowid` of the inserted row.
  Future<int> insertOrUpdateBodyWeight(double weight, DateTime date) {
    return _appDatabase.insertOrUpdateBodyWeight(weight, date);
  }

  /// Retrieve all body weight entries, sorted by date.
  Future<List<BodyWeightEntry>> getAllBodyWeightEntries() {
    return _appDatabase.getAllBodyWeightEntries();
  }

  /// Retrieve all food entries, sorted by date.
  Future<List<FoodWeight>> getAllFoodEntries() async {
    final List<FoodEntry> foodEntries = await _appDatabase.getAllFoodEntries();
    return foodEntries.map((FoodEntry entry) => entry.toDomain()).toList();
  }

  /// Delete a body weight entry by id.
  Future<int> deleteBodyWeightEntry(int id) {
    return (_appDatabase.delete(
      _appDatabase.bodyWeightEntries,
    )..where(($BodyWeightEntriesTable tbl) => tbl.id.equals(id))).go();
  }

  /// Update a body weight entry by id.
  Future<bool> updateBodyWeightEntry({
    required int id,
    required double weight,
    required DateTime date,
  }) async {
    final int updatedRows =
        await (_appDatabase.update(
          _appDatabase.bodyWeightEntries,
        )..where(($BodyWeightEntriesTable tbl) => tbl.id.equals(id))).write(
          BodyWeightEntriesCompanion(
            weight: Value<double>(weight),
            date: Value<DateTime>(date),
          ),
        );
    // Return true if any row was updated.
    return updatedRows > 0;
  }

  Future<int> clearFoodEntries() {
    return _appDatabase.clearFoodEntries();
  }

  Future<int> clearBodyWeightEntries() {
    return _appDatabase.clearBodyWeightEntries();
  }

  Future<BodyWeight> getTodayBodyWeight() async {
    final BodyWeightEntry? bodyWeightEntry = await _appDatabase
        .getTodayBodyWeight();
    if (bodyWeightEntry != null) {
      return bodyWeightEntry.toDomain();
    }
    return BodyWeight.empty();
  }

  /// Insert a new food weight entry.
  Future<int> addFoodWeightEntry({
    required double weight,
    required DateTime date,
  }) {
    final FoodEntriesCompanion entry = FoodEntriesCompanion(
      weight: Value<double>(weight),
      date: Value<DateTime>(date),
    );

    return _appDatabase.insertFoodEntry(entry);
  }

  /// Retrieve food weight entries from today.
  Future<List<FoodWeight>> getTodayFoodEntries() async {
    final List<FoodEntry> foodEntries = await _appDatabase.getFoodEntriesByDate(
      DateTime.now(),
    );

    return foodEntries
        .map((FoodEntry weightEntry) => weightEntry.toDomain())
        .toList();
  }

  /// Retrieve food weight entries by a specific date.
  Future<List<FoodWeight>> getFoodEntriesByDate(DateTime date) async {
    final List<FoodEntry> foodEntries = await _appDatabase.getFoodEntriesByDate(
      date,
    );
    return foodEntries
        .map((FoodEntry weightEntry) => weightEntry.toDomain())
        .toList();
  }

  /// Delete a food weight entry by [id].
  Future<int> deleteFoodWeightEntry(int id) => _appDatabase.deleteFoodEntry(id);

  /// Update an existing food weight entry.
  Future<int> updateFoodWeightEntry({
    required int foodEntryId,
    required double foodEntryValue,
  }) {
    return _appDatabase.updateFoodEntry(
      id: foodEntryId,
      weight: foodEntryValue,
    );
  }

  Future<double> getTotalConsumedYesterday() async {
    return _appDatabase.getTotalConsumedYesterday();
  }

  Future<List<FoodWeight>> fetchYesterdayEntries() async {
    final List<FoodEntry> foodEntries = await _appDatabase
        .fetchYesterdayEntries();
    return foodEntries
        .map((FoodEntry weightEntry) => weightEntry.toDomain())
        .toList();
  }

  Future<void> clearTrackingData() {
    return _appDatabase.transaction(() async {
      await _appDatabase.clearBodyWeightEntries();
      await _appDatabase.clearFoodEntries();
      await _appDatabase.clearPortionControlEntries();
      await _preferences.remove(_lastPortionControlKey);
      await _preferences.remove(_mealsConfirmedKey);
      await _preferences.remove(_mealsConfirmedDateKey);
    });
  }

  /// Retrieves the current language setting for the application.
  ///
  /// It prioritizes:
  /// 1. A language explicitly saved by the user in preferences.
  /// 2. A language detected from the host environment (e.g., a specific
  /// subdomain for web).
  /// 3. The device's current system language, if supported by the app.
  /// 4. A default fallback language (English: [Language.en]) if none of the
  /// above are supported or found.
  Language getLanguage() {
    // Get the ISO code using the robust logic from `getLanguageIsoCode()`.
    final String languageIsoCode = getLanguageIsoCode();

    // Convert the determined ISO code to the Language enum.
    return Language.fromIsoLanguageCode(languageIsoCode);
  }

  Future<Directory> _getAppDirectory() async {
    if (!kIsWeb & Platform.isIOS) {
      const MethodChannel channel = MethodChannel(
        'portioncontrol.shared/container',
      );
      final String path = await channel.invokeMethod(
        'getAppleAppGroupDirectory',
      );

      return Directory(path);
    } else {
      // On Android or other platforms, fallback to Documents directory.
      return getApplicationDocumentsDirectory();
    }
  }

  String _translateError(String key, String locale) {
    final Map<String, Map<String, String>> localizedErrors =
        <String, Map<String, String>>{
          'error.save_asset_image_failed': <String, String>{
            'en': 'Failed to save asset image',
            'uk': 'Не вдалося зберегти зображення',
          },
        };
    return localizedErrors[key]?[locale] ?? key;
  }

  Future<BodyWeight> getLastBodyWeight() async {
    final BodyWeightEntry? bodyWeightEntry = await _appDatabase
        .getLastBodyWeight();
    if (bodyWeightEntry != null) {
      return bodyWeightEntry.toDomain();
    }
    return BodyWeight.empty();
  }

  Future<int> getBodyWeightStreak() {
    return _appDatabase.getBodyWeightStreak();
  }

  Future<List<DayFoodLog>> getDailyFoodLogHistory() async {
    final List<FoodEntry> foodEntries = await _appDatabase.getAllFoodEntries();

    if (foodEntries.isEmpty) {
      return <DayFoodLog>[];
    }

    final Map<DateTime, List<FoodEntry>> grouped =
        <DateTime, List<FoodEntry>>{};

    for (final FoodEntry entry in foodEntries) {
      final DateTime day = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );

      grouped.putIfAbsent(day, () => <FoodEntry>[]).add(entry);
    }

    final List<BodyWeightEntry> bodyWeights = await _appDatabase
        .getAllBodyWeightEntries();

    final Map<DateTime, double> bodyWeightByDay = <DateTime, double>{
      for (final BodyWeightEntry bw in bodyWeights)
        DateTime(bw.date.year, bw.date.month, bw.date.day): bw.weight,
    };

    // To get previous body weight, we need sorted body weights.
    final List<BodyWeightEntry> sortedBodyWeights = List<BodyWeightEntry>.from(
      bodyWeights,
    )..sort((BodyWeightEntry a, BodyWeightEntry b) => a.date.compareTo(b.date));

    final Map<DateTime, double> previousBodyWeightByDay = <DateTime, double>{};
    for (int i = 1; i < sortedBodyWeights.length; i++) {
      final BodyWeightEntry current = sortedBodyWeights[i];
      final BodyWeightEntry previous = sortedBodyWeights[i - 1];
      previousBodyWeightByDay[DateTime(
            current.date.year,
            current.date.month,
            current.date.day,
          )] =
          previous.weight;
    }

    final double defaultLimit =
        getLastPortionControl() ??
        await _appDatabase.getMinConsumptionWhenWeightIncreased();

    final List<PortionControlEntry> portionControls = await _appDatabase
        .getAllPortionControls();

    // Sort portion controls by date ascending so that later entries for
    // the same day overwrite earlier ones in our map.
    portionControls.sort(
      (PortionControlEntry a, PortionControlEntry b) =>
          a.date.compareTo(b.date),
    );

    final Map<DateTime, double> portionControlByDay = <DateTime, double>{
      for (final PortionControlEntry pc in portionControls)
        DateTime(pc.date.year, pc.date.month, pc.date.day): pc.value,
    };

    final List<DayFoodLog> result = grouped.entries.map((
      MapEntry<DateTime, List<FoodEntry>> mapEntry,
    ) {
      final DateTime day = mapEntry.key;

      final double dailyLimit = portionControlByDay[day] ?? defaultLimit;

      final double total = mapEntry.value.fold(
        0.0,
        (double sum, FoodEntry item) => sum + item.weight,
      );
      return DayFoodLog(
        date: day,
        totalConsumed: total,
        dailyLimit: dailyLimit,
        bodyWeight: bodyWeightByDay[day],
        previousBodyWeight: previousBodyWeightByDay[day],
        entries: mapEntry.value.map((FoodEntry entry) {
          return FoodWeight(
            id: entry.id,
            weight: entry.weight,
            dateTime: entry.date,
          );
        }).toList(),
      );
    }).toList();

    result.sort((DayFoodLog currentLog, DayFoodLog nextLog) {
      return nextLog.date.compareTo(currentLog.date);
    });
    return result;
  }

  Future<void> insertPortionControl({
    required double value,
    required DateTime date,
  }) {
    return _appDatabase.insertPortionControl(value: value, date: date);
  }

  Future<double> getMaxConsumptionWhenWeightDecreased() {
    return _appDatabase.getMaxConsumptionWhenWeightDecreased();
  }

  Future<double> getMinConsumptionWhenWeightIncreased() {
    return _appDatabase.getMinConsumptionWhenWeightIncreased();
  }
}
