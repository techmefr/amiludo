# amiLudo feature catalog

Status: **[x] = implemented in the Flutter alpha**, with flows validated and limits described in APP-STATUS.md; **[ ] = planned or incomplete**. Tests on physical devices remain separate. MVP = first version; V1 = individual enrichment; V2 = shared services and extensions. Priorities within blocks remain adjustable.

The product combines immediate access to tools with a game mode that shares players, time and scores.

## Access and experience — MVP

- [x] F001 — Quick tools without creating a game
- [x] F002 — Game mode combining the useful tools
- [x] F003 — Customizable home and favorites
- [x] F004 — Automatic resume of the last game
- [x] F005 — Offline operation of the core
- [x] F006 — No mandatory account
- [x] F007 — No ads
- [ ] F008 — French and English
- [x] F009 — Light and dark mode
- [ ] F010 — Phone and tablet, portrait and landscape
- [x] F011 — Large controls usable around the table
- [x] F012 — Colors accompanied by names or symbols
- [ ] F013 — Text size and screen readers
- [x] F014 — Animations, sounds and vibrations can be disabled
- [x] F015 — Screen kept on during a game

## Players and setup — MVP

- [ ] F016 — Local profiles with nickname, color and avatar
- [x] F017 — Guest players without a permanent profile
- [ ] F018 — Reusable player groups
- [ ] F019 — Manual or random teams
- [ ] F020 — Configurable number and size of teams
- [x] F021 — First player draw by list
- [x] F022 — Finger selection with countdown
- [x] F023 — Random or manual turn order
- [x] F024 — Restart a game with the same players
- [ ] F025 — Quick setup of the game, rounds and tools

## Chance and dice — MVP

- [x] F026 — d4, d6, d8, d10, d12, d20 and d100 dice
- [x] F027 — Several dice and automatic total
- [x] F028 — Lock some dice and reroll the others
- [x] F029 — Session results history
- [x] F030 — Coin flip
- [x] F031 — Draw a name, number or list item
- [x] F032 — Draw with or without replacement
- [x] F033 — Wheel with custom options
- [ ] F034 — Save dice sets and lists
- [x] F035 — Randomness provided by a secure system source

## Scores and resources — MVP

- [x] F036 — Scores per player or team
- [x] F037 — Quick add and subtract, free value
- [x] F038 — Configurable negative and decimal scores
- [x] F039 — Scores per round and cumulative total
- [x] F040 — Ranking by highest or lowest score
- [x] F041 — Tie and ex aequo handling
- [x] F042 — Points goal or number of rounds
- [x] F043 — Undo and redo a change
- [x] F044 — Score change log
- [x] F045 — Independent life, currency and resource counters
- [x] F046 — Labeled bonuses and penalties
- [x] F047 — Final summary and rematch

## Time and turns — MVP

- [ ] F048 — Game stopwatch
- [x] F049 — Shared countdown
- [x] F050 — Fixed time per turn
- [x] F051 — Time bank per player, from 2 to many players
- [x] F052 — Global pause and resume
- [x] F053 — Active player and pass-turn button
- [ ] F054 — Configurable low-time warning
- [x] F055 — Sound and vibration on expiry
- [ ] F056 — Different time per player
- [ ] F057 — Fischer increment and simple delay
- [ ] F058 — Turn and round counter
- [ ] F059 — Direction of rotation and rotating first player

## Reliability and data — MVP

- [x] F060 — Local save after every significant action
- [x] F061 — Recovery after the app is closed
- [x] F062 — Local history of finished games
- [x] F063 — JSON export and import of games
- [x] F064 — CSV export of scores
- [x] F065 — Individual deletion and full erasure
- [x] F066 — Confirmation before destructive reset
- [ ] F067 — Versioned migration of local data

## Advanced customization — V1

- [x] F068 — Symbol dice and custom faces
- [ ] F069 — Dice expressions, modifiers and successes
- [ ] F070 — Advantage, disadvantage and conditional rerolls
- [ ] F071 — Token bags with configurable contents and replacement
- [ ] F072 — Custom virtual card decks
- [ ] F073 — Weighted draws with visible probabilities
- [ ] F074 — Selecting several winners and random ranking
- [ ] F075 — Team composition constraints
- [x] F076 — Secret roles with individual reveal
- [ ] F077 — Simultaneous timers and time per team
- [ ] F078 — Bronstein, hourglass and byo-yomi time controls
- [ ] F079 — Multi-phase time controls
- [x] F080 — Score tallying by category
- [x] F081 — Declarative score formulas with no code executed
- [x] F082 — Cooperative goals and win/lose results
- [x] F083 — Game-specific notes, goals and counters

## Templates and community — V1

- [x] F084 — Complete presets per game
- [x] F085 — Score sheet editor
- [x] F086 — Game setup editor
- [x] F087 — Import and export of versioned JSON templates
- [x] F088 — Bundled library usable offline
- [x] F089 — Community catalog with search and filters
- [x] F090 — Template contributions by pull request
- [x] F091 — Automatic template validation
- [x] F092 — Author, version, language and license metadata
- [ ] F093 — Favorites and personal variants
- [x] F094 — Short original instructions and links to the official rules
- [ ] F095 — Template version and compatibility management

## History and evenings — V1

- [x] F096 — Game search by game, player and date
- [ ] F097 — Statistics on wins, scores and durations
- [ ] F098 — Score evolution and round comparison
- [ ] F099 — Game series and evening ranking
- [x] F100 — Team and cooperation results
- [ ] F101 — Sharing the summary as an image
- [x] F102 — Backup and restore of a complete library
- [ ] F103 — Table mode accessibility and per-player oriented display

