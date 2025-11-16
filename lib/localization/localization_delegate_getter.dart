import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';

Future<LocalizationDelegate> getLocalizationDelegate(
  LocalDataSource localDataSource,
) async {
  final LocalizationDelegate localizationDelegate =
      await LocalizationDelegate.create(
        fallbackLocale: localDataSource.getLanguageIsoCode(),
        supportedLocales: Language.values
            .map((Language language) => language.isoLanguageCode)
            .toList(),
      );

  return localizationDelegate;
}
