import 'package:portion_control/domain/enums/language.dart' as language;
import 'package:portion_control/domain/services/interactors/use_case.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';

class SaveLanguageUseCase implements UseCase<Future<bool>, String> {
  const SaveLanguageUseCase(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  Future<bool> call([
    String languageIsoCode = language.kEnglishIsoLanguageCode,
  ]) {
    return _localDataSource.saveLanguageIsoCode(languageIsoCode);
  }
}
