import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Theme/deck_widgets.dart';

const appVersion = '0.2.0-alpha.1';
const projectUrl = 'https://github.com/techmefr/ludoply';
const bugReportUrl = '$projectUrl/issues/new?template=bug_report.yml';
const featureRequestUrl = '$projectUrl/issues/new?template=feature_request.yml';
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final font in [
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
      notify(
        context,
        tr(
          context,
          'Le navigateur n’a pas ouvert le lien. Copiez le lien du projet affiché ci-dessous.',
          'The browser could not open the link. Copy the project link shown below.',
        ),
      );
    }
  } on PlatformException {
    if (context.mounted) {
      notify(
        context,
        tr(
          context,
          'Impossible d’ouvrir le navigateur.',
          'Could not open the browser.',
        ),
      );
    }
  }
}

void showProjectInfo(BuildContext context) => showAboutDialog(
  context: context,
  applicationName: 'Compagnon',
  applicationVersion: appVersion,
  applicationLegalese: tr(
    context,
    'Code sous licence MIT. Nom provisoire.',
    'MIT-licensed code. Working name.',
  ),
  applicationIcon: Icon(
    Icons.diamond_outlined,
    size: 40,
    color: Theme.of(context).colorScheme.primary,
  ),
  children: [
    const SizedBox(height: 16),
    Text(
      tr(
        context,
        'Participez aux essais ou proposez une amélioration. Le code et la feuille de route sont publics.',
        'Join testing or propose an improvement. Source code and roadmap are public.',
      ),
    ),
    const SizedBox(height: 16),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton.icon(
          onPressed: () => openProjectLink(context, bugReportUrl),
          icon: const Icon(Icons.bug_report_outlined),
          label: Text(tr(context, 'Signaler un bug', 'Report a bug')),
        ),
        TextButton.icon(
          onPressed: () => openProjectLink(context, featureRequestUrl),
          icon: const Icon(Icons.lightbulb_outline),
          label: Text(tr(context, 'Proposer une idée', 'Suggest an idea')),
        ),
      ],
    ),
    const SizedBox(height: 12),
    const SelectableText(projectUrl),
  ],
);
