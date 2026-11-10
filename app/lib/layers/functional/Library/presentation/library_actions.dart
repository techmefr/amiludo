import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/list_row.dart';

class LibraryActions extends StatelessWidget {
  const LibraryActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rows = <(IconData, String, VoidCallback)>[
      (
        Icons.qr_code_scanner,
        l.libraryScanBox,
        () => context.push('/library/scan'),
      ),
      (
        Icons.nightlight_outlined,
        l.libraryWhatToPlay,
        () => context.push('/library/tonight'),
      ),
      (
        Icons.qr_code_2,
        l.libraryReceiveByQr,
        () => context.push('/share/receive'),
      ),
      (Icons.ios_share, l.libraryShareASession, () => context.push('/share')),
      (
        Icons.inventory_2_outlined,
        l.libraryPacksAndTemplates,
        () => context.go('/templates'),
      ),
    ];
    return Column(
      children: [
        for (final (icon, label, onTap) in rows)
          ListRow(
            title: label,
            leading: Icon(icon),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap,
          ),
      ],
    );
  }
}
