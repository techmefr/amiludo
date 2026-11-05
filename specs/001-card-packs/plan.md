# Implementation Plan: Card packs character creation

**Branch**: `feat/card-packs` | **Date**: 2026-11-05 | **Spec**: [spec.md](spec.md)

## Summary

The app already builds characters from categories with a draw size and keep range (`CreationCategory`, `CharacterDraft`, `CharacterTool`). This lot turns that into the pack opening experience, persists the unfinished draft, and lets a card reference an optional bundled image with an icon fallback.

## Technical Context

**Language/Version**: Dart 3 / Flutter 3.47 (SDK at `~/ludoply-flutter-sdk`)

**Primary Dependencies**: flutter_bloc, drift (document store), hugeicons, existing `deck_*` theme widgets

**Storage**: local document store (`technical/Storage`), one document per feature

**Testing**: `flutter test` (unit and widget tests under `app/test`)

**Target Platform**: Android, iOS, web, one code base

**Project Type**: mobile and web app

**Constraints**: offline first, no remote image fetching, screens 1280x720 and 1920x1080 plus phones, reduced motion honoured, all texts through the translation helper, code files under 200 lines, no comments in code

**Scale/Scope**: up to 16 categories per pack, 100 cards per category (existing limits)

## Constitution Check

No constitution file exists in this repository. Rules applied from the project conventions: OSDD layers (technical never imports functional, features only import another feature's domain), tests only extended never weakened, translations everywhere, accessibility by default.

## Project Structure

### Documentation

```text
specs/001-card-packs/
├── spec.md
├── plan.md
└── tasks.md
```

### Source Code

```text
app/lib/layers/functional/
├── Templates/domain/entities/character_pack.dart    # CharacterCard gains optional image
├── Random/domain/entities/character_draft.dart      # toJson/fromJson for persistence
├── Random/domain/gateways/character_draft_gateway.dart
├── Random/domain/use_cases/                         # save, read, clear draft
├── Random/data/gateways/character_draft_gateway_impl.dart
└── Random/presentation/
    ├── character_tool.dart                          # orchestrates the flow, shrinks
    ├── pack_opening.dart                            # closed pack and reveal animation
    ├── card_face.dart                               # card with image or icon fallback
    └── character_sheet_stack.dart                   # final stacked sheet
app/test/
├── character_draft_test.dart
└── card_packs_widget_test.dart
```

**Structure Decision**: extend the existing Random feature (where the character tool lives) rather than create a new feature. The image reference lives on `CharacterCard` in Templates because packs are serialised there.

## Design decisions

1. **Image reference** is an asset key such as `cards/race-duneens` resolved against `assets/cards/` in the app bundle. Any other form is rejected on import. A missing asset triggers the icon fallback through an error builder.
2. **Persistence** stores the draft as JSON (pack name, boosters flag, offers per category, kept choices, index) so the same offers are restored and cannot be rerolled by leaving the screen.
3. **Animation** uses implicit Flutter animations only (no new dependency). The reveal checks `MediaQuery.disableAnimations` and shows cards immediately when set. A skip control reveals everything.
4. **Accessibility** each card is a semantic node with type, name and description, and keep/unkeep is a labelled toggle.

## Complexity Tracking

No constitution violations.
