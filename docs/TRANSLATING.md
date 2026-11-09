<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="../design/logo/amiludo-logo-horizontal-dark.png">
    <img src="../design/logo/amiludo-logo-horizontal.png" width="360" alt="amiLudo - La boîte">
  </picture>
</p>

# Translating amiLudo

The interface texts live in `app/lib/l10n/`, one ARB file per language. English (`app_en.arb`) is the template: every other file must have exactly the same keys and the same `{placeholders}`.

## Supported languages

French, English, Spanish, German, Italian, Portuguese and Dutch. The list shown in the language selector is `app/lib/layers/technical/Locale/supported_languages.dart`.

## Add a text

1. Add the key and the English text to `app_en.arb`. For a text with values, declare them under `@key` as placeholders.
2. Add the same key to every other language file.
3. Run `flutter gen-l10n` from `app/`, then use `context.l10n.yourKey` in the code.

The test `app/test/l10n_completeness_test.dart` fails when a language misses a key or uses different placeholders.

## Add a language

1. Create `app_<code>.arb` with all the keys of `app_en.arb`.
2. Add the language to `supportedLanguages` with its native name and flag.
3. Run `flutter gen-l10n`.

## Review status

The Spanish, German, Italian, Portuguese and Dutch texts are first drafts and still need a review by native speakers. Corrections are welcome as pull requests on the ARB files.

## Migration status

Texts are moved from the old inline helper to ARB files feature by feature. Features not migrated yet still show French when the language is French and English otherwise.
