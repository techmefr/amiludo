# Interactive mockups

Deliberately provisional name: "compagnon". Standalone web prototype, meant to validate the experience before the Flutter port. It does not replace the production app.

## Try it

Open https://techmefr.github.io/amiludo/ or run `python3 -m http.server 4173 --directory prototype` at the repository root, then open http://localhost:4173.

## Screens

Home, game in progress, tools, template library, history, appearance. Template-specific screens are explicitly previews. The catalog of 141 features is reachable from the tools and can be filtered. On mobile, library and history remain reachable through the home links; frequent destinations are in the bottom bar.

## Your style

Universes: Cyberdeck (default), Orbital 77, Carnet. Palettes: Acid Circuit, Night City, Amber Terminal, Plasma, Lichen, Lavender, Terracotta, Tide, Honey, Dew. Fonts: Chakra Petch, Rajdhani, IBM Plex Mono, DM Sans, Manrope, Nunito Sans, Space Grotesk. Light, dark and system modes; beveled, sharp, soft or round shapes; density and enlarged reading; animations can be disabled. Profiles are local to each browser: no account or sync. Versioned JSON export and validated import.

Fonts are loaded from Google Fonts and need a connection on first load; a system font takes over. Plan to self-host the fonts in the app. The prototype includes no service worker and does not promise offline loading.

## Interactions

Scores for 2 to 8 players, undo, rounds, turn passing, foreground timer, dice rolls, coin flip, player picker, teams, order and wheel. The initial values and two history entries are flagged examples. Multi-touch picking depends on the device. The wheel shows a text result: its decorative sectors do not represent the options.

The timer is not a system alarm; it stops when the page is left and is not restored after closing. History and scores are local; clearing browser data deletes them. Score undo applies to the current session.

## Verification

Navigation of the six screens, theme persistence after reload, saved profile, adding/undoing points, turn passing, timer, dice, teams and catalog search were tested in Chromium. Display checked at 1440 px and 390 px, with no horizontal overflow on the four main mobile screens. Screenshots in design/mockups. Physical iOS/Android devices and screen readers remain to be checked.

Additional validation: applying profiles, theme export, valid import and rejection of invalid files. The public link and its 141 entries were checked with no JavaScript errors. Library reachable in mobile navigation.
Headings use Chakra Petch in Cyberdeck and Rajdhani in Orbital. The chosen font customizes compatible texts and controls; Carnet also uses this font for its headings. Theme exports are now version 2, with support for reading old version 1 exports. Old profiles without a universe are interpreted as Carnet. Screenshots of the new direction: design/mockups/cyber.
