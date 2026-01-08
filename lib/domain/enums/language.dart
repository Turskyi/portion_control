/// [Language] is an `enum` object that contains all supported languages by
/// project.
enum Language {
  en(
    name: _englishLanguage,
    isoLanguageCode: kEnglishIsoLanguageCode,
    flag: '🇬🇧',
  ),
  uk(
    name: _ukrainianLanguage,
    isoLanguageCode: _ukrainianIsoLanguageCode,
    flag: '🇺🇦',
  ),
  fr(
    name: _frenchLanguage,
    isoLanguageCode: _frenchIsoLanguageCode,
    flag: '🇫🇷',
  );

  const Language({
    required this.name,
    required this.isoLanguageCode,
    required this.flag,
  });

  final String name;
  final String isoLanguageCode;
  final String flag;

  bool get isEnglish => this == Language.en;

  bool get isUkrainian => this == Language.uk;

  bool get isFrench => this == Language.fr;

  static Language fromIsoLanguageCode(String isoLanguageCode) {
    switch (isoLanguageCode.trim().toLowerCase()) {
      case kEnglishIsoLanguageCode:
        return Language.en;
      case _ukrainianIsoLanguageCode:
        return Language.uk;
      case _frenchIsoLanguageCode:
        return Language.fr;
      default:
        return Language.en;
    }
  }
}

const String kEnglishIsoLanguageCode = 'en';
const String _ukrainianIsoLanguageCode = 'uk';
const String _frenchIsoLanguageCode = 'fr';
const String _englishLanguage = 'English';
const String _ukrainianLanguage = 'Ukrainian';
const String _frenchLanguage = 'French';
