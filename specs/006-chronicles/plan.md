# Implementation Plan: Chronicles, a character generator by boosters

**Branch**: `chronicles-boosters` | **Date**: 2026-11-06 | **Spec**: [spec.md](spec.md)

## Summary

Extend the Random feature (character generator, specs 001 and 004) with a multi-step booster flow driven by a content file. Pure domain logic with injected randomness, a cubit that saves after every action, simple screens first, then a card painter, gestures and effects.

## Technical Context

**Language/Version**: Dart 3 / Flutter 3.47

**Primary Dependencies**: existing only (flutter_bloc, get_it, share_plus, drift store)

**Storage**: a `chronicles_run` stored document holding the run as JSON; content in a bundled asset

**Testing**: unit tests for rules, draw, destiny, stats, rarity, sheet, exports, resume; a 10000-draw weight test; widget tests at 390x844 and 1280x720

**Constraints**: offline, code files under 200 lines, no comments, English in the repository, existing tests only extended, tokens only

## Constitution Check

Everything lives in the Random feature: `domain/chronicles`, `data/chronicles`, `presentation/chronicles`. Domain imports nothing from presentation or data. Presentation imports other features only through their domain (Game, Templates). Technical layers are untouched except for reuse.

## Structure

```text
app/assets/chronicles/chronicles-data.json
app/lib/layers/functional/Random/domain/chronicles/    card, data, checks, rules, draw, run, sheet, export, gateways, use cases
app/lib/layers/functional/Random/data/chronicles/      catalog (asset) and run (stored document) gateways
app/lib/layers/functional/Random/presentation/chronicles/   picker, edition, discover, recap, sheet, view
app/lib/layers/functional/Random/presentation/cubit/chronicles_cubit.dart
```

## Content schema

- `caracteristiques`: list of `{id, nom}`
- `raretes`: list of `{id, nom, poids, score}`
- `etapes`: list of `{id, nom, types: [{type, min, max}]}`
- `editions`: list of `{id, nom, stats: [id, id]}`
- `univers`: list of `{id, nom, epithete}`
- `libellesCourts`: map from type to short label
- `cartes`: list of `{id, univers, etape, type, libelle, rarete, nom, texte, modificateurs, tags, conflits, apparence, epithete}`; `univers` is `*` for common cards

## Run state

Phase edition, discover, recap or done; step index; chosen edition; the five card identifiers of the booster and the position; kept cards with a destiny flag; seen identifiers of the step. Cards are stored by identifier and looked up in the content, so a save never embeds content.

## Lots

- **Lot 1 - Specs, data, domain, state, simple screens** (first pull request)
- **Lot 2 - Card painter, flip, detail panel, gestures, effects, procedural portrait** (second pull request)
