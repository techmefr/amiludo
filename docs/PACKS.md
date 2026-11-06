# Packs, builders and gallery

Alpha 0.2.0 lets you build one pack per game from Templates → Create a companion. Every tool opens on its own page with a back button; finger selection has a touch surface that fills the available space. Short confirmations remain dialogs.

## Pack contents

- Dice: several types, number of copies, label and value of each face. Repeated faces change the probabilities; rolls let you keep dice.
- Roles: name, headcount and private instruction. Dealing requires one card per participant; cards are revealed one at a time, then hidden. Leaving the app hides the revealed card.
- Scores: categories, multiplication, complete sets, triangular progression, thresholds and custom scales. Computed quantities replace a category's total in the round; they do not double it. The log can be undone.
- Characters: free categories (races, professions, backgrounds, powers...), cards and descriptions, booster size, minimum and maximum number of cards to keep. Example: offer four races and keep one or two. List mode offers all the cards; booster mode draws without duplicates. The choices form a local sheet that can be exported and imported.
- Rules: HTTPS link, editing and personal notes included in the pack. The remote rulebook stays a link; the app neither fetches nor analyzes it automatically.
- Pack author, language, license and version.

A game keeps a copy of its pack. Editing a pack in the library does not recompute existing games. Character sheets are kept after the original pack is deleted; they are included in the global backup.

## Community gallery

The initial catalog contains three original examples, clearly identified. You can search, filter, install and reinstall a pack. Installing copies the data into the library; reinstalling asks for confirmation before replacing. Refreshing loads the public catalog; the bundled catalog remains available offline. Installed packs remain usable offline.

To share: export the pack, then submit its file to the public repository. See [community/README.md](../community/README.md). Publication goes through a pull request and a review, with no automatic upload from the app. There are no dedicated accounts, ratings, purchases or instant publishing yet.

## Current limits

Calculations are limited declarative operations, not a universal referee for every rule of a game. Generated sheets contain the choices and descriptions; numeric attributes, inventories, combat and free progression have yet to be built. Booster cards are not yet a generic draw/hand/discard engine. Private hands across several devices will require shared rooms.

Multitouch tests on physical devices are still needed. Creations in progress and tool draws are not restored; save a sheet or a pack to keep it.

Free mode opens the tools without a pack. A per-game companion gathers the configured modules in a dashboard. The interface icons use Hugeicons Free, under the MIT license; they are bundled in the build and require no external loading.

The builder is walked through in steps: local and English name, mode selection, settings for the selected modes only, summary. Publication metadata stays collapsed. Unselected tools are not imposed on the game's companion.
