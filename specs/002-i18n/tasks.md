# Tasks: European multilingual app and content

**Input**: `specs/002-i18n/spec.md`, `plan.md`

**Tests**: included, existing tests are only extended.

## Phase 1: Lot A - Infrastructure

- [x] T001 Add `l10n.yaml` and enable `generate: true` in `app/pubspec.yaml`
- [x] T002 [P] Create `app/lib/l10n/app_en.arb` as template and `app_fr.arb`
- [x] T003 [P] Add `app/lib/layers/technical/Locale/supported_languages.dart` (fr, en, es, de, it, pt, nl with flag and native name)
- [x] T004 Wire delegates, supported locales and locale resolution in `app/lib/main.dart`
- [x] T005 Add the `context.l10n` extension
- [x] T006 [US1] Language selector with flag and native name in Appearance, replacing the current selector
- [x] T007 [US3] `app/test/l10n_completeness_test.dart`: same keys and placeholders in every language
- [x] T008 [US1] Migrate shared Theme widgets, Appearance and Workspace to keys
- [x] T009 [US1] Draft `app_es`, `app_de`, `app_it`, `app_pt`, `app_nl` for lot A keys

## Phase 2: Lot B - Random, Templates, Game

- [ ] T010 [US1] Migrate Random (character tool, packs, tools) and translate all languages
- [ ] T011 [US1] Migrate Templates and Game and translate all languages
- [ ] T012 [US1] Widget tests: switch language and check no inline text on main screens

## Phase 3: Lot C - Remaining features and content

- [ ] T013 [US1] Migrate Library, Friends, Evenings, Lobby, Memories, History, Account, Admin, Timer, About, Feedback
- [ ] T014 [US1] Plural rules for every counted text
- [ ] T015 [US1] Dates, times and numbers formatted with the selected language
- [ ] T016 Remove `tr()` once no call remains
- [ ] T017 [US2] `localized_text.dart` and tests: plain string, map, fallback order, round trip
- [ ] T018 [US2] Use `LocalizedText` for pack and card names and descriptions, keeping old packs valid
- [ ] T019 [US1] Layout checks at 1280x720, 1920x1080 and phone for every language

## Phase 4: Polish

- [x] T020 Mark drafted translations for native review in `docs/TRANSLATING.md`
- [ ] T021 Update `docs/FEATURES.md` and `README` language list
- [ ] T022 Run `flutter analyze`, `dart format` and the full `flutter test`

## Dependencies

T001 before everything. T003 and T004 before T006. T007 before T009 so gaps are caught early. Lot B and C wait for the previous lot to be merged.
