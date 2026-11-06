# Accessibility statement (draft)

Application: amiLudo, alpha 0.4.0. Targets: WCAG 2.2 level AA, and RGAA 4.1 as the French reference. Status: **not audited, not conformant by claim**. This page states what is implemented and what is verified, and no more. It is not a formal RGAA declaration, which requires an audit by a qualified auditor and a rate of conformity.

## What the code does

- Text scaling: layouts adapt to large system text (the shell switches layout above 125 percent, and card grids reduce their column count with the text scale).
- Reduced motion: the app honours the system "disable animations" setting and has its own motion switch. Wheel, dice, hourglass, pack opening and transitions shorten or stop.
- Touch targets: a design token sets a minimum interactive size of 44 px.
- Semantics: roughly one hundred places in the interface define semantic labels or tooltips, including icon buttons, counters, the dice tray, the hourglass, timers, finger pickers, photo grids and forms.
- Haptic and sound feedback are optional settings; no information is conveyed only by vibration or sound according to the design, but this has not been verified.
- Languages: seven interface languages (English, French, Spanish, German, Italian, Portuguese, Dutch), with an automated check that every language file has the same keys and placeholders.
- Keyboard: the web build is navigable by keyboard through Flutter's default focus handling. The search shortcut convention is not applicable to this app.

## What the automated tests verify

- Pages (home, tools, templates, library, friends, history) render without layout errors at 200 percent text scale, on a 390 x 844 phone and a 1280 x 720 desktop viewport.
- Design components render without errors at 390 x 844, 1280 x 720 and 1920 x 1080.
- Motion durations stay under 350 ms; reduced motion yields zero duration; the minimum target token is at least 44.
- Language files are complete.

These are regression tests against overflow and token values. They do not measure contrast, check every control's accessible name, nor prove screen reader behaviour.

## Not verified

- Colour contrast ratios of every theme (4.5:1 for text, 3:1 for components): no automated contrast check exists, and user-created themes can break it.
- Screen reader use on real devices: TalkBack on Android, VoiceOver on iOS and web, NVDA, JAWS.
- Focus order and visible focus on all screens, and keyboard operability of custom widgets (wheel, finger pad, QR scanner, drag interactions).
- The finger-based tools (teams by fingers, first player) require multi-touch and have no alternative gesture documented; a non-touch alternative exists through names and the room, but is not audited.
- Real-device tests of vibration, sounds, camera scanner, Wi-Fi discovery and multi-touch. The project status lists these as still to do.
- Safari and Windows high contrast mode.
- Text in images and cards: alternative text of illustrations and generated cards.
- Time limits: timers and hourglasses are tools, not session time limits; no session timeout exists. Not verified against 2.2.1 for the account sign-in code expiry.
- Table-mode accessibility and per-player oriented display (feature F103) is not done.
- Authentication emails are sent in English only and have not been checked.

## Known gaps stated by the project

The features catalogue states that its checked boxes are not a full accessibility validation, and the roadmap lists accessibility proof before broader release.

## Plan before store release

1. Run Flutter's accessibility guideline checks (labeled tap target, text contrast) in widget tests for the main screens.
2. Test TalkBack and VoiceOver on real devices on the scenarios: create a game, add points, undo, roll dice, join a room.
3. Check contrast of every built-in theme and warn on low contrast in the theme editor.
4. Commission an RGAA audit if the app is offered in France to the public sector or meets the legal thresholds, then publish a declaration with the conformity rate.

## Contact and feedback

Accessibility issues can be reported to [email or issue tracker URL]. Target response time: [x working days].
