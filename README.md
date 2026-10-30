# Ludoply

**Tous les outils. Autour de la table.**

An open-source board game companion for Android, iOS and the web. Choose who starts, roll dice, keep scores and manage time — with the same players throughout a game.

## Project status

Planning and identity exploration. No runnable application yet. All features below are planned, not implemented. The name is provisional; logo concepts are under review.

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
