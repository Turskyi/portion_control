import 'package:flutter/foundation.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/models/storage_keys.dart';
import 'package:portion_control/domain/services/repositories/i_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository implements ISettingsRepository {
  const SettingsRepository(this._preferences);

  final SharedPreferences _preferences;

  @override
  Language getLanguage() {
    final String? savedLanguageIsoCode = _preferences.getString(
      StorageKeys.languageIsoCode.key,
    );
    if (savedLanguageIsoCode != null) {
      return Language.fromIsoLanguageCode(savedLanguageIsoCode);
    } else {
      return Language.fromIsoLanguageCode(
        PlatformDispatcher.instance.locale.languageCode,
      );
    }
  }

  @override
  Future<bool> saveLanguageIsoCode(String languageIsoCode) =>
      _preferences.setString(StorageKeys.languageIsoCode.key, languageIsoCode);
}
