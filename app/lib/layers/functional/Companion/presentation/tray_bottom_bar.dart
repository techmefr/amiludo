import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/tray_result.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_history_sheet.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Network/link_share.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class TrayBottomBar extends StatelessWidget {
  const TrayBottomBar({
    super.key,
    required this.session,
    required this.onAdd,
    required this.onLook,
    this.onClear,
  });
  final DiceTraySession session;
  final VoidCallback onAdd, onLook;
  final VoidCallback? onClear;

  String get shareText => trayResultText(
    TrayResultMode.combined,
    session,
    oddEven: (odd, even) => '',
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final thrown = session.thrown;
    return Row(
      children: [
        IconButton(
          tooltip: l.diceLook,
          onPressed: onLook,
          icon: const Icon(Icons.tune),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text(l.diceTrayAddDie),
        ),
        Expanded(
          child: Text(
            l.diceTrayCount(session.settings.dice.length),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        IconButton(
          tooltip: l.diceTrayErase,
          onPressed: thrown ? onClear : null,
          icon: const Icon(Icons.backspace_outlined),
        ),
        IconButton(
          tooltip: l.diceTrayShareResult,
          onPressed: thrown ? () => shareLink(shareText) : null,
          icon: const Icon(Icons.ios_share),
        ),
        IconButton(
          tooltip: l.diceTrayHistory,
          onPressed: session.history.isEmpty
              ? null
              : () => showTrayHistorySheet(context, session),
          icon: const Icon(Icons.history),
        ),
        const SizedBox(width: Space.xs),
      ],
    );
  }
}
