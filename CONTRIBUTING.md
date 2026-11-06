# Contributing

The companion is a Flutter application in public alpha, under the MIT license. Feedback from real devices, fixes, translations, accessibility improvements and game templates are welcome.

Start with the [testing guide](TESTING.md). For a significant change, open a proposal explaining the game, the problem and the desired behavior; check the [catalog](docs/FEATURES.md) to avoid duplicates. Small fixes can be proposed directly by pull request.

## Development

Install Flutter **3.47.9** (Dart **3.13.7**), then:

```sh
cd app
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
cd ..
python3 -m unittest discover -s scripts -p 'test_*.py'
```

The full web build uses `bash scripts/build_web.sh`. Android requires the Android SDK and JDK 17; iOS requires macOS and Xcode. Dependency versions are locked.

The code is in `app/lib/layers/functional` and `app/lib/layers/technical`, the tests in `app/test`, the mockups in `prototype` and the publishing tools in `scripts`.

## Propose a change

1. Create a fork and a dedicated branch.
2. Keep the change focused and explain its effect for players.
3. Check the analysis and the tests; cover any affected score, time, import or storage rules. For an interface change, attach a screenshot and list the devices tested.
4. Update the catalog if a feature becomes genuinely usable. Flag the remaining limits and any data format changes.
5. Open a pull request against `main`.

Keep local operation without an account, accessibility and portable backups. Do not commit secrets or personal data. Templates, images, fonts and other contributions must have a compatible origin and license. Do not include third-party rulebooks, illustrations or trademarks without permission; keep the required credits and licenses.

Discussions must stay respectful and focus on usage and the proposed changes. For a vulnerability, follow [SECURITY.md](SECURITY.md).
