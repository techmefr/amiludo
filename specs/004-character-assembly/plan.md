# Implementation Plan: Character creation with a visually assembled avatar

**Branch**: `feat/character-assembly` | **Date**: 2026-11-05 | **Spec**: [spec.md](spec.md)

## Summary

Extend the existing card pack creation (specs 001) with a base appearance step, a stepwise booster flow that stores draws and resumes, and a layered avatar renderer driven by a catalogue of appearance items. Rules and appearance stay in separate data.

## Technical Context

**Language/Version**: Dart 3 / Flutter 3.47

**Primary Dependencies**: existing only; layers drawn with plain `Stack` and `Image.asset`

**Storage**: the existing draft document, extended with appearance, draws, step and catalogue version

**Testing**: unit tests for assembly rules (order, masking, fallbacks) and draft persistence; widget tests at 390x844, 1280x720, 1920x1080; reduced motion

**Constraints**: offline, code files under 200 lines, no comments, English in the repository, existing tests only extended

## Constitution Check

Technical layers never import functional ones. The layer renderer is generic and lives in the technical layer; the catalogue and rules live in the Random and Templates features, which only import each other's domain.

## Project Structure

```text
app/lib/layers/technical/Avatar/      layer stack renderer, masking, fallbacks
app/lib/layers/functional/Random/     base appearance step, stepwise boosters, recap
app/lib/layers/functional/Templates/  catalogue entities (cards, appearance items)
app/assets/cards/   app/assets/avatar/{bodies,heads,faces,hair,implants,outfits,equipment,weapons,accessories}/
```

## Drawing order

Back accessories, back hair, body and base underwear, prostheses, lower outfit and shoes, upper outfit and sleeves, head, face, front hair and beard, face accessories, belt or torso equipment, weapon, hand in front of the grip, foreground details. Orders are numbers in the data so they can be adjusted after the first character test.

## Lots

- **Lot 1 - Model**: catalogue entities, draft extension, stepwise flow state with stable draws and resume, tests. No images needed.
- **Lot 2 - Renderer**: layer stack, drawing order, masking, fallbacks, tests with generated placeholder layers.
- **Lot 3 - Appearance step and recap**: base appearance screens, live preview, recap.
- **Lot 4 - Demonstration assembly**: one body shape, one base, two heads, two hairstyles, one outfit, one arm prosthesis, one belt item, one weapon and their cards, with real images once available.
- **Lot 5 - Catalogue production**: the remaining cards and layers, second body shape.

## Open Points

- Confirm the eight peoples and their starting abilities.
- Final names of the universe and of the cards.
- Realignment tooling for generated layers.
