import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Network/link_share.dart';
import 'package:amiludo/layers/technical/Network/room_link.dart';
import 'package:amiludo/layers/technical/Qr/qr_code.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class InviteCard extends StatelessWidget {
  const InviteCard({super.key, required this.link, required this.title});

  final RoomLink link;
  final String title;

  String get _spaced =>
      link.code.replaceAllMapped(RegExp('.{1,4}'), (m) => '${m[0]} ').trim();

  @override
  Widget build(BuildContext context) {
    final url = link.shareUri.toString();
    return DeckPanel(
      child: Column(
        children: [
          QrCode(data: url, size: 220),
          const SizedBox(height: 16),
          Text(tr(context, 'Code', 'Code')),
          SelectableText(
            _spaced,
            style: Theme.of(context).textTheme.displaySmall,
            semanticsLabel: link.code.split('').join(' '),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => shareLink(
                  tr(
                    context,
                    'Rejoins « $title » sur amiLudo : $url (code ${link.code})',
                    'Join “$title” on amiLudo: $url (code ${link.code})',
                  ),
                  subject: title,
                ),
                icon: const Icon(Icons.share),
                label: Text(tr(context, 'Partager le lien', 'Share link')),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await copyText(link.code);
                  if (context.mounted) {
                    notify(context, tr(context, 'Code copié', 'Code copied'));
                  }
                },
                icon: const Icon(Icons.copy),
                label: Text(tr(context, 'Copier le code', 'Copy code')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
