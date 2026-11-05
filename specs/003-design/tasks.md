# Tasks: Polished, Apple-like interface

**Input**: `specs/003-design/spec.md`, `plan.md`

**Tests**: included, existing tests are only extended.

## Lot 1 - Foundations

- [x] T001 Create `Theme/tokens/` (spacing, radius, elevation, type scale, motion)
- [x] T002 Split `deck_theme.dart` under 200 lines per file, same behaviour
- [x] T003 [US3] Motion tokens honouring reduced motion
- [x] T004 `app/test/design_tokens_test.dart`: forbids hard-coded sizes, colours and fonts in presentation code

## Lot 2 - Components

- [ ] T005 [P] [US2] Tile, primary and secondary buttons
- [ ] T006 [P] [US2] Sheet and header
- [ ] T007 [P] [US1] Empty, loading and error states
- [ ] T008 [US4] Targets of 44 by 44 and screen reader labels in the component set
- [ ] T009 Widget tests at three sizes, light and dark

## Lot 3 - Home and first launch

- [ ] T010 [US1] Rebuild the home screen with one primary action and tool tiles
- [ ] T011 [US1] Empty states on every first-launch screen
- [ ] T012 Check navigation depth of two taps

## Lots 4 to 6 - Features

- [ ] T013 Migrate Random, Timer, Game, Templates
- [ ] T014 Migrate Library, Friends, Evenings, Lobby, Memories, Sharing, History
- [ ] T015 Migrate Account, Admin, Appearance
- [ ] T016 [US4] Accessibility sweep at 200 percent text and with a screen reader
- [ ] T017 Visual review at three sizes, validated by the owner
- [ ] T018 Update `docs/FEATURES.md`
