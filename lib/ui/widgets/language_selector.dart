import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/res/resources.dart';
import 'package:portion_control/res/values/dimens.dart';

/// A widget that builds the language selector dropdown.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    required this.currentLanguage,
    required this.onLanguageSelected,
    super.key,
  });

  final Language currentLanguage;
  final ValueChanged<Language> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<Language>> languageOptions = Language.values
        .map(
          (Language language) {
            return DropdownMenuItem<Language>(
              alignment: Alignment.center,
              // The value of each item is the language object.
              value: language,
              // The child of each item is a row with the flag.
              child: Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 8.0),
                child: Text(language.flag),
              ),
            );
          },
        )
        .toList();

    final Resources resources = Resources.of(context);
    final Dimens dimens = resources.dimens;

    return DropdownButton<Language>(
      padding: EdgeInsets.only(left: dimens.leftPadding),
      // The value of the dropdown is the current language.
      value: currentLanguage,

      // The icon of the dropdown is the flag of the current language.
      icon: const Icon(
        Icons.arrow_drop_down_outlined,
        color: Colors.white,
      ),
      selectedItemBuilder: (BuildContext context) {
        final List<Center> languageSelectorItems = Language.values.map(
          (Language language) {
            return Center(
              child: AnimatedSwitcher(
                duration: resources.durations.animatedSwitcher,
                transitionBuilder:
                    (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                child: Text(
                  key: ValueKey<String>(language.flag),
                  language.flag,
                ),
              ),
            );
          },
        ).toList();
        return currentLanguage.isEnglish
            ? languageSelectorItems
            : languageSelectorItems.reversed.toList();
      },
      underline: const SizedBox(),
      dropdownColor: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(dimens.borderRadius),
      // The items of the dropdown are the supported languages.
      items: currentLanguage.isEnglish
          ? languageOptions
          : languageOptions.reversed.toList(),
      // The onChanged callback is triggered when the user selects a
      // different language.
      onChanged: (Language? newLanguage) {
        // Change the language in based on the isoCode of the selected
        // language.
        if (newLanguage != null) {
          changeLocale(context, newLanguage.isoLanguageCode)
          // The returned value is always `null`.
          .then((Object? _) {
            onLanguageSelected(newLanguage);
          });
        }
      },
    );
  }
}
