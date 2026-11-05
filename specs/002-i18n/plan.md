# Implementation Plan: European multilingual app and content

**Branch**: `feat/i18n` | **Date**: 2026-11-05 | **Spec**: [spec.md](spec.md)

## Summary

Replace the inline `tr(context, french, english)` helper (about 773 calls in 74 files) with Flutter generated localizations from ARB files, add five languages, a language selector with flags and native names, localized pack content with fallback, and automated completeness checks.

## Technical Context

**Language/Version**: Dart 3 / Flutter 3.47 (SDK at `~/ludoply-flutter-sdk`)

**Primary Dependencies**: `flutter_localizations` (already present), `intl`, Flutter `gen-l10n`

**Storage**: the existing appearance document keeps the language code

**Testing**: `flutter test`; a checks test compares every ARB file with the English template

**Target Platform**: Android, iOS, web

**Constraints**: offline, no runtime translation download, no new heavy dependency, code files under 200 lines, no comments in code, texts in English in the repository

**Scale/Scope**: about 773 texts today, 7 languages, growth expected with game content

## Constitution Check

No constitution file in this repository. Applied rules: OSDD layers, existing tests only extended, accessibility by default.

## Project Structure

### Documentation

```text
specs/002-i18n/
├── spec.md
├── plan.md
└── tasks.md
```

### Source Code

```text
app/
├── l10n.yaml                        # gen-l10n configuration, English template
├── lib/l10n/
│   ├── app_en.arb                   # template
│   ├── app_fr.arb app_es.arb app_de.arb app_it.arb app_pt.arb app_nl.arb
│   └── generated files from gen-l10n
├── lib/layers/technical/Locale/
│   ├── supported_languages.dart     # code, native name, flag
│   └── localized_text.dart          # per-language text with fallback
├── lib/layers/functional/Appearance/presentation/language_selector.dart
└── test/
    ├── l10n_completeness_test.dart
    └── localized_text_test.dart
```

**Structure Decision**: generated localizations live in `lib/l10n` as Flutter expects. The supported language list and localized text value type are technical (no feature imports them the other way round), so they sit in `technical/Locale`.

## Design decisions

1. **Access**: a `context.l10n` extension returns the generated class, so call sites read `context.l10n.openPack`.
2. **Keys** are descriptive English identifiers in lower camel case, grouped by feature prefix (`randomOpenPack`, `libraryEmptyShelf`).
3. **Placeholders and plurals** use ICU syntax in ARB, replacing string interpolation and the `carte(s)` pattern.
4. **Migration** goes feature by feature. A temporary script extracts each `tr()` pair into keys, French from the first argument and English from the second, then rewrites the call site. The script is not committed.
5. **Compatibility**: `tr()` stays until the last feature is migrated, then it is deleted.
6. **Locale resolution**: stored choice, else device locale if supported, else English. Unsupported stored values fall back the same way.
7. **Localized content**: a `LocalizedText` accepts either a plain string (existing packs) or a map of language code to text, with order requested language, English, first available. Export keeps the map.
8. **Selector** shows flag and native name per language, listed from `supported_languages.dart`.
9. **Completeness test** loads every ARB and checks same keys and same placeholders as the template.

## Delivery

Sequential lots, each its own branch from `main`, merged before the next:

- Lot A: infrastructure, selector, completeness test, shared UI and Appearance and Workspace migrated.
- Lot B: Random, Templates and Game.
- Lot C: remaining features, removal of `tr()`, localized pack content.

## Complexity Tracking

No constitution violations.
