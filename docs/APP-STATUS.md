<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="../design/logo/amiludo-logo-horizontal-dark.png">
    <img src="../design/logo/amiludo-logo-horizontal.png" width="360" alt="amiLudo - La boîte">
  </picture>
</p>

# Application — actual status

Alpha **0.4.0**. Name: amiLudo. The Flutter code is in `app/`, the web app is published under `/app/`, and the old mockups remain at the site root.

## Available

- **Game**:
  - local scores, rounds, categories, goals;
  - undoable log, resources and statuses, notes;
  - per-table clocks, chance tools, teams by names, room players or fingers.
- **Customization**: themes and profiles, pack builders (dice, roles, declarative calculations, characters by lists or boosters) and an installable gallery. See [PACKS.md](PACKS.md).
- **Game library and friends**:
  - game shelves, friend profiles with tastes, available time and per-game opinions;
  - "What are we playing tonight?" suggestions;
  - memories with photos and an encrypted gallery.
- **Offline sharing**: full session in an animated QR code with fountain coding.
- **Rooms**:
  - short code, QR or link;
  - same Wi-Fi without a server, with UDP discovery and WebSocket;
  - or remotely through Supabase Realtime;
  - the host accepts or refuses each player.
- **Optional accounts**:
  - sign-up, sign-in by password or magic link (link or code received by email);
  - forgotten password, password change, first name;
  - the `admin` role is carried by `app_metadata.role`, which only the server can assign;
  - "Manage accounts" screen reserved for admins: list, invitation by email, admin role, blocking, deletion. An action on one's own account is refused.
- **Evenings**: date, place, seats, planned games, yes / maybe / no answers, waiting list, invitation by link, code or QR. Without a server, the host records the answers.
- **Storage**: SQLite, history, CSV and JSON backups.

The catalog counts **170 features: 113 checked, 57 planned or incomplete**. The three initial packs are original examples from the project. Community publishing goes through pull request review.

## Server

Optional Supabase project, provided at build time by `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` and `AMILUDO_LINK_BASE` (GitHub repository variables in the CI).

On the database side, the schema is in `server/supabase/migrations`:
- `evenings` table protected by RLS;
- `publish_evening`, `get_evening` and `answer_evening` functions, reserved for signed-in accounts;
- `admin-users` Edge function (`server/supabase/functions`): it checks the caller's admin role, then goes through the Supabase Auth admin API.

Without these variables, the app stays entirely local. The Wi-Fi room does not exist in the browser.

## Checks

- **Tests**: 115 Flutter tests.
  - Game, chance and data: scores, imports, storage, time, draws, profiles, packs, game library, friends, suggestions, memories, QR sharing.
  - Rooms: protocol, then real sockets over local loopback.
  - Evenings, accounts, account management and links.
  - An architecture test checks the dependencies between layers.
- **CI**: the workflow analyzes the code and runs the tests before building the web app and the Android APK.
- **Checked online version**: the page responds, the bundle points to the right Supabase project, the auth settings are reachable, and an anonymous call to evenings is refused.

Still to do:
- tests on real phones: Wi-Fi discovery, camera, multitouch, sleep, sounds, vibrations;
- Safari and screen readers.

## Known limits

**Rooms**:
- the room code is the only access control;
- the remote channel is public and the local WebSocket is not encrypted.

A host secret and private channels are planned before a wide opening (see the roadmap).

**Account emails**:
- they go out through Supabase's built-in sending: 2 emails per hour, in English;
- the free plan does not allow custom templates without a dedicated SMTP;
- French templates in amiLudo colors are ready: `python3 server/supabase/auth_emails.py` produces the JSON to send to `/v1/projects/<ref>/config/auth` once SMTP is configured.

**Data**:
- the `Workspace` document gathers all the device's data and is rewritten on every change;
- a per-feature split is planned.

**Translation**: English is partial, and some texts and error messages remain in French.

**Rules and calculations**:
- remote rules are links, with no analysis of rulebooks;
- the available calculations do not check every rule of a game;
- a game keeps a copy of its pack.

**Platforms**:
- native iOS requires macOS, Xcode and an Apple signature, and is not distributed. The site is usable on iPhone and iPad.
- APKs are test versions: export a backup before any update.
- No background alarm is guaranteed.

Storage identifiers, file formats and legacy native packages are kept for data continuity.
