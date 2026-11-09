# Implementation Plan: Polished, Apple-like interface

**Branch**: `feat/design` | **Date**: 2026-11-05 | **Spec**: [spec.md](spec.md)

## Summary

Introduce design tokens and a small component set in the technical Theme layer, then rebuild the home screen and migrate each feature to them, lot by lot, one pull request per lot.

## Technical Context

**Language/Version**: Dart 3 / Flutter 3.47

**Primary Dependencies**: existing only (flutter_bloc, hugeicons, go_router); no new dependency

**Testing**: extend the responsive harness for the window matrix in FR-009. Exercise populated screens, text scaling, keyboard and sheets, and assert action visibility and reachability. Verify critical flows on the deployed build.

**Constraints**: offline, code files under 200 lines, no comments, English in the repository, existing tests only extended; `deck_theme.dart` (482 lines) is split while touched

## Constitution Check

The technical layer never imports a functional layer. Tokens and components live in `lib/layers/technical/Theme`; features only consume them.

## Project Structure

```text
specs/003-design/{spec.md,plan.md,tasks.md}
app/lib/layers/technical/Theme/
  tokens/        spacing, radius, elevation, type scale, motion
  components/    tile, primary button, sheet, empty state, header
app/test/design_*_test.dart
```

## Lots

- **Lot 1 - Foundations**: tokens, split of `deck_theme.dart`, motion tokens with reduced motion, tokens test.
- **Lot 2 - Components**: tile, buttons, sheet, empty and error states, headers, with widget tests.
- **Lot 3 - Home and first launch**: Workspace home, empty states, navigation depth.
- **Lot 4 - Tools**: Random, Timer, Game, Templates.
- **Lot 5 - Social and data**: Library, Friends, Evenings, Lobby, Memories, Sharing, History.
- **Lot 6 - Account, Admin, Appearance**, then accessibility sweep.
- **Lot 7 - Responsive coverage**: inventory routes, embedded tools, editors and sheets. Test them with realistic content, then correct each failure where its layout is defined. Review the results on the deployed build.

## Open Points

- Which skin becomes the default look (proposal: a clean light skin with one accent).
- Exact tile layout of the home screen, to validate on screenshots before lot 3.
