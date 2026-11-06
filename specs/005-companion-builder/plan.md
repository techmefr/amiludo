# Implementation Plan: Companion builder from independent bricks

**Spec**: `specs/005-companion-builder/spec.md`

## Approach

A companion is data: a list of bricks, each with a type, settings and an owner. A brick registry maps a type to a widget and a settings schema. Existing tools (scores, timer, dice, generators, finger picker) are re-exposed as bricks without changing their behavior.

## Existing system to extend

The app already has game templates (`GameTemplate` in `Templates/domain/entities/game_template.dart`) with modules, dice, roles, scoring rules, creation categories, statuses, resources, a target and a timer, a pack builder in stages, a marketplace and sessions that run from them. A companion is that template, not a second concept. Bricks are added to it as a `bricks` list next to the existing fields, so every current template keeps working unchanged, and the builder gains a brick step instead of a new builder. The `Companion` and `Brick` entities already merged are the shape of that list.

## Layers

- **technical/Bricks**: brick registry, settings schema, full-screen frame, shake and turn sensors behind an interface with a button fallback.
- **functional/Companion**: companion entity, session state, history with undo, import and export, builder screen.
- **functional/Game**: counters, heroes and powers reuse the existing player and tracker model.
- Technical never imports functional; each brick receives its settings and state through its constructor.

## Lots

1. **Brick model and registry**: companion and brick entities, versioned JSON, unknown bricks preserved, registry.
2. **Counter brick**: settings, displays (number, bar, hearts, pips), bounds, outcome at a bound, history and undo; life, chips and pot as presets.
3. **Heroes and powers**: hero tile, teams, active hero, power charge rules and states.
4. **Hourglass**: flow model with elapsed time kept on turning, sensor interface and button fallback.
5. **Dice tray**: dice sets, physics simulation, shake, keep aside, custom faces.
6. **Builder and session**: add, reorder, resize, remove bricks; full-screen session with one discreet back button.
7. **Share**: export and import of the companion file; generic starting setups.

## Risks

- Physics must be deterministic enough to test: results are read from a seeded simulation in tests.
- Sensors differ per platform: every sensor feature has a visible fallback and is tested without it.
- Large companions on small screens: layout tests at 390×844, 844×390, 1280×720 and 1920×1080.

## Constraints

Files under 200 lines, no comments, every text translated in the seven languages, tokens only for spacing, radii and colors, existing tests only extended.
