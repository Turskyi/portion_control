import 'package:flutter/material.dart';
import 'package:portion_control/domain/enums/language.dart';

abstract interface class ISettingsRepository {
  const ISettingsRepository();

  Language getLanguage();

  Future<bool> saveLanguageIsoCode(String languageIsoCode);

  bool isOnboardingCompleted();

  ThemeMode getThemeMode();

  Future<bool> saveThemeMode(ThemeMode themeMode);
}
