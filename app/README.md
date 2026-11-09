<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="../design/logo/amiludo-logo-horizontal-dark.png">
    <img src="../design/logo/amiludo-logo-horizontal.png" width="360" alt="amiLudo - La boîte">
  </picture>
</p>

# amiLudo — Flutter app (alpha)

Android, iOS and web app. Flutter 3.47.9 / Dart 3.13.7. Code organized in functional and technical layers. The HTML mockups remain in ../prototype.

## Run

```sh
flutter pub get
flutter run -d chrome
```

For browsers, the SQLite components and the Drift worker are included in web/. Fonts are bundled with their OFL licenses; no external font is loaded at startup.

## Verify

```sh
flutter analyze
flutter test
```

After changing the Drift tables: `dart run build_runner build`. The generated sources are versioned so the project runs out of the box.

## Build

At the repository root: `bash scripts/build_web.sh`. APP_BASE_PATH changes the public path; the default is /amiludo/app/. The script produces an offline cache from the compiled files. A first connected visit and a completed download are required before offline use. The browser may clear its data: exporting a backup remains useful.

Android: `flutter build apk --debug` for a test install, with the Android SDK and JDK 17. The GitHub workflow produces this APK as an artifact. It is not a signed store release. The iOS project requires macOS, Xcode and a signing identity to distribute a native app; it is not built on Linux.

## Actual scope

- Local games with 1 to 32 participants; reusable names and rematch.
- Decimal and negative scores, rounds, categories, log, undo and redo, rankings and ties, individual and cooperative objectives, resources and notes.
- Free timer, per-turn time, per-player reserves, increment and pause; settings kept per table.
- Multiple polyhedral dice, locking, expressions and symbols; secure draw, teams, order, weighted wheel, coin, numbers, draw-without-replacement bag and secret roles.
- Six built-in templates actually in use and a JSON template editor.
- Real history, import/export of games and templates, CSV, full backup, restore and confirmed deletion.
- Playroom / Cyberdeck / Orbital / Carnet universes, eleven palettes, seven local fonts, shapes, density, enlarged reading, animations, style profiles and import/export.
- French interface and main controls in English. Exhaustive translation and screen reader testing remain to be completed.

- Game library, friends, game suggestions, memories and session sharing via animated QR code.
- Lobbies to join by code, link or QR (same Wi‑Fi or remote), optional accounts and game nights with sign-ups.

Tournaments, advanced time controls, arbitrary formulas and integrations are not implemented. The global catalog marks these features as planned.

## Online features

They are optional: pass `--dart-define=SUPABASE_URL=…`, `--dart-define=SUPABASE_PUBLISHABLE_KEY=…` and `--dart-define=AMILUDO_LINK_BASE=…`. `scripts/build_web.sh` reads them from the environment. Without these values, the app stays local.

The Wi‑Fi lobby requests network permissions on Android, and `NSLocalNetworkUsageDescription` on iOS.

## Data and limitations

Drift/SQLite stores a versioned library document in a transaction; writes are serialized and save errors are visible. An incompatible backup is rejected before replacement. Score changes can be undone after a reload. Random tools keep their result while open; their configurations are not yet a preset library.

Clocks use a monotonic clock at runtime and a persisted delay for resumption. The app does not promise an audible alarm when the system suspends or closes the browser. Keeping the screen on depends on platform permissions. Finger-based selection depends on the hardware. A weighted wheel displays equal sectors; the weights change the draw and are explicitly stated in its form.

A fallback font for symbols is also bundled, and the wheel respects reduced motion.

Packs and builders: see [PACKS.md](../docs/PACKS.md). Limited declarative calculations and character generation via lists/boosters are available in alpha 0.2.0.

Alpha 0.3.0 adds Playroom, a Confetti palette, original illustrations and warmer titles. Alpha 0.4.0 adds the game library, friends, lobbies and game nights.
