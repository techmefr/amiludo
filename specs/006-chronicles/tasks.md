# Tasks: Chronicles, a character generator by boosters

**Input**: `specs/006-chronicles/spec.md`, `plan.md`

**Tests**: included, existing tests are only extended.

## Lot 1 - Specs, data, domain, state, simple screens

- [x] T001 Specification, plan and tasks
- [x] T002 Data models, loader and coherence checks, bundled sample content
- [x] T003 [US1] Quotas, blocking rules, completion with unfillable types
- [x] T004 [US2] Weighted booster draw with injected randomness, rarity fallback
- [x] T005 [US2] Destiny completion marked and excluded from stats and rarity
- [x] T006 [US3] Stats, global rarity, name, epithet, sheet, text and JSON exports
- [x] T007 Domain unit tests including 10000 draws within 1.5 points
- [x] T008 [US1] Run state, stored document, save after every action and resume
- [x] T009 Localizations in seven languages
- [x] T010 [US1] Universe choice, edition choice, booster with buttons, recap, final sheet
- [x] T011 Entry from the character generator and from the home, route `/chronicles`
- [x] T012 Widget tests at 390x844 and 1280x720

## Lot 2 - Cards and gestures

- [ ] T013 [US4] Card face painter with procedural sigil, rarity border, holographic band from Rare
- [ ] T014 [US4] Flip with perspective, detail panel (bottom sheet on phones)
- [ ] T015 [US4] Swipe to keep or pass with stamps and elastic return (keep threshold 28 percent of the table width, tap under 12 px opens the detail)
- [ ] T016 [US4] Tear gesture (85 percent of 40 percent of the table width) and edition carousel (more than 40 px)
- [ ] T017 [US4] Touch lessons: table wins the gesture arena, 450 ms ignore after opening the detail, no parallax while dragging, table about 54 percent of the height on phones
- [ ] T018 [US4] Particles, halo and flash only when animations are not reduced
- [ ] T019 [US3] Procedural portrait from the appearance data of the kept cards
- [ ] T020 Replace the sample content with the full file and run the 223-card check
