<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="../design/logo/amiludo-logo-horizontal-dark.png">
    <img src="../design/logo/amiludo-logo-horizontal.png" width="360" alt="amiLudo - La boîte">
  </picture>
</p>

# Roadmap

No deadlines promised; each stage depends on exit criteria.

## 0 — Foundations (done, provisional identity)

Working name, catalog, technical choices and the chosen "The box" logo (design/logo). The repository now contains a Flutter alpha app and the initial mockups.

## 1 — Vertical slice (done and tested)

Create a three-player game, add points, undo, close and resume the game. Prove out data migrations and accessibility before broadening.

## 2 — Offline MVP (alpha in validation)

Features marked MVP in the catalog. Test on Android, iPhone and browser, including touch selection, sleep, clock resume and web storage loss. A complete game must work in airplane mode after installation or a first cached web load.

## 3 — Customizable V1

Game templates, category scores, advanced tools and richer history. Import a validated community template and play without a network. The editor starts with a limited declarative format.

## 4 — Shared V2 (in progress)

Done in 0.4.0:
- rooms joined by code, link or QR, on the same Wi-Fi or remotely (Supabase);
- optional accounts;
- evenings with sign-ups and a waiting list.

Next steps:
- host secret in the link, private Realtime channels and Wi-Fi discovery without a plain-text code;
- SMTP for account emails;
- App Links and Universal Links instead of the `amiludo://` scheme;
- signed release APK;
- sharing game state across devices (host authority, action ordering, resume).

Local games remain available without a remote service.

## Code quality

- Split the `Workspace` document into per-feature storage; each cubit then exposes only its own state.
- Remove the Game ↔ Timer cycle.
- Split `random_tool.dart` by tool.
- Move the remaining texts and errors to i18n.

## 5 — Tournaments and integrations

Independent extensions, based on observed usage and contributions. The priority remains a local, accessible and customizable companion.

## Characters and cards

List/booster generators are available. Next steps: free sheets (attributes, inventory, progression), generic card decks (draw, hand, discard), boards/tokens and campaign tracking. Private multi-device hands depend on the future shared rooms.
