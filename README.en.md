# Board game companion — working name

An MIT-licensed, offline board game companion for mobile and web, with customizable retrofuturistic themes. The final name is still undecided.

**[Try the web app](https://techmefr.github.io/ludoply/app/)** · [Android test releases](https://github.com/techmefr/ludoply/releases) · [Français](README.md)

## Available in the public alpha

- Local games, players, rounds, scoring categories, negative and decimal scores, undo/redo, rankings, ties, cooperative goals, resources and notes.
- Timers, player time banks, increments and per-table settings.
- Dice, expressions, locked dice, finger/list selection, teams, weighted wheel, turn order, coin, numbers, token bag and secret roles.
- Six built-in game templates and a custom template editor with JSON import/export.
- Local SQLite storage, game history, CSV, full JSON backup and restore.
- Three visual themes, ten palettes, seven bundled fonts, personal appearance profiles, reduced motion, sound and haptic settings.

No account or server is required for these functions. Load the web app online first so its offline resources can finish downloading. Back up your data: browsers may clear local storage. Android packages are development-signed test builds; export a backup before updating or uninstalling.

The interface is French with partial English support. Native iOS distribution is not available; iPhone users can test the website. Physical-device validation, full English translation and accessibility testing remain open work. Background alarms depend on platform behavior.

Shared rooms, tournaments, advanced time controls, formulas and integrations are planned, not implemented. The [141-feature catalogue](docs/FEATURES.md) distinguishes implemented alpha features from future work.

## Test and contribute

See the [testing guide](TESTING.md), [contribution guide](CONTRIBUTING.md), [actual development status](docs/APP-STATUS.md), [issues](https://github.com/techmefr/ludoply/issues) and [discussions](https://github.com/techmefr/ludoply/discussions). Reports in French or English are welcome.

Flutter 3.47.9 / Dart 3.13.7. Run `flutter pub get`, `flutter analyze` and `flutter test` inside `app`. The web build script is `bash scripts/build_web.sh`.

Source code is under the [MIT license](LICENSE). Bundled fonts and third-party components retain their own license notices, also accessible through the application’s About dialog.
