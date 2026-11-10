# Avatar art brief

## Why the current art cannot assemble

The 237 pieces in `app/assets/avatar/pieces` were cut out of generated contact sheets and then each one was scaled to fill its own square (every piece touches about 5% from the edge of its canvas, whatever it is). So an eye, a beard and a boot all have the same size on the canvas, and the canvas position carries no information. Other problems, measured on the files:

- Several pieces per sheet: `hairstyles-sheet-1/2` hold four hairstyles in one image, `beards-sheet-2` a moustache and a beard, `wide-ears` a strip of ears, `eyes-mechanical-*` several eyes.
- Single pieces of a symmetric pair (one eye, one eyebrow, one sleeve, one boot): the code now mirrors them, but they were not drawn to match a head.
- The body (`body-base-full`) is a small full figure with its own head and baked brown colours; heads are large unrelated portraits. Arms, forearms, hands, feet, calves, implants, straps, pockets, signal gear, chain nets are sheets of parts with no body to attach to.
- Baked colour on `body-base-full` and the vest outfit, so skin tint produces muddy results.
- Different line weights and light directions between sheets.

What the code now does to compensate: `tools/build_catalogue.py` stores the opaque bounding box of each piece, and `assets/avatar/rig.json` gives each kind a target rectangle on a big-head character, mirrors pairs, fixes the draw order and hides incompatible pieces. This gives a readable character but the proportions stay approximate. Pieces without a believable placement (including the multi-piece sheets hairstyles 1-2 and wide ears) are marked `hidden` in the rig and not offered.

## Target format

One slot = one PNG, 1024x1024, transparent, drawn at its final position on the template. No cropping, no rescale: the position on the canvas is the attachment. Same canvas for every piece, so the rig needs no rectangle at all.

- Template: `docs/avatar-template.png` (regenerate with `python3 tools/avatar_template.py`). Big-head full-body character, centred on x = 512. Head and neck from y = 20 to 510, shoulders at y = 530, hands at y = 740, feet at y = 990. Red dots are the anchors: eyes (440, 225) and (585, 225), brows y = 175, nose tip (512, 320), mouth (512, 380), hair line y = 100, chin y = 420, shoulders (390, 530) and (635, 530), feet (450, 990) and (575, 990).
- Draw the left/right pairs (eyes, brows, sleeves, hands, boots, ears) as the full pair on one canvas.
- Tintable parts (skin, hair, cloth, eyes): light grey and white only, no hue, shading kept, so the app multiplies a colour. Never bake a skin colour.
- Anything that must not change colour (outlines, metal, gems, pupils, teeth) is a separate untinted piece.
- Same outline weight (about 6 px at 1024), same light direction (top left), same flat cel shading with a single shadow tone, on every piece.
- Layers a piece may need: back part and front part as two PNGs (cape, hair behind the neck, backpack).
- File naming: `<slot>/<kind>_<n>.png`, plus `<slot>/<kind>_<n>_back.png` when a back part exists. One item entry per file in `items.json`.
- Variants: one canvas per body shape (`slim`, `average`, `broad`), same template scaled to the shape, never a rescale of the image.

## Slot list to produce first

| Slot | Content | Count |
|---|---|---:|
| body | nude body, neck down, hands and feet included, grey skin mask | 3 shapes |
| head | head and neck with ears, no features, grey skin mask | 6 |
| eyes | pair of eyes, one colour mask for the iris | 10 |
| eyebrows | pair | 6 |
| nose | single | 6 |
| mouth | single, closed and open | 6 |
| hair | front part and back part | 10 |
| beard | moustache plus beard | 6 |
| outfit top, bottom, shoes | worn on the body template, grey cloth mask | 6 each |
| headgear | hood, helmet, hat, goggles, mask | 6 |
| weapon, tool | in the right hand at (190, 740) | 12 |

## ChatGPT image prompts

Always attach `docs/avatar-template.png` and say: use it only as a position guide, do not draw the red dots, the grid or the grey outline in the result.

Common ending for every prompt: `Transparent background, PNG, square 1024x1024, flat cel shading with one shadow tone, uniform 6 px dark outline, light from the top left, no text, no frame, no extra object. Keep exactly the position and scale of the guide so the piece can be stacked on other pieces without moving it.`

- Body: `Full-body character base for a fantasy tabletop game, seen from the front, large head, human, neutral standing pose, arms slightly away from the body, wearing only plain underwear. Colours: neutral light grey and white only, no hue, so the skin colour can be added in code. Head left empty (no face features), neck and shoulders included.`
- Head: `Front view of a bald human head and neck, no eyes, no eyebrows, no nose, no mouth, ears visible. Light grey and white shading only, no hue. Aligned on the guide head ellipse.`
- Eyes: `Front view of a pair of eyes aligned on the two eye anchors of the guide, expressive, thick upper lash line. Iris in light grey, white of the eye in white, everything else outline only. One image, both eyes.`
- Eyebrows / nose / mouth: `Front view of <a pair of eyebrows | a nose | a mouth> aligned on the matching anchor of the guide, light grey and white shading only, no hue, nothing else in the image.`
- Hair: `Front hair of a <style> hairstyle fitting the guide head, covering the hair line anchor, in light grey and white shading with a few darker strands, no hue. Deliver two images: the front part, and the part that goes behind the neck and shoulders.`
- Beard: `Moustache and beard of <style> fitting the guide head, under the nose anchor and around the mouth anchor, light grey and white shading, no hue, one image.`
- Outfit: `<Garment> worn on the guide body (shoulders at the shoulder anchors), seen from the front, light grey cloth with white highlights, no hue, no body skin visible, openings (neck, sleeves, hems) cut cleanly so the base body shows through.`
- Headgear: `<Hood | helmet | goggles | mask> worn on the guide head, aligned on the guide head ellipse and the eye anchors. Cloth parts in light grey and white, metal parts in their real metal colours. Deliver front part and back part if it wraps around the head.`
- Weapon / tool: `<Object>, held in the right hand of the guide at the hand anchor, vertical, grip centred on the anchor, real colours for metal and wood, outline in the same weight as the character.`

## Acceptance check per piece

1. Place it over `docs/avatar-template.png` at 100%: every feature sits on its dot.
2. Stack it on three other pieces of different sheets: no jump of scale or outline weight.
3. Skin and hair pieces contain no hue (`saturation < 3%`), measured by a script.
4. Opaque bounding box stays inside the area allowed for its slot (written in `rig.json`).
