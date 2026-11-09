<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="../design/logo/amiludo-logo-horizontal-dark.png">
    <img src="../design/logo/amiludo-logo-horizontal.png" width="360" alt="amiLudo - La boîte">
  </picture>
</p>

# Technical choices

Initial decision of October 30, 2026. These choices are now applied in app/: Flutter 3.47.9, flutter_bloc (Cubit) + get_it, Drift/SQLite, local fonts and JSON files. Exact versions are in app/pubspec.lock.

| Need | Choice | Reason |
|---|---|---|
| Android, iOS, interactive web | Flutter stable + Dart | One shared app codebase, suited to touch interaction and table mode |
| State and dependencies | flutter_bloc (Cubit) + get_it | One Cubit per feature, injected use cases, testable gateway contracts |
| Navigation | go_router | Declarative navigation and links to tools |
| Persistence | Drift + SQLite | Relational data, transactions and migrations; native engine on mobile and Wasm on web |
| Community templates | JSON + JSON Schema | Simple contributions, validation and versioning; no arbitrary execution |
| Translations | Flutter l10n, ARB files | French and English from the start |
| Identity | Original SVGs | "The box" logo in design/logo, icons generated from the SVG |
| Checks | flutter_test + integration_test | Calculations, undo, resume, migrations, essential flows |
| Automation | GitHub Actions | Analysis, tests and web build; mobile builds to be added after configuration |
| License | MIT | Reuse and open contributions; the name does not grant permission to represent the project |

## Target structure

The code follows the OSDD architecture:
- **Functional layers**, in `lib/layers/functional/<Feature>`: Account, Appearance, Evenings, Friends, Game, History, Library, Lobby, Memories, Random, Sharing, Templates, Timer, Workspace.
- **Technical layers**, in `lib/layers/technical/<Layer>`: About, Appearance, Feedback, Files, Network, Qr, Storage, Theme, Transfer.
- **Inside each feature**: domain (entities, gateways, use_cases), then data (gateways), then presentation (cubit, screens).
- **Dependency rules**: a feature only imports another feature's domain, and technical never imports functional. `test/architecture_test.dart` fails the CI if either rule is broken.
- **Assembly**: `main.dart`, `router.dart` and `dependencies.dart`.

## Offline

The local database is authoritative for a single-device game. Score changes go through transactions and a log enabling undo and resume. Keep durable data separate from animation and the visual refresh of clocks.

On the web, explicitly configure the SQLite Wasm engine and its files/headers, as well as a service worker for the app cache. Check storage restrictions, private modes and compatibility of the targeted browsers. Do not promise persistent alarms when the system suspends the app.

## Showcase site

The app's web version will be Flutter. A showcase site and indexable documents may be separate static HTML pages, generated with Astro if the need arises. No second framework before that need.

## Network and server

**Room on the same Wi-Fi**, with no server at all:
- the host opens an `HttpServer` with WebSocket on `/room/<code fingerprint>` (dart:io);
- guests find the address through a UDP broadcast probe on port 47474, which carries only a fingerprint of the code;
- a link can also carry the address (`?lan=ip:port`), limited to private ranges;
- unavailable in the browser.

**Remote**: Supabase Realtime, broadcast channel `room:CODE`.

**Room access control**:
- the link and the QR carry a host secret (`?k=`); the host signs every state and the closing (HMAC-SHA256, sequence number against replay);
- on Wi-Fi, the host proves this secret during discovery and at connection;
- each guest attaches a key fingerprint to their request and only releases their own seat by revealing that key;
- a guest who only enters the code cannot verify the host.

**Accounts and evenings**:
- Supabase Auth (password, magic link with PKCE and a fallback code, return to the web app or `amiludo://amiludo.app/account`) and PostgreSQL;
- `evenings` table with RLS, `security definer` functions reserved for signed-in accounts (`server/supabase/migrations`);
- `admin-users` Edge function (Deno) for account management by admins, with the service key on the server side only;
- the host is authoritative over the room state.

The server stays optional: without `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` at build time, everything works locally.

Realtime alone is not offline synchronization. To share a game's state, we will need:
- action identifiers;
- idempotence;
- host authority;
- resume;
- access control.

## Validation before extended development

- Multi-touch prototype on real phones, with a list-based fallback.
- Clocks during sleep and after closing/resuming on each platform.
- Drift native and web, migration and import/export.
- Keyboard navigation, screen readers and enlarged text.
- Check package versions and licenses at install time; pin Flutter and keep pubspec.lock.

## Official sources

- https://docs.flutter.dev/platform-integration/web
- https://drift.simonbinder.eu/platforms/
- https://bloclibrary.dev/
