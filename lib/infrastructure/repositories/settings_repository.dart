import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/services/repositories/i_settings_repository.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';

class SettingsRepository implements ISettingsRepository {
  const SettingsRepository(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  Language getLanguage() => _localDataSource.getLanguage();

  @override
  Future<bool> saveLanguageIsoCode(String languageIsoCode) {
    return _localDataSource.saveLanguageIsoCode(languageIsoCode);
  }

  @override
  bool isOnboardingCompleted() => _localDataSource.isOnboardingCompleted();
}