## Shared games — V2

- [ ] F104 — Join a room by QR code or short code
- [ ] F105 — Guest nickname without a personal account
- [ ] F106 — Score entry from several devices
- [ ] F107 — Shared screen for scores and time
- [ ] F108 — Explicit host and edit permissions
- [ ] F109 — Shared log and handling of concurrent actions
- [ ] F110 — Reconnection and event catch-up
- [ ] F111 — Host role transfer
- [ ] F112 — Private roles and information per player
- [ ] F113 — Optional synchronization of the personal library
- [ ] F114 — Self-hostable server and deployment documentation
- [ ] F115 — Export and deletion of remote data

## Tournaments and extensions — V2

- [ ] F116 — Round-robin and knockout tournaments
- [ ] F117 — Swiss pairings with explicit rules
- [ ] F118 — Table and team rotation
- [ ] F119 — Ranking with configurable tiebreakers
- [ ] F120 — Kiosk or large-screen mode
- [ ] F121 — System shortcuts and widgets depending on platform
- [ ] F122 — Collection import via external services if allowed
- [ ] F123 — Stable template API and contribution tools

## Design constraints

- The number of simultaneous fingers depends on the screen, the browser and system gestures: always offer the draw by list.
- A timer must use timestamps and a monotonic clock while running; background reminders have limits depending on the platform. Test locking, sleep and resume.
- On the web, offline operation requires an explicit app cache. Browser storage can be erased: offer an exportable backup.
- The random draw is not for gambling. The animation presents the result without changing the probabilities.
- Templates do not embed third-party illustrations or rules without permission. Formulas are validated data, never arbitrary code.
- Scores and times stay readable without relying on color alone.

## Customization and style profiles — MVP

- [x] F124 — Light, dark and automatic mode following the system
- [x] F125 — Eleven coordinated palettes for backgrounds, texts and accents
- [x] F126 — Choice of seven readable font families
- [x] F127 — Real-time theme preview
- [x] F128 — Style applied on all screens
- [x] F129 — Four shape styles: beveled, sharp, soft and very rounded
- [x] F130 — Comfortable or compact density
- [x] F131 — Enlarged reading text
- [x] F132 — Reduced animations that also respect the system
- [x] F133 — Saving several style profiles on a device
- [x] F134 — Switching profile in one gesture
- [x] F135 — Custom name for each profile
- [x] F136 — Individual deletion of profiles
- [x] F137 — Theme export in JSON format
- [x] F138 — Theme import with format validation
- [x] F139 — Reset to the default style
- [x] F140 — Style kept after closing and reloading

- [x] F141 — Four visual universes: Playroom, Cyberdeck, Orbital 77 and Notebook

## Characters and cards — V1

- [x] F142 — Builder of categories and character creation cards
- [x] F143 — Generation by lists or boosters with minimum and maximum to keep
- [x] F144 — Sheets from the choices, save, JSON import and export
- [ ] F145 — Free sheets with attributes, skills, inventory and progression
- [ ] F146 — Generic card deck builder: front/back, draw, hand and discard
- [ ] F147 — Customizable boards, tracks and tokens
- [ ] F148 — Campaigns, scenarios and progression between sessions

## Game library, friends and memories — V1

Everything stays on the device, with no account or server. Exchanges go through QR code or an encrypted file.

- [x] F149 — Game library on shelves: each owned game is a box with genres, players, duration and linked packs
- [x] F150 — Game library game sheet: packs, games played, average rating, play and share
- [x] F151 — Friend profiles: first name, color, liked or avoided genres, maximum duration and refused games
- [x] F152 — Reviews and 1 to 5 star ratings per player at the end of a game
- [x] F153 — "What are we playing tonight?": library suggestions based on the friends present
- [x] F154 — Game memories: rating, highlights and photos
- [x] F155 — Private gallery exported as an encrypted file, key passed by QR code at the table
- [x] F156 — Merging received galleries without duplicates
- [x] F157 — Shared session (packs, dice, character sheets, players, game) in an animated QR code at 10 frames per second
- [x] F158 — Reception by scan with fountain coding: you can start midway and miss frames
- [x] F159 — Starting resources and statuses defined by the pack, applied to each player
- [x] F160 — Quick adjustment of resources and stackable statuses during the game
- [x] F161 — Per-game opinion on each friend (wants to, loves despite the genre, refused) and available time for suggestions

## Joining, accounts and evenings — V1

The Wi-Fi room works without a server. Remote play, accounts and online sign-ups require a Supabase project provided at build time (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`); without it, the app stays in local mode.

- [x] F162 — Game room opened by the host: short code, QR code and shareable link
- [x] F163 — Join by code, link or scan, on the same Wi-Fi (automatic discovery) or remotely
- [x] F164 — The host accepts or refuses each request, closes the room and starts the game with the accepted players
- [x] F165 — Local first name and optional online account: sign-up, sign-in, forgotten password
- [x] F166 — Evenings: date, place, seats, planned games
- [x] F167 — Yes / maybe / no sign-ups, first come first served, waiting list
- [x] F168 — Invitation to an evening by link, code or QR; answers saved on the server
- [x] F169 — Without a server, the host records their friends' answers themselves
- [x] F170 — Teams from the entered names, the room players or the fingers placed on the screen

**Total: 170 planned features.**

Customization is handled in Flutter. The checked boxes describe a local alpha; they are not an Android/iOS certification or a full accessibility validation.

**Alpha summary: 113 features checked; 57 planned or incomplete.**
