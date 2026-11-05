import 'dart:ui';

class SupportedLanguage {
  const SupportedLanguage(this.code, this.name, this.flag);

  final String code, name, flag;

  Locale get locale => Locale(code);
}

const autoLanguage = 'auto';

const fallbackLanguage = 'en';

const supportedLanguages = [
  SupportedLanguage('fr', 'Français', '🇫🇷'),
  SupportedLanguage('en', 'English', '🇬🇧'),
  SupportedLanguage('es', 'Español', '🇪🇸'),
  SupportedLanguage('de', 'Deutsch', '🇩🇪'),
  SupportedLanguage('it', 'Italiano', '🇮🇹'),
  SupportedLanguage('pt', 'Português', '🇵🇹'),
  SupportedLanguage('nl', 'Nederlands', '🇳🇱'),
];

bool isValidLanguage(String code) =>
    code == autoLanguage || supportedLanguages.any((l) => l.code == code);

Locale resolveLocale(Locale? requested, Iterable<Locale> supported) {
  for (final locale in supported) {
    if (locale.languageCode == requested?.languageCode) return locale;
  }
  return const Locale(fallbackLanguage);
}
