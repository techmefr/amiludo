# Tasks: Character creation with a visually assembled avatar

**Input**: `specs/004-character-assembly/spec.md`, `plan.md`

**Tests**: included, existing tests are only extended.

## Lot 1 - Model

- [x] T001 Card and appearance item entities with identifiers and versioned catalogue
- [x] T002 [US2] Extend the character draft with appearance, draws per booster, step and catalogue version
- [x] T003 [US2] Stepwise flow: stable draws, provisional selection, confirmation, back navigation
- [x] T004 [US2] Automatic save and resume
- [x] T005 Tests for stable draws, resume and rule effects without images

## Lot 2 - Renderer

- [x] T006 [US4] Technical Avatar layer stack with drawing order
- [x] T007 [US4] Masking of hidden body parts and fallbacks for missing layers
- [x] T008 Tests with placeholder layers

## Lot 3 - Appearance step and recap

- [x] T009 [US1] Base appearance screens with live preview
- [ ] T010 [US3] Recap with eight cards and computed traits
- [x] T011 Localizations in seven languages
- [ ] T012 Widget tests at three sizes and with reduced motion

## Lot 4 - Demonstration assembly

- [ ] T013 Demonstration catalogue and layers (one shape, two heads, two hairstyles, outfit, prosthesis, belt item, weapon)
- [ ] T014 Validate neck, shoulders, hands, masking and held weapon
- [ ] T015 Update `docs/FEATURES.md` and `docs/PACKS.md`

## Lot 5 - Catalogue production

- [ ] T016 Remaining cards and layers, second body shape
