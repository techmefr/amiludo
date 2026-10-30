# Ludoply

**Tous les outils. Autour de la table.**

An open-source board game companion for Android, iOS and the web. Choose who starts, roll dice, keep scores and manage time — with the same players throughout a game.

## Project status

Product planning with a runnable interactive web prototype. The production Flutter application is not implemented yet. The name is provisional and will be chosen later. Prototype behavior and planned application features are distinguished below.

## Product principles

- Quick tools without setup, and a connected game mode.
- Offline core, no mandatory account, no advertising.
- Accessible, readable across the table, with undo and automatic recovery.
- Portable data and community-authored game presets.

## Project documents

- [Feature catalogue — French](docs/FEATURES.md)
- [Roadmap](docs/ROADMAP.md)
- [Technology decisions](docs/TECHNOLOGY.md)
- [Brand exploration](design/BRIEF.md)
- [Contributing](CONTRIBUTING.md)

## Selected direction

Flutter + Dart for the app; Riverpod for state; Drift/SQLite for local persistence. Community presets in versioned JSON. No backend for the first release. Optional shared sessions and sync are later milestones.

See the technology document for platform limitations and validation gates. Documentation and initial contributions are welcome. Code and original design concepts are released under the MIT license.

## Interactive mockups

[Open the prototype](https://techmefr.github.io/ludoply/) · [Prototype guide](prototype/README.md) · [Screenshots](design/mockups/)

Six responsive screens: home, active game, tools, preset library, history and appearance. Six palettes, four fonts, light/dark/system modes, shape and density options, saved local style profiles, JSON import/export. Scores, undo, turns, timer, dice, player selection, teams, coin and wheel can be tried. Generic preset cards are previews, not implemented game engines.

Run locally from the repository: `python3 -m http.server 4173 --directory prototype`, then open http://localhost:4173. No build or account required.
