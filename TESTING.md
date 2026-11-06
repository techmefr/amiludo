# Testing the companion

The alpha is public, free and usable without an account. The name remains provisional.

- **Web, desktop and mobile:** https://techmefr.github.io/amiludo/app/
- **Android:** download the APK file from the latest [test release](https://github.com/techmefr/amiludo/releases). Allow its installation from your browser if Android asks.
- **iPhone and iPad:** test the site in Safari. No native iOS app is currently distributed.

## A first ten-minute try

1. Create a game with several players, add points and a round.
2. Undo then redo a change; close and reopen the application to check that the game resumes.
3. Try the dice, a draw, teams and a clock with pause.
4. Choose a universe, a palette and a font; check that they are kept after reloading.
5. Turn off sounds, vibrations and animations according to your preferences.
6. Export a JSON backup and keep it. Test a restore only with data you can replace.
7. After a first full load while online, go offline, reopen and edit a game. Go back online if the resources have not finished downloading.
8. Finish a game and find its result in the history; try the CSV export.

## Report a problem

Use the [bug form](https://github.com/techmefr/amiludo/issues/new?template=bug_report.yml). Give the version shown in "About", the device, the browser and the steps to reproduce. Do not attach any backup containing personal information; use fictional players.

[Discussions](https://github.com/techmefr/amiludo/discussions) welcome questions and usage feedback. For a new feature, describe the game concerned and the need in the [feature request form](https://github.com/techmefr/amiludo/issues/new?template=feature_request.yml).

## Limits of this alpha

Chromium flows have been checked, including persistent scores and offline reloading. Tests on physical phones, Safari, multitouch, vibrations and sleep behavior remain to be completed. Sounds also depend on the system. A clock does not guarantee an alarm when the system suspends the application.

The browser may clear local storage. Export a backup regularly. Test APKs use a development signature; an update may require an uninstall. **Back up before updating**, because uninstalling erases local data.

Shared rooms, tournaments and other unchecked features of the [catalog](docs/FEATURES.md) are not yet available.

## New flows in alpha 0.2.0

- From Templates, open the gallery, install an example and find it in the library.
- Create a pack with several dice, roles and a calculation; save it, reopen it and export its JSON.
- Start a game with this pack and apply a count twice: a category total must not be doubled.
- Install "Origines", choose the boosters, keep two races then finish the character. Save the sheet, reload and find it again. Also test list mode and sheet export/import.
- Open "Who starts?": the touch selection fills the page; the back button returns to the tools.
