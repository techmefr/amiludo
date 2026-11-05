# Tasks: Card packs character creation

**Input**: `specs/001-card-packs/spec.md`, `plan.md`

**Tests**: included, existing tests are only extended.

## Phase 1: Foundation

- [x] T001 Add optional `image` to `CharacterCard` with validation and JSON in `app/lib/layers/functional/Templates/domain/entities/character_pack.dart`
- [x] T002 [P] Declare `assets/cards/` in `app/pubspec.yaml` with a `.gitkeep`
- [x] T003 [P] Add `toJson`/`fromJson` to `CharacterDraft` in `app/lib/layers/functional/Random/domain/entities/character_draft.dart`

## Phase 2: User Story 1 - Build a character by opening packs (P1)

- [x] T004 [US1] Add `CharacterDraftGateway` and its drift-backed implementation in `Random/domain` and `Random/data`
- [x] T005 [US1] Add save, read and clear draft use cases in `Random/domain/use_cases`
- [x] T006 [US1] Create `pack_opening.dart`: closed pack with the category name and the flip reveal
- [x] T007 [US1] Create `character_sheet_stack.dart`: stacked final sheet
- [x] T008 [US1] Rewire `character_tool.dart` to use the pack opening, persist after each step and restore on entry
- [x] T009 [US1] Unit tests: draft round trip, same offers after restore, keep range enforced (`app/test/character_draft_test.dart`)
- [x] T010 [US1] Widget test: open three packs, keep one card each, name and save (`app/test/card_packs_widget_test.dart`)

## Phase 3: User Story 2 - Illustrations (P2)

- [x] T011 [US2] Create `card_face.dart`: image from the bundle, type icon on error or when absent
- [x] T012 [US2] Use `CardFace` in the pack opening and in the sheet stack
- [x] T013 [US2] Tests: valid reference, missing asset fallback, import rejects an invalid reference, export keeps it

## Phase 4: User Story 3 - Accessibility (P3)

- [x] T014 [US3] Skip control and reduced motion handling in `pack_opening.dart`
- [x] T015 [US3] Semantics for cards and keep toggles
- [x] T016 [US3] Widget tests for reduced motion, skip and semantic labels

## Phase 5: Polish

- [x] T017 Translations for every new text through the existing helper
- [ ] T018 Check layouts on 1280x720, 1920x1080 and a phone viewport
- [x] T019 Run `flutter analyze`, `dart format` and the full `flutter test`
- [ ] T020 Update `docs/FEATURES.md` and `docs/PACKS.md`

## Dependencies

T001 before T011 and T013. T003 before T004. T004 and T005 before T008. T006 and T007 before T008. User stories 2 and 3 depend on the pack opening from User Story 1.
