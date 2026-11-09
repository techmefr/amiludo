<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="../design/logo/amiludo-logo-horizontal-dark.png">
    <img src="../design/logo/amiludo-logo-horizontal.png" width="360" alt="amiLudo - La boîte">
  </picture>
</p>

# Credits and licenses

The project code is under the MIT license.

- Icons: Hugeicons Free / Stroke Rounded, Flutter package `hugeicons` 4.4.0, under the MIT license. Source: https://github.com/hugeicons/hugeicons; license distributed with the package. No Pro assets are included.
- Dice sounds: synthesized in code at runtime (noise bursts through decaying resonant filters), no audio asset is shipped. Playback uses the Flutter package `audioplayers` 6.8.1 under the MIT license. Source: https://github.com/bluefireteam/audioplayers.
- Fonts: OFL licenses kept in `app/assets/fonts/`.
- Flutter components and dependencies: notices available from About → Show licenses.
- Initial packs: original examples from the project, under the MIT license, with author and version in each file.

Cited brands and games belong to their owners. The project is not presented as an official app of those publishers.

## Dice designer

- Face icons come from the same Hugeicons Free / Stroke Rounded set (MIT, copyright 2024 Halal Labs); the searchable catalogue in `app/lib/layers/technical/Theme/icon_catalog.dart` maps plain names to a curated subset. Licence compatible with the MIT project code; no new dependency was added.
- Image import reuses `file_selector` (BSD-3-Clause); drawings and imported images are downscaled to 256x256 PNG with `dart:ui` and stored in the local document store.
- Dice files (`amiludo-dice.json`) contain only the user’s own dice and their face images; nothing from published games.

## 3D dice

- The 3D dice mode is drawn with Flutter `Canvas` and plain vector maths in `app/lib/layers/technical/Dice3D`; the polyhedra (tetrahedron, cube, octahedron, pentagonal trapezohedron, dodecahedron, icosahedron) are generated from their standard coordinates. No new dependency was added.

## Aura backgrounds

- The layered gradient backgrounds (soft blurred blobs combined with blend modes over a base colour, plus a film-grain finish) are inspired by the approach of Aura (https://github.com/CristianOlivera1/Aura, MIT). They are re-created natively with Flutter `CustomPainter`; no asset or code was copied and no dependency was added.
