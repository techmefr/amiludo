# Community gallery

Each JSON pack can bundle dice, roles, score categories, instructions and a rules link. Installed packs remain usable offline. Notes are included; remote rulebooks stay with their publisher.

## Publish a pack

1. Create and test the pack in the application builder.
2. Fill in author, version, edition/variant and license. Only use text and content you are allowed to share.
3. Export the JSON from "Pack tools and rules".
4. Add the file to `community/packs/` with a unique name and open a pull request. The suggestion button opens this folder on GitHub; the application does not publish anything automatically.
5. Describe the game, the calculations you verified and the limits. After review and merge, the catalog is rebuilt and published; users can refresh it in the gallery.

The three initial packs are original examples from the project, not creations presented as submitted by other users. The gallery currently offers no purchases, dedicated accounts or ratings. A GitHub account is required to propose an addition; no account is required to install public packs.

## Format and verification

The format remains `table-companion-template`, version 1. Older templates without dice, roles or calculations remain readable. A pack has its own version (`revision`). Games keep a copy of their pack so that a later change does not alter their rules.

Declarative calculations support: quantity × factor, complete lots, triangular progression, and threshold and scale for whole quantities. No code supplied by a pack is executed. A sheet replaces a category total for a round, keeping an undoable log. It does not verify moves or all the conditions of a commercial game.

From the root: `python3 scripts/build_catalog.py`, then the Flutter tests. The generated catalog is embedded and published on the site. The tests validate each pack with the same reader as the application. Do not edit any generated file by hand.

Packs can also include `creation`: character card categories, suggested number per booster, and the minimum and maximum kept. Generated sheets belong to the local library, not to the public catalog.
