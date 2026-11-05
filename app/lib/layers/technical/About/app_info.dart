import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

const appVersion = '0.4.0-alpha.1';
const projectUrl = 'https://github.com/techmefr/amiludo';
const bugReportUrl = '$projectUrl/issues/new?template=bug_report.yml';
const featureRequestUrl = '$projectUrl/issues/new?template=feature_request.yml';
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final font in [
      'LilGrotesk',
      'BricolageGrotesque',
      'SpaceGrotesk',
      'ChakraPetch',
      'Rajdhani',
      'IBMPlexMono',
      'DMSans',
      'Manrope',
      'NunitoSans',
      'NotoSansSymbols',
      'NotoSansSymbols2',
    ]) {
      yield LicenseEntryWithLineBreaks([
        'Font $font',
      ], await rootBundle.loadString('assets/fonts/$font-OFL.txt'));
    }
  });
}

Future<void> openProjectLink(BuildContext context, String url) async {
  try {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      notify(context, context.l10n.aboutTheBrowserCouldNotOpen);
    }
  } on PlatformException {
    if (context.mounted) {
      notify(context, context.l10n.aboutCouldNotOpenTheBrowser);
    }
  }
}

void showProjectInfo(BuildContext context) => showAboutDialog(
  context: context,
  applicationName: 'amiLudo',
  applicationVersion: appVersion,
  applicationLegalese: context.l10n.aboutMitLicensedCode,
  applicationIcon: DeckIcon(
    Icons.diamond_outlined,
    size: 40,
    color: Theme.of(context).colorScheme.primary,
  ),
  children: [
    const SizedBox(height: 16),
    Text(context.l10n.aboutJoinTestingOrProposeAn),
    const SizedBox(height: 16),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton.icon(
          onPressed: () => openProjectLink(context, bugReportUrl),
          icon: const DeckIcon(Icons.bug_report_outlined),
          label: Text(context.l10n.aboutReportABug),
        ),
        TextButton.icon(
          onPressed: () => openProjectLink(context, featureRequestUrl),
          icon: const DeckIcon(Icons.lightbulb_outline),
          label: Text(context.l10n.aboutSuggestAnIdea),
        ),
      ],
    ),
    const SizedBox(height: 12),
    const SelectableText(projectUrl),
  ],
);
