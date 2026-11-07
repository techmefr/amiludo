# Catalogue format for character pieces

What the app reads. Anything not listed here is ignored, so extra fields are harmless.

## Pieces

- PNG, 512x512 (1024x1024 also accepted; the canvas is square and shared), transparent background, one shared canvas for every piece of the same body shape. Never crop or resize a piece: its position on the canvas is its attachment, so no coordinates are needed.
- File path inside the app: `assets/avatar/<group>/<name>.png`, referenced in JSON as `avatar/<group>/<name>` (no `assets/` prefix, no extension).
- A piece meant to be colored by the app is drawn in light grey and white shading only (no hue). The app multiplies it by the chosen color, so shadows and highlights survive.
- Outlines, shadows and textures that must not change color go in their own separate piece, without a tint.

## Item

One entry per choosable element (a hairstyle, an outfit, an arm implant, a weapon).

```json
{
  "id": "outfit.miner",
  "slot": "outfit",
  "peoples": [],
  "variants": {
    "slim": {
      "layers": [
        { "order": 40, "src": "avatar/outfit/miner/trousers_slim" },
        { "order": 60, "src": "avatar/outfit/miner/torso_slim", "tint": "cloth" },
        { "order": 62, "src": "avatar/outfit/miner/sleeves_slim", "tint": "cloth" }
      ],
      "hideBodyParts": ["torso", "upper_legs"]
    }
  }
}
```

- `id`: unique, stable, dotted (`<slot>.<name>`).
- `slot`: one of `base`, `head`, `eyes`, `eyebrows`, `nose`, `mouth`, `hair`, `beard`, `marks`, `outfit`, `shoes`, `accessory`, `implant`, `equipment`, `weapon`.
- `peoples`: list of people ids it fits; empty means every people.
- `variants`: one entry per body shape (`slim`, `average`, `broad`), each with its own layers, because the pieces follow the body. A missing shape means the item does not fit that shape.
- `layers[].order`: draw order, ascending. Use the table below.
- `layers[].tint`: optional palette name (see below). Absent means drawn as is.
- `hideBodyParts`: body parts of the base body that this item covers or replaces (an implant arm hides `right_arm`). Names: `head`, `neck`, `torso`, `left_arm`, `right_arm`, `left_hand`, `right_hand`, `upper_legs`, `lower_legs`, `feet`.

## Draw order

| Order | Content |
|---:|---|
| 10 | Back accessories, back hair |
| 20 | Base body and underwear |
| 30 | Prostheses and implants |
| 40 | Lower outfit and shoes |
| 60 | Upper outfit and sleeves |
| 70 | Head |
| 75 | Face (eyes, brows, nose, mouth, marks) |
| 80 | Front hair and beard |
| 85 | Face accessories |
| 90 | Belt and torso equipment |
| 100 | Weapon |
| 105 | Hand in front of the grip |
| 110 | Foreground details |

Orders between two rows are allowed; they can be adjusted after the first full character test.

## Palettes

```json
{
  "skin": ["#F2D2B6", "#D9A57C", "#A66E47", "#5C3A26"],
  "hair": ["#1B1B1B", "#4A2F1D", "#8B5A2B", "#C9A227", "#B5482F", "#8E8E8E", "#E8E8E8", "#3E5C8A"],
  "eyes": ["#3B2A1A", "#2E6B4F", "#3D6FB0", "#7A7A7A", "#9A5B1E", "#6A3D8A", "#B58B1F", "#1F1F1F"],
  "cloth": ["#C9B38B", "#6B7F5E", "#8A3B2E", "#3B4F6B", "#6E6E6E", "#D9D1BF"]
}
```

Any palette name used by a `tint` must exist here. The app picks one color per palette name for the character and applies it to every layer using that name.

## Files per batch

1. The PNG pieces.
2. `items.json`: a list of items as above.
3. `palettes.json`.
4. `version`: an integer inside each JSON file, bumped on any change, so the same seed rebuilds the same character.

## First batch to check the pipeline

One human head, three variants of each face trait, one hairstyle, one torso, two sleeves, one trousers, one pair of shoes, one accessory, in a single body shape. Assemble them, color them, and only then produce the other shapes and peoples.
